#! /bin/bash

echo "Make sure you are logged in as cluster admin"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#oc process -f "${DIR}/jupyterhub-idle-culler.yaml" | oc delete -n redhat-ods-applications -f -
#
#oc delete configmap odh-dashboard-config -n redhat-ods-applications
#oc rollout restart deployment/odh-dashboard -n redhat-ods-applications
#
#oc delete group rhods-admins
#oc patch configmap rhods-groups-config -n redhat-ods-applications --patch-file "${DIR}/rhods-groups-config-original-patch.yaml"
#oc patch configmap jupyter-singleuser-profiles -n redhat-ods-applications --patch-file "${DIR}/jupyter-singleuser-profiles-original-patch.yaml"
#oc patch configmap rhods-jupyterhub-sizes -n redhat-ods-applications --patch-file "${DIR}/rhods-jupyterhub-sizes-original-patch.yaml"
#oc rollout latest deploymentconfig/jupyterhub -n redhat-ods-applications
#
#
#oc process -n rhods-notebooks -f "${DIR}/autoscaling-buffer.yaml" | oc apply -f -


oc get deployment -n rhods-notebooks autoscaling-buffer > /dev/null 2>&1 && RETURNCODE=$? || RETURNCODE=$?
if [ $RETURNCODE -eq 0 ]; then
    oc delete -n rhods-notebooks deployment autoscaling-buffer
fi

oc get priorityclass autoscaling-buffer > /dev/null 2>&1 && RETURNCODE=$? || RETURNCODE=$?
if [ $RETURNCODE -eq 0 ]; then
    oc delete priorityclass autoscaling-buffer
fi