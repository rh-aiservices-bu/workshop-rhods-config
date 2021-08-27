# Workshop RHODS Configuration

To set workshop configuration options:
```shell
./setup.sh
```
```shell
ADMIN_USERS='admin1 admin2' IDLE_CULLER_TIMEOUT=3600 AUTOSCALE=true ./setup.sh

```

To undo workshop configuration options:
```shell
./cleanup.sh
```

## RHODS Configuration Settings
This configures the following

### User Configuration
Updates configmap `rhods-groups-config` in `redhat-ods-applications` to allow all authenticated cluster users to use RHODS.  Also creates group `rhods-admins` for admin access with people listed in `ADMIN_USERS` environment variable.

```shell
ADMIN_USERS='admin1 admin2' ./setup.sh 
```

### Dashboard Configuration
Implements the following by creating [odh-dashboard-config.yaml](/odh-dashboard-config.yaml) in the namespace `redhat-ods-applications`.
- Disables ISV Explore Information
- Disables ISV Enablement
- Disables Support Link

### Terminate Idle Notebooks
Implements the following by creating [JupyterHub Idle Culler DeploymentConfig](/jupyterhub-idle-culler.yaml) in the namespace `redhat-ods-applications`.  The culler kills any idle pods after a certain time in seconds set by `IDLE_CULLER_TIMEOUT`, but defaulting to 24 hours.

```shell
IDLE_CULLER_TIMEOUT=86400 ./setup.sh
```

### Update Notebook Size Options
- Update default notebook size [jupyter-singleuser-profiles-patch.yaml](/jupyter-singleuser-profiles-patch.yaml) 
  Sets the Default to 2 CPU and 8Gi RAM by patching the configmap `jupyter-singleuser-profiles` in `redhat-ods-applications`
- Update other notebook sizes. [rhods-jupyterhub-sizes-patch.yaml](/rhods-jupyterhub-sizes-patch.yaml)
  Sets the only choice to be Small with 2 CPU and 8Gi RAM by patching the configmap `rhods-jupyterhub-sizes` in `redhat-ods-applications`


### Buffer for Autoscaling Clusters
If autoscaling, you may wish to reduce the chances a user will be waiting for a new compute node to spin up while trying to start a notebook.  Adds a deployment with pods that reserve cpu and memory, but have a low scheduling priority (-5).  These pods should get evicted to make room when a notebook that needs the resources gets scheduled.  

Optional for autoscaling clusters. Enable by setting `AUTOSCALE` environment variable, otherwise defaults to not deploy.

```shell
AUTOSCALE=true ./setup.sh
```