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

function delete_instance() {
    source .env

    rhoas kafka delete --name ${INSTANCE_NAME} -y
    CLIENT_ID=$(grep clientID ./sa-credentials.json | cut -d ":" -f2 | tr -d '", ')
    rhoas service-account delete --id ${CLIENT_ID} -y
}

confirm_login
delete_instance

