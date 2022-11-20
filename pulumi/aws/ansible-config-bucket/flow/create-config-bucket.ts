import * as aws from "@pulumi/aws";

export const createConfigBucket = () => {
  const bucketName = "upolujksiazke-config-bucket";
  const bucket = new aws.s3.Bucket(bucketName, {
    acl: "private",
    bucket: bucketName,
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
