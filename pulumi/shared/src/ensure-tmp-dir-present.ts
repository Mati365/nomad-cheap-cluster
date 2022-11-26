import { ensureDirIsEmpty } from "./ensure-dir-is-empty";
import { resolveTmpPath } from "./paths/resolve-tmp-path";

export const ensureTmpDirPresent = (dir: string) => ensureDirIsEmpty(resolveTmpPath(dir));
