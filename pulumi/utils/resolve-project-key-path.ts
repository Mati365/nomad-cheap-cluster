import * as path from "path";
import { PROJECT_PATH } from "../constants";

export const resolveProjectKeyPath = (filePath: string) =>
  path.resolve(PROJECT_PATH, "keys", filePath);
