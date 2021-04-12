#!/bin/bash
# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Make sure this is run via source or .
if ! (return 0 2>/dev/null); then
  echo "ERROR: Usage: 'source oci-cli-cs-key-auth.sh"
  exit
fi

# unset OCI_CLI variables
unset OCI_CLI_CONFIG_FILE
unset OCI_CLI_PROFILE
unset OCI_AUTH
unset OCI_CLI_CLOUD_SHELL
unset OCI_CLI_AUTH
unset OCI_CONFIG_PROFILE
unset OCI_CONFIG_FILE
unset OCI_AUTH_TYPE
unset OCI_DELEGATION_TOKEN_FILE

# Create Keys
if ! test -f ~/.oci/oci_api_key.pem; then
  oci setup keys --overwrite --passphrase "" 
fi

# Push Public Key to OCI
while ! state_done PUSH_OCI_CLI_KEY; do
  if ! oci iam user api-key upload --user-id $(state_get USER_OCID) --key-file ~/.oci/oci_api_key_public.pem 2>$GRABDISH_LOG/err; then
    if grep KeyAlreadyExists $GRABDISH_LOG/err >/dev/null; then 
      # The key already exists
      state_set_done PUSH_OCI_CLI_KEY
    else
      echo 'ERROR: Failed to upload key.  Please delete old keys to make way for the new key and I will try again in 10 seconds'
      sleep 10
    fi
  else
    state_set_done PUSH_OCI_CLI_KEY
  fi
done

# Get fingerprint
FINGERPRINT=`openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c | awk '{print $2}'`

# Create config file
umask 177
cat >~/.oci/config <<!
[DEFAULT]
user=$(state_get USER_OCID)
fingerprint=$FINGERPRINT
key_file=~/.oci/oci_api_key.pem
tenancy=${OCI_TENANCY}
region=${OCI_REGION}
!
umask 22

