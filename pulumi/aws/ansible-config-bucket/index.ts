import {
  createConfigCiUser,
  createConfigBucket,
  createKeysBucketFile,
} from "./flow";

const { bucket: configBucket } = createConfigBucket();
const { user } = createConfigCiUser({ configBucket });

createKeysBucketFile({ configBucket });

export const bucketId = configBucket.id;
export const userId = user.id;
