import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import * as hcloud from "@pulumi/hcloud";

import { resolveProjectKeyPath } from "./resolve-project-key-path";

type SSHKey = {
  name: string;
  file: string;
};

export const readSSHKeys = (keys: SSHKey[]) =>
  keys.map(({ file, name }) => {
    const absolutePath = file.startsWith("~")
      ? path.join(os.homedir(), file.slice(2))
      : resolveProjectKeyPath(file);

    return new hcloud.SshKey(name, {
      publicKey: fs.readFileSync(absolutePath, "utf-8"),
    });
  });
