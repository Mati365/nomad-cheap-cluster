import * as hcloud from "@pulumi/hcloud";

export const createFirewallRuleForPorts = (
  ports: (string | number)[],
  rule: Omit<hcloud.types.input.FirewallRule, "port">
): hcloud.types.input.FirewallRule[] =>
  ports.map((port) => ({
    ...rule,
    port: port.toString(),
  }));
