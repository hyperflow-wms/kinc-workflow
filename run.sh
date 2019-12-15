export HF_VAR_WORKER_CONTAINER="hyperflowwms/kinc-worker"
export HF_VAR_WORK_DIR="$PWD/input"
export HF_VAR_function="redisCommand"
hflow run .
