#!/bin/bash

export VARIABLE_NAME="$1" && echo "$VARIABLE_NAME"
export VARIABLE_TYPE="$2" && echo "$VARIABLE_TYPE"
export LOCAL_VAR_FILE_NAME="$3" && echo "$LOCAL_VAR_FILE_NAME"
export PROTECTED="$4" && echo "$PROTECTED"
export MASKED="$5" && echo "$MASKED"
export ENVIRONMENT_SCOPE=$(echo $6)
export GITLAB_API_RW_PRIVATE_TOKEN="$7" && echo "$GITLAB_API_RW_PRIVATE_TOKEN"
export CI_API_V4_URL="$8" && echo "$CI_API_V4_URL"
export PROJECT_ID="$9" && echo "$PROJECT_ID"


if [[ ! "$(curl -s -XGET -H PRIVATE-TOKEN: $GITLAB_API_RW_PRIVATE_TOKEN $CI_API_V4_URL/projects/$PROJECT_ID/variables/$VARIABLE_NAME)" =~ "404 Variable Not Found" ]];
then
  echo "Variable $VARIABLE_NAME exists! Updating!"
  curl -s -XPUT -H "PRIVATE-TOKEN: $GITLAB_API_RW_PRIVATE_TOKEN" "$CI_API_V4_URL/projects/$PROJECT_ID/variables/$VARIABLE_NAME" \
    --form value="$(cat $CI_PROJECT_DIR/eks/$APP/$LOCAL_VAR_FILE_NAME)" \
    --form variable_type="$VARIABLE_TYPE" \
    --form protected="$PROTECTED" \
    --form masked="$MASKED" \
    --form environment_scope=$ENVIRONMENT_SCOPE
else
  echo "Variable $VARIABLE_NAME does not exist! Creating!"
  curl -s -XPOST -H "PRIVATE-TOKEN: $GITLAB_API_RW_PRIVATE_TOKEN" "$CI_API_V4_URL/projects/$PROJECT_ID/variables" \
    --form key="$VARIABLE_NAME" \
    --form value="$(cat $CI_PROJECT_DIR/eks/$APP/$LOCAL_VAR_FILE_NAME)" \
    --form variable_type="$VARIABLE_TYPE" \
    --form protected="$PROTECTED" \
    --form masked="$MASKED" \
    --form environment_scope=$ENVIRONMENT_SCOPE
fi
