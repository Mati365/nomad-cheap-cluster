import * as hcloud from "@pulumi/hcloud";
import * as pulumi from "@pulumi/pulumi";

import {
  createFirewallRuleForPorts,
  genInternalNetworkCardName,
} from "./utils";

type ClusterPrivateNetConfig = {
  ipv4: {
    network: string;
    subNetworks: string[];
    server: string;
    client: string;
  };
};

type CreateServersConfig = {
  sshKeys: hcloud.SshKey[];
  privateNetwork: ClusterPrivateNetConfig;
  getUserData(attrs: { internalNetworkCardName: string }): string;
};

export type AppCluster = ReturnType<typeof createSkeletonCluster>;

export const createSkeletonCluster = ({
  sshKeys,
  privateNetwork,
  getUserData,
}: CreateServersConfig) => {
  const clusterNodeFirewall = new hcloud.Firewall("cluster-node-firewall", {
    rules: [
      {
        direction: "in",
        protocol: "icmp",
        sourceIps: ["0.0.0.0/0", "::/0"],
      },
      ...createFirewallRuleForPorts([22, 80, 443, 8200, 5000], {
        direction: "in",
        sourceIps: ["0.0.0.0/0", "::/0"],
        protocol: "tcp",
      }),
    ],
  });

  const network = new hcloud.Network("cluster-network", {
    ipRange: privateNetwork.ipv4.network,
  });

  const subNetworks = privateNetwork.ipv4.subNetworks.map(
    (ip, index) =>
      new hcloud.NetworkSubnet(`network-subnet-${index}`, {
        type: "cloud",
        networkId: network.id as any,
        networkZone: "eu-central",
        ipRange: ip,
      })
  );

  const nodes = pulumi
    .all([...sshKeys, ...subNetworks, clusterNodeFirewall])
    .apply(() => {
      const serverConfig = {
        image: "debian-11",
        location: "fsn1",
        firewallIds: [clusterNodeFirewall.id as any],
        sshKeys: sshKeys.map((key) => key.id),
        publicNets: [
          {
            ipv4Enabled: true,
          },
        ],
      };

      return {
        server: new hcloud.Server("nomad-server", {
          ...serverConfig,
          serverType: "cx21",
          userData: getUserData({
            internalNetworkCardName: genInternalNetworkCardName("cx21"),
          }),
          networks: [
            {
              networkId: network.id as any,
              ip: privateNetwork.ipv4.server,
            },
          ],
        }),

        client: new hcloud.Server("nomad-client", {
          ...serverConfig,
          serverType: "cpx11",
          userData: getUserData({
            internalNetworkCardName: genInternalNetworkCardName("cpx11"),
          }),
          networks: [
            {
              networkId: network.id as any,
              ip: privateNetwork.ipv4.client,
            },
          ],
        }),
      };
    });

  return {
    privateNetwork,
    nodes,
  };
};
