#!/bin/sh

url="${SLACK_WEBHOOK}"
username='Gitlab builder'

to="${SLACK_WEBHOOK_CHANNEL}"

emoji=':gitlab:'

color="$1"

curl --silent -X POST -H 'Content-type: application/json' \
  -d \
"{  \"channel\": \"${to}\",
    \"username\": \"${CI_PROJECT_NAME}\",
    \"icon_emoji\": \"${emoji}\",
    \"text\": \"Gitlab ${CI_PROJECT_NAME} job ${CI_JOB_NAME} by $GITLAB_USER_LOGIN finished\",
    \"attachments\": [
        {\"color\": \"${color}\", \"text\": \"Job ${CI_JOB_NAME} finished with $(echo $color | tr '[:lower:]' '[:upper:]'), link: <${CI_PROJECT_URL}/-/jobs/${CI_JOB_ID}>\"}
    ]
}" $SLACK_WEBHOOK > /dev/null || true
