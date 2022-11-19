import * as hcloud from "@pulumi/hcloud";
import { AppCluster } from "./create-skeleton-cluster";

type ClusterSnapshotsConfig = {
  cluster: AppCluster;
};

export const createClusterSnapshots = ({
  cluster: { nodes },
}: ClusterSnapshotsConfig) => [
  new hcloud.Snapshot(
    "cluster-client-snapshot",
    {
      serverId: nodes.client.id as any,
    },
  ),

  new hcloud.Snapshot(
    "cluster-server-snapshot",
    {
      serverId: nodes.server.id as any,
    },
  ),
];
