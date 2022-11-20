import * as path from "path";
import { tar } from "zip-a-folder";
import { ensureTmpDirPresent } from "@infra/shared";

type TmpArchiveConfig = {
  srcFolder: string;
  destFileName: string;
};

export const createTmpArchive = async ({
  srcFolder,
  destFileName,
}: TmpArchiveConfig) => {
  const fileName = `${destFileName}.tar`;
  const archivePath = path.join(ensureTmpDirPresent("tmp-archive"), fileName);

  await tar(srcFolder, archivePath);

  return {
    fileName,
    archivePath,
  };
};
