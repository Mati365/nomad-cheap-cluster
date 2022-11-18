import * as pulumi from "@pulumi/pulumi";
import * as hcloud from "@pulumi/hcloud";

import {
  readSSHKeys,
  createFirewallRuleForPorts,
} from "./utils";

const createSiteStack = () => {
  const sshKeys = readSSHKeys([
    { name: 'default', file: "~/.ssh/id_rsa.pub" },
    { name: 'ansible', file: "ansible/id_rsa.pub" },
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
};

createSiteStack();
