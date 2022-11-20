// https://docs.hetzner.com/cloud/networks/server-configuration/#debian--ubuntu
const INTERNAL_CARD_NETWORKS = {
  cx21: "ens10",
  cpx11: "enp7s0",
} as const;

export const genInternalNetworkCardName = (
  type: keyof typeof INTERNAL_CARD_NETWORKS
) => INTERNAL_CARD_NETWORKS[type];
