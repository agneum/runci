#!/bin/sh -l

JSON_DATA=$(jq -n -c \
  --arg owner "$INPUT_OWNER" \
  --arg repo "$INPUT_REPO" \
  --arg ref "$INPUT_REF" \
  --arg commands "$INPUT_COMMANDS" \
  --arg db_name "$INPUT_DBNAME" \
  --arg actor "$GITHUB_ACTOR" \
  --arg branch "${GITHUB_REF##*/}" \
  --arg diff $INPUT_DIFF \
  --arg migration_envs "$INPUT_MIGRATION_ENVS" \
  '{source: {owner: $owner, repo: $repo, ref: $ref, branch: $branch, diff: $diff}, actor: $actor, db_name: $db_name, commands: $commands | rtrimstr("\n") | split("\n"), migration_envs: $migration_envs | rtrimstr("\n") | split("\n")}')

echo $JSON_DATA

echo $INPUT_DIFF
echo $GITHUB_HEAD_REF
echo ${GITHUB_REF##*/}

env

response_code=$(curl --show-error --silent --location --request POST "${CI_ENDPOINT}" --write-out "%{http_code}" \
--header "Verification-Token: ${SECRET_TOKEN}" \
--header 'Content-Type: application/json' \
--output response.json \
--data "${JSON_DATA}")

if [[ $response_code -ne 200 ]]; then
  echo "Invalid status code given: ${response_code}"
  exit 1
fi

response=$(cat response.json)

echo "::set-output name=response::$response"
