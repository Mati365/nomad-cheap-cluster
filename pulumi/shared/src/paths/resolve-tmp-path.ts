import * as path from "path";
import * as process from "process";

export const resolveTmpPath = (file: string = "") =>
  path.resolve(process.cwd(), "./tmp", file);
