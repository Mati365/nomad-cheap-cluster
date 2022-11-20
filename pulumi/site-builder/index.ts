import { createConfigCiUser, createConfigBucket } from "./flow";

const { bucket } = createConfigBucket();
const { user } = createConfigCiUser({ configBucket: bucket });

export const bucketId = bucket.id;
export const userId = user.id;
