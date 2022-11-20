import { ensureDirIsEmpty } from "../ensure-dir-is-empty";
import { resolveTmpPath } from "./resolve-tmp-path";

export const ensureTmpDirPresent = (dir: string) => ensureDirIsEmpty(resolveTmpPath(dir));
