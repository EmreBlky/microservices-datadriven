#!/bin/bash
## Copyright (c) 2021 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/


# See docs/Deploy.md for details
kubectl delete deployment banka-springboot -n msdataworkshop
kubectl delete deployment bankb-springboot -n msdataworkshop
