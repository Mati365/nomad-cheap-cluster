import * as aws from "@pulumi/aws";
import { Bucket } from "@pulumi/aws/s3";

type CiConfigUserAttrs = {
  configBucket: Bucket;
};

export const createConfigCiUser = ({ configBucket }: CiConfigUserAttrs) => {
  const user = new aws.iam.User("ci");

  const accessKey = new aws.iam.AccessKey("ci-user", {
    user: user.name,
  });

  const policy = new aws.iam.UserPolicy("ci-policy", {
    user: user.name,
    policy: configBucket.id.apply((id) =>
      JSON.stringify({
        Version: "2012-10-17",
        Statement: [
          {
            Effect: "Allow",
            Action: ["s3:GetBucketLocation", "s3:ListAllMyBuckets"],
            Resource: "arn:aws:s3:::*",
          },
          {
            Effect: "Allow",
            Action: ["s3:GetObject", "s3:GetObjectVersion"],
            Resource: [`arn:aws:s3:::${id}`, `arn:aws:s3:::${id}/*`],
          },
        ],
      })
    ),
  });

  return {
    user,
    accessKey,
    policy,
  };
};
