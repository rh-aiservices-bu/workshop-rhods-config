#! /bin/bash

echo "Make sure you are logged in as cluster admin"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

IDLE_CULLER_TIMEOUT=${IDLE_CULLER_TIMEOUT:-'86400'}
oc process -n redhat-ods-applications -f "${DIR}/jupyterhub-idle-culler.yaml" \
  -p IDLE_CULLER_TIMEOUT="${IDLE_CULLER_TIMEOUT}" \
  | oc apply -n redhat-ods-applications -f -

oc apply -n redhat-ods-applications -f "${DIR}/odh-dashboard-config.yaml"
oc rollout restart deployment/odh-dashboard -n redhat-ods-applications

oc adm groups new rhods-admins ${ADMIN_USERS} || echo "rhods-admins group already exists"
oc patch configmap rhods-groups-config -n redhat-ods-applications --patch-file "${DIR}/rhods-groups-config-patch.yaml"

oc patch configmap jupyter-singleuser-profiles -n redhat-ods-applications --patch-file "${DIR}/jupyter-singleuser-profiles-patch.yaml"
oc patch configmap rhods-jupyterhub-sizes -n redhat-ods-applications --patch-file "${DIR}/rhods-jupyterhub-sizes-patch.yaml"

oc rollout latest deploymentconfig/jupyterhub -n redhat-ods-applications

if [ -n "${AUTOSCALE}" ]
then
  AUTOSCALER_REPLICAS=${AUTOSCALER_REPLICAS:-'4'}
  AUTOSCALER_CPU=${AUTOSCALER_CPU:-'4'}
  AUTOSCALER_MEMORY=${AUTOSCALER_MEMORY:-'16Gi'}
  oc process -n rhods-notebooks -f "${DIR}/autoscaling-buffer.yaml" | oc apply -n rhods-notebooks -f -
fi

