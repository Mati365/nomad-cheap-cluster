import * as path from "path";
import * as fs from "fs";
import * as os from "os";

import * as pulumi from "@pulumi/pulumi";
import { local } from "@pulumi/command";

import { AppCluster } from "./create-skeleton-cluster";
import {
  ensureDirIsEmpty,
  isPortReachable,
  resolveDistPath,
  resolveProjectAnsiblePath,
} from "../utils";

type ConfigureClusterConfig = {
  env: string;
  cluster: AppCluster;
  force?: boolean;
};

export const ansibleConfigureCluster = ({
  env,
  force,
  cluster: { nodes, privateNetwork },
}: ConfigureClusterConfig) => {
  const allIpv4 = pulumi.all([
    nodes.server.ipv4Address,
    nodes.client.ipv4Address,
  ]);

  const inventory = pulumi.interpolate`
    [server]
    ${nodes.server.ipv4Address}

    [client]
    ${nodes.client.ipv4Address}

    [cluster:children]
    server
    client

    [web:children]
    cluster
  `;

  const groupVars = pulumi.interpolate`
    env: ${env}
    cluster_cidr: "${privateNetwork.ipv4.subNetworks[0]}"

    addresses:
      consul:
        ip: ${privateNetwork.ipv4.server}
        port: 8500
        dns_port: 8600
        stats_port: 3000

      server: ${privateNetwork.ipv4.server}
  `;

  const clusterAvailable = nodes.server.ipv4Address.apply((ip) =>
    pulumi.output(isPortReachable(8200, { host: ip }))
  );

  return pulumi
    .all([inventory, groupVars, allIpv4, clusterAvailable])
    .apply(([inventory, groupVars, allIpv4, clusterAvailable]) => {
      const resolveInventoryPath = (file: string = "") =>
        resolveDistPath(path.join("ansible", "inventory", file));

      const inventoryHostsPath = resolveInventoryPath("hosts.ini");
      const groupVarsPath = resolveInventoryPath("group_vars/all.yml");

      ensureDirIsEmpty(resolveInventoryPath());
      ensureDirIsEmpty(resolveInventoryPath("group_vars"));

      fs.writeFileSync(inventoryHostsPath, inventory, "utf-8");
      fs.writeFileSync(groupVarsPath, groupVars, "utf-8");

      const ansiblePath = resolveProjectAnsiblePath();
      const playbookPath = resolveProjectAnsiblePath("configure.yml");
      const keyscanHosts = allIpv4.map(
        (ip) =>
          new local.Command(`Keyscan keys ${ip}`, {
            create: `sleep 4; ssh-keygen -f "${os.homedir()}/.ssh/known_hosts" -R "${ip}"`,
          })
      );

      console.info(
        `cd ${ansiblePath}; ansible-playbook ${playbookPath} -i ${inventoryHostsPath}`
      );

      new local.Command(
        "Ansible sync config",
        {
          create: clusterAvailable && !force
            ? "/bin/true"
            : `cd ${ansiblePath}; ansible-playbook ${playbookPath} -i ${inventoryHostsPath}`,
        },
        {
          dependsOn: keyscanHosts,
        }
      );
    });
};
