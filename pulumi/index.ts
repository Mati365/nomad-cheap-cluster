import * as hcloud from "@pulumi/hcloud";
import {
  readSSHKeys,
  createFirewallRuleForPorts,
  readSSHKeySync,
} from "./utils";

const createSiteStack = () => {
  const { hcloudKeys: defaultSshKeys, names: sshKeysNames } = readSSHKeys([
    { name: "default", file: "~/.ssh/id_rsa.pub" },
    { name: "ansible", file: "ansible/id_rsa.pub" },
  ]);

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
    networkId: network.id.apply((id) => +id),
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

  return {
    server: new hcloud.Server(
      "nomad-server",
      {
        serverType: "cx21",
        image: "debian-11",
        location: "fsn1",
        firewallIds: [clusterNodeFirewall.id as any],
        sshKeys: sshKeysNames,
        networks: [
          {
            networkId: network.id.apply((id) => +id),
            ip: "10.0.0.2",
          },
        ],
        publicNets: [
          {
            ipv4Enabled: true,
          },
        ],
        userData,
      },
      {
        dependsOn: [...defaultSshKeys, networkSubnet, clusterNodeFirewall],
      }
    ),

    client: new hcloud.Server(
      "nomad-client",
      {
        serverType: "cpx11",
        image: "debian-11",
        location: "fsn1",
        firewallIds: [clusterNodeFirewall.id.apply((id) => +id)],
        sshKeys: sshKeysNames,
        publicNets: [
          {
            ipv4Enabled: true,
          },
        ],
        networks: [
          {
            networkId: network.id.apply((id) => +id),
            ip: "10.0.0.3",
          },
        ],
        userData,
      },
      {
        dependsOn: [...defaultSshKeys, networkSubnet, clusterNodeFirewall],
      }
    ),
  };
};

createSiteStack();
