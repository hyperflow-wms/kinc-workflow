# OSG-KINC worklow -- HyperFlow port
Port of the [Pegasus OSG-KINC workflow](https://github.com/feltus/OSG-KINC) to HyperFlow. 

## Build and publish image
HyperFlow Docker image contains kinc binaries and HyperFlow job executor
- `make` -- build the container and push to Docker Hub
- `make container` -- build the container

## Generate workflow
To generate a workflow, run the following commands:
```
git clone https://github.com/hyperflow-wms/kinc-workflow
cd kinc-worklfow
./gen_workflow.sh [-c command_name] num_jobs
```
Where 
- `command_name` is the optional name of the command to be used in the output `workflow.json` (default is `{{function}}` -- a variable that can be set as [explained here](https://github.com/hyperflow-wms/hyperflow/wiki/Workflow-description-format#support-for-templates).
- `num_jobs` is the number of jobs to be generated in the workflow. The more jobs you set, the shorter they will be. Set at least `10000` for a reasonable run time of a single job. 

This will generate `workflow.josn` in the current directory. Note: the `gen_workflow.sh` script requires Docker.

## Running locally
The generated workflow can be run using the command:
```
. run.sh
```

## Running in a Kubernetes cluster

To run the workflow on a Kubernetes cluster, you can use the [HyperFlow-k8s-deployment project](https://github.com/hyperflow-wms/hyperflow-k8s-deployment). 
