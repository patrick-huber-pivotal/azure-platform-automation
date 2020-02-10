#!/bin/bash
CF_MGMT_CLIENT_ID=$(credhub get -n /concourse/main/cf-mgmt -q -k username) 
CF_MGMT_CLIENT_SECRET=$(credhub get -n /concourse/main/cf-mgmt -q -k password)
cf-mgmt export-config \
  user-id=cf-mgmt \
  --system-domain=sys.dell.azure.pivotal.rocks \
  --user-id=${CF_MGMT_CLIENT_ID} \
  --client-secret=${CF_MGMT_CLIENT_SECRET} \
  --excluded-org=system
  
