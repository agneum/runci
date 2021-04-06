#!/bin/sh -l

echo "Owner $1"

JSON_DATA=$(jq -n \
  --arg owner "$INPUT_OWNER" \
  --arg repo "$INPUT_REPO" \
  --arg ref "$INPUT_REF" \
  '{owner: $owner, repo: $repo, ref: $ref}')

echo "${INPUT_COMMANDS}"

curl --location --request POST "${CI_ENDPOINT}" \
--header 'Authorization-Token: secret_token' \
--header 'Content-Type: application/json' \
--data-raw "${JSON_DATA}"

status="OK"
echo "::set-output name=status::$status"
