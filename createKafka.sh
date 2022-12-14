#!/bin/bash


function confirm_login() {
  echo "Are you already logged in using rhoas login? "
  select answer in "Yes" "No"; do
      case $answer in
          Yes) echo "Logged in...";
               break;;
          No) echo "Please login first"
              exit 1;;
      esac
  done
}

function create_instance() {
    source .env

    rhoas kafka create --name ${INSTANCE_NAME} --wait
    rhoas context set-kafka --name ${INSTANCE_NAME}
    rhoas generate-config --type json --overwrite --output-file ${KAFKA_INSTANCE_CONFIG_JSON}

    for topic in items customers orders
    do
        rhoas kafka topic create --name $topic
    done

    rhoas service-account create --output-file=./${SA_CRED_JSON} --file-format json --overwrite --short-description=${SA_NAME}
    CLIENT_ID=`cat sa-credentials.json | jq -r .clientID`

    for topic in items customers orders
    do
        rhoas kafka acl grant-access --consumer --producer \
            --service-account ${CLIENT_ID} --topic-prefix ${topic}  --group "${topic}${KAFKA_CONSUMER_GROUP_SUFFIX}" -y
    done
}


confirm_login
create_instance
