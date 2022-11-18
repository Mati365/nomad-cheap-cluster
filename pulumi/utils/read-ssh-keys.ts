import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import * as hcloud from "@pulumi/hcloud";

import { resolveProjectKeyPath } from "./resolve-project-key-path";

type SSHKey = {
  name: string;
  file: string;
};

export const readSSHKeySync = (file: string) => {
  const absolutePath = file.startsWith("~")
    ? path.join(os.homedir(), file.slice(2))
    : resolveProjectKeyPath(file);

  return fs.readFileSync(absolutePath, "utf-8");
};

export const readSSHKeys = (keys: SSHKey[]) => {
  const hcloudKeys = keys.map(
    ({ file, name }) =>
      new hcloud.SshKey(name, {
        publicKey: readSSHKeySync(file),
      })
  );

  return {
    names: keys.map((key) => key.name),
    hcloudKeys,
  };
};
