import * as aws from "@pulumi/aws";

export const createConfigBucket = () => {
  const bucket = new aws.s3.Bucket("upolujksiazke-config-bucket", {
    acl: "private",
  });

  const accessBlock = new aws.s3.BucketPublicAccessBlock(
    "upolujksiazke-config-bucket-access-block",
    {
      bucket: bucket.id,
      blockPublicAcls: true,
      blockPublicPolicy: true,
      ignorePublicAcls: true,
      restrictPublicBuckets: true,
    }
  );

  return {
    bucket,
    accessBlock,
  };
};
