import * as fs from "fs";
import * as mkdirp from "mkdirp";

export const ensureDirIsEmpty = (path: string) => {
  if (fs.existsSync(path)) {
    fs.rmSync(path, { recursive: true, force: true });
  }

  mkdirp.sync(path);
  return path;
};
