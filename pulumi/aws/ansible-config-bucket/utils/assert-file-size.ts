import * as fs from "fs";

export const assertFileSize = (expectedSizeKb: number, path: string) => {
  const stat = fs.statSync(path);

  if (stat.size > expectedSizeKb * 1024) {
    throw new Error("Too large file!");
  }
};
