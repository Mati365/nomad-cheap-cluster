import * as aws from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";
import { Bucket } from "@pulumi/aws/s3";

import { resolveProjectKeysPath } from "@infra/shared";
import { assertFileSize, createTmpArchive } from "../utils";

type KeysBucketFileAttrs = {
  configBucket: Bucket;
};

export const createKeysBucketFile = ({ configBucket }: KeysBucketFileAttrs) => {
  const archive = createTmpArchive({
    srcFolder: resolveProjectKeysPath(),
    destFileName: "ansible-keys",
  });

  return pulumi.all([archive]).apply(
    ([{ archivePath, fileName }]) => {
      assertFileSize(/* 1MB */ 1024, archivePath);

      return new aws.s3.BucketObject(fileName, {
        bucket: configBucket,
        source: new pulumi.asset.FileAsset(archivePath),
      });
    },
  );
};
