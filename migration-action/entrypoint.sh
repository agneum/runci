#!/bin/sh -l

JSON_DATA=$(jq -n -c \
  --arg owner "$INPUT_OWNER" \
  --arg repo "$INPUT_REPO" \
  --arg ref "$INPUT_REF" \
  --arg commands "$INPUT_COMMANDS" \
  --arg db_name "$INPUT_DBNAME" \
  --arg actor "$GITHUB_ACTOR" \
  --arg branch "${GITHUB_HEAD_REF:-${GITHUB_REF##*/}}" \
  --arg commit_sha "${INPUT_COMMIT_SHA}" \
  --arg commit "${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/commit/${INPUT_COMMIT_SHA}" \
  --arg request_link "${INPUT_PULL_REQUEST:-$INPUT_COMPARE}" \
  --arg migration_envs "$INPUT_MIGRATION_ENVS" \
  '{source: {owner: $owner, repo: $repo, ref: $ref, branch: $branch, commit_sha: $commit_sha, commit: $commit, request_link: $request_link}, actor: $actor, db_name: $db_name, commands: $commands | rtrimstr("\n") | split("\n"), migration_envs: $migration_envs | rtrimstr("\n") | split("\n")}')

echo $JSON_DATA

echo ${CI_ENDPOINT_MIGRATION}

response_code=$(curl --show-error --silent --location --request POST "${CI_ENDPOINT_MIGRATION}" --write-out "%{http_code}" \
--header "Verification-Token: ${SECRET_TOKEN}" \
--header 'Content-Type: application/json' \
--output response.json \
--data "${JSON_DATA}")

if [[ $response_code -ne 200 ]]; then
  echo "Invalid status code given: ${response_code}"
  exit 1
fi

response=$(cat response.json)

echo $response

status=$(jq '.session.result.status' response.json)
echo $status

clone_id=$(jq '.clone_id' response.json)
session_id=$(jq '.session.id' response.json)

echo ${CI_ENDPOINT_ARTIFACT}

cat response.json | jq -c '.session.artifacts[]' | while read object; do
    api_call $artifact $session_id $clone_id
done

function download_artifacts() {
    curl --show-error --silent "${CI_ENDPOINT_ARTIFACT}?artifact_type=$1&session_id=$2&clone_id=$3" --write-out "%{http_code}" \
         --header "Verification-Token: ${SECRET_TOKEN}" \
         --header 'Content-Type: application/json' \
         --output artifacts/$1

    echo "Artifact \"$1\" has been downloaded to the artifacts directory"
}
echo "::set-output name=response::$response"
