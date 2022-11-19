import * as path from "path";
import * as fs from "fs";

import * as hcloud from "@pulumi/hcloud";
import * as pulumi from "@pulumi/pulumi";
// import { local } from "@pulumi/command";

import {
  readSSHKeys,
  createFirewallRuleForPorts,
  readSSHKeySync,
  ensureDirIsEmpty,
  resolveDistPath,
} from "./utils";

const createSiteStack = () => {
  const { hcloudKeys: defaultSshKeys, names: sshKeysNames } = readSSHKeys({
    default: "~/.ssh/id_rsa.pub",
    ansible: "ansible/id_rsa.pub",
  });

  const clusterNodeFirewall = new hcloud.Firewall("cluster-node-firewall", {
    rules: [
      {
        direction: "in",
        protocol: "icmp",
        sourceIps: ["0.0.0.0/0", "::/0"],
      },
      ...createFirewallRuleForPorts([80, 443, 8200, 8500, 22], {
        direction: "in",
        sourceIps: ["0.0.0.0/0", "::/0"],
        protocol: "tcp",
      }),
    ],
  });

  const network = new hcloud.Network("cluster-network", {
    ipRange: "10.0.0.0/16",
  });

  const networkSubnet = new hcloud.NetworkSubnet("network-subnet", {
    type: "cloud",
    networkId: network.id as any,
    networkZone: "eu-central",
    ipRange: "10.0.0.0/24",
  });

  const userData = /* yaml */ `
    #cloud-config
    users:
      - name: ansible
        groups: users, admin
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        home: /home/ansible
        ssh_authorized_keys:
          - ${readSSHKeySync("ansible/id_rsa.pub")}
  `;

  const serverConfig = {
    image: "debian-11",
    location: "fsn1",
    firewallIds: [clusterNodeFirewall.id as any],
    sshKeys: sshKeysNames,
    publicNets: [
      {
        ipv4Enabled: true,
      },
    ],
    userData,
  };

  const cluster = pulumi
    .all([...defaultSshKeys, networkSubnet, clusterNodeFirewall])
    .apply(() => ({
      server: new hcloud.Server("nomad-server", {
        ...serverConfig,
        serverType: "cx21",
        networks: [
          {
            networkId: network.id as any,
            ip: "10.0.0.2",
          },
        ],
      }),

      client: new hcloud.Server("nomad-client", {
        ...serverConfig,
        serverType: "cpx11",
        networks: [
          {
            networkId: network.id as any,
            ip: "10.0.0.3",
          },
        ],
      }),
    }));

  cluster.apply(({ server, client }) => {
    const resolveInventoryPath = (file: string = "") =>
      resolveDistPath(path.join("ansible", "inventory", file));

    const inventory = `
      [server]
      ${server.ipv4Address.get()}

      [client]
      ${client.ipv4Address.get()}

      [cluster:children]
      server
      client

      [web:children]
      cluster
    `.trim();

    const serverPrivateIp = server.networks.get()?.[0].ip;
    const groupVars = `
      env: dev
      ip:
        cidr: "${networkSubnet.ipRange.get()}"
        interface:
          default: "ens10"

      addresses:
        consul:
          ip: ${serverPrivateIp}
          port: 8500
          dns_port: 8600
          stats_port: 3000

        server: ${serverPrivateIp}
    `.trim();

    const inventoryHostsPath = resolveInventoryPath("hosts.cfg");
    const groupVarsPath = resolveInventoryPath("group_vars/all.ini");

    ensureDirIsEmpty(resolveInventoryPath());
    ensureDirIsEmpty(resolveInventoryPath("group_vars"));

    fs.writeFileSync(inventoryHostsPath, inventory, "utf-8");
    fs.writeFileSync(groupVarsPath, groupVars, "utf-8");
  });
};

createSiteStack();
