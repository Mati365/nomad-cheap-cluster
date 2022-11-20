import * as path from "path";
import { PROJECT_PATH } from "../constants";

export const resolveProjectAnsiblePath = (filePath: string = '') =>
  path.resolve(PROJECT_PATH, "ansible", filePath);

export const resolveProjectKeysPath = (filePath: string = '') =>
  path.resolve(PROJECT_PATH, "keys", filePath);
