import * as path from "path";
import * as process from "process";

export const resolveDistPath = (file: string = "") =>
  path.resolve(process.cwd(), "./dist", file);
