#!/usr/bin/env bash

set -e

FUNCTION_NAME="switchbot-api-state-switch"
ZIP_FILE_NAME="deploy.zip"
export AWS_DEFAULT_REGION="ap-northeast-1"

# export AWS_ACCESS_KEY_ID=""
# export AWS_SECRET_ACCESS_KEY=""
# export AWS_SESSION_TOKEN=""


npx esbuild index.ts --bundle --platform=node \
    --target=node22 --outfile=dist/index.js \
    --minify \
    --tsconfig=tsconfig.json

zip -r deploy.zip dist/*

aws lambda update-function-code \
  --function-name "${FUNCTION_NAME}" \
  --zip-file "fileb://${ZIP_FILE_NAME}"
