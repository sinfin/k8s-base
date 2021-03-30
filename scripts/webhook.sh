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
    \"text\": \"Project *${CI_PROJECT_NAME}* run job *${CI_JOB_NAME}* on *${CI_COMMIT_REF_NAME}* by ${GITLAB_USER_LOGIN} finished *$(echo $color | tr '[:lower:]' '[:upper:]')*\",
    \"attachments\": [
        {\"color\": \"${color}\",
         \"fallback\": \"Job: <${CI_PROJECT_URL}/-/jobs/${CI_JOB_ID}|${CI_JOB_ID}>, Commit: <${CI_PROJECT_URL}/-/commit/${CI_COMMIT_SHA}|${CI_COMMIT_SHORT_SHA}>\",
         \"fields\": [
            { \"title\":\"Job (${CI_JOB_NAME})\", \"value\": \"<${CI_PROJECT_URL}/-/jobs/${CI_JOB_ID}|${CI_JOB_ID}>\" },
            { \"title\":\"Commit (${CI_COMMIT_REF_NAME})\", \"value\": \"<${CI_PROJECT_URL}/-/commit/${CI_COMMIT_SHA}|${CI_COMMIT_SHORT_SHA}>\" },
            { \"title\":\"Message\", \"value\": \"${CI_COMMIT_TITLE}\" }
           ]
        }
    ]
}" $SLACK_WEBHOOK > /dev/null || true
