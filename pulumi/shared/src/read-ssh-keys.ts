import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import * as hcloud from "@pulumi/hcloud";

import { resolveProjectKeysPath } from "./paths/resolve-project-path";

type SSHKeys = {
  [name: string]: string;
};

export const readSSHKeySync = (file: string) => {
  const absolutePath = file.startsWith("~")
    ? path.join(os.homedir(), file.slice(2))
    : resolveProjectKeysPath(file);

  return fs.readFileSync(absolutePath, "utf-8");
};

export const readSSHKeys = (keys: SSHKeys) => {
  const files = Object.fromEntries(
    Object.entries(keys).map(([name, file]) => [name, readSSHKeySync(file)])
  );

  const cloud = Object.entries(files).map(
    ([name, file]) =>
      new hcloud.SshKey(name, {
        publicKey: file,
      })
  );

  return {
    cloud,
    files,
  };
};
