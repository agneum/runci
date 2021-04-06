#!/bin/sh -l

JSON_DATA=$(jq -n \
  --arg owner "$INPUT_OWNER" \
  --arg repo "$INPUT_REPO" \
  --arg ref "$INPUT_REF" \
  --arg commands "$INPUT_COMMANDS" \
  '{owner: $owner, repo: $repo, ref: $ref, commands: $commands | rtrimstr("\n") | split("\n")}')

echo $JSON_DATA

curl --location --request POST "${CI_ENDPOINT}" \
--header 'Authorization-Token: "${SECRET_TOKEN}"' \
--header 'Content-Type: application/json' \
--data-raw "${JSON_DATA}"

status="OK"
echo "::set-output name=status::$status"
