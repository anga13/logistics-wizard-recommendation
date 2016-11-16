#!/bin/bash
# Called by the pipeline from the checkout directory
if [ -z ${OPENWHISK_AUTH} ]; then
  echo Skipping OpenWhisk deployment as no OpenWhisk auth key is configured
  exit 0
fi

# Get the OpenWhisk CLI
mkdir ~/wsk
curl https://openwhisk.ng.bluemix.net/cli/go/download/linux/amd64/wsk > ~/wsk/wsk
chmod +x ~/wsk/wsk
export PATH=$PATH:~/wsk

# Configure the OpenWhisk CLI
wsk property set --apihost openwhisk.ng.bluemix.net --auth "${OPENWHISK_AUTH}" --namespace "${CF_ORG}_${CF_SPACE}"

# inject the location of the controller service
domain=".mybluemix.net"
case "${REGION_ID}" in
  ibm:yp:eu-gb)
    domain=".eu-gb.mybluemix.net"
  ;;
  ibm:yp:au-syd)
  domain=".au-syd.mybluemix.net"
  ;;
esac
export CONTROLLER_SERVICE=https://$CONTROLLER_SERVICE_APP_NAME$domain

# Deploy the OpenWhisk triggers/actions/rules
./deploy.sh --uninstall
./deploy.sh --install