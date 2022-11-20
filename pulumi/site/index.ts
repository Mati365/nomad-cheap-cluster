import { readSSHKeys } from "./utils";
import {
  ansibleConfigureCluster,
  createClusterSnapshots,
  createSkeletonCluster,
} from "./cluster";

const sshKeys = readSSHKeys({
  default: "~/.ssh/id_rsa.pub",
  ansible: "ansible/id_rsa.pub",
});

const cluster = createSkeletonCluster({
  sshKeys: sshKeys.cloud,
  privateNetwork: {
    ipv4: {
      network: "10.0.0.0/16",
      subNetworks: ["10.0.0.0/24"],
      server: "10.0.0.2",
      client: "10.0.0.3",
    },
  },
  getUserData: ({ internalNetworkCardName }) =>
    /* yaml */ `
    #cloud-config
    users:
      - name: ansible
        groups: users, admin
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        home: /home/ansible
        ssh_authorized_keys:
          - ${sshKeys.files["ansible"]}
    write_files:
      - path: /etc/network/cluster-network-card-name
        content: ${internalNetworkCardName}
        permissions: '0755'
  `.trim(),
});

ansibleConfigureCluster({ env: "prod", cluster }).apply(() =>
  createClusterSnapshots({ cluster })
);
