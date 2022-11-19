import * as path from "path";

export const resolveDistPath = (file: string = "") =>
  path.resolve(__dirname, "../dist", file);
