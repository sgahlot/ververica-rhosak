#!/bin/sh

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

function check_status() {
    source .env
    rhoas status
    rhoas kafka describe --name ${INSTANCE_NAME}
}

confirm_login
check_status
