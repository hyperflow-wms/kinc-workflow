# OSG-KINC worklow -- HyperFlow port
Port of the Pegasus OSG-KINC workflow to HyperFlow. New in this repository:
- `Dockerfile` for the `kinc` command
- HyperFlow workflow generator script `gen_workflow.sh`

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

## Running in Kubernetes
...


# OSG-KINC

OSG-KINC is a Pegasus workflow that is configured to run on the Open Science Grid.  The workflow uses the Knowledge Independent Network Construction (KINC) software package to build a similarity matrix representing correlation analysis of all pairwise comparisons of genes/transcripts in a Gene Expression Matrix (GEM).  

This repository contains a pre-compiled kinc binary that is executable on the OSG resources requested by this workflow.  The user must provide a properly formatted GEM, and specify the number of jobs that the computation will be split into.  

## Open Science Grid / Execution Environment

The OSG-GEM workflow is designed to execute on the [Open Science Grid](https://www.opensciencegrid.org/) via the
[OSG Connect](https://osgconnect.net/) infrastructure. Access to the system can be requested on the 
[sign up page](https://osgconnect.net/signup). 

Once you have an account and have joined a project, login to the login02 submit node.
This node can be accessed by ssh:

        ssh username@login02.osgconnect.net

A workflow specific ssh key has to be created. This key is used for some of the data staging steps of the workflow. 

        $ mkdir -p ~/.ssh
        $ ssh-keygen -t rsa -b 2048 -f ~/.ssh/workflow
          (just hit enter when asked for a passphrase)
          
 
One you have the ~/.ssh/workflow.pub file, add it to your profile as described in https://support.opensciencegrid.org/support/solutions/articles/12000027675-generate-ssh-key-pair-and-add-the-public-key-to-your-account#step-2-add-the-public-ssh-key-to-login-node

## Input GEM Format

The workflow will automatically identify the dimensions of the input Gene Expression Matrix.  However, this matrix must be formatted as follows:

- Tab delimited text file
- No 'GeneID' string in header.  First value of header is a sample ID (it looks frameshifted, don't worry)

| Sample1 | Sample2 | Sample3 | Sample4 | Sample5 |         |
| ------- | ------- | ------- | ------- | ------- | ------- |
| Gene1 | 0.215 | 12.770 | 15.112 | 12.111 | 501.211 |    
| Gene2 | 0.111 | 10.265 | 50.555 | 200.331 | 423.221 |
| Gene3 | 0.212 | 0.472 | 12.223 | 111.121 | 456.778 |
| Gene4 | 0.543 | 0.778 | 23.421 | 224.431 | 333.421 |
| Gene5 | 0.321 | 0.783 | 44.431 | 353.765 | 334.431 | 

For this dataset, the kinc parameters would be identified as follows:

rows: 6

columns: 5 

Once the input GEM is formatted properly, it must be named with the '.txt' file extension and placed in the 'task-files' directory of the workflow.  

In addition, a compressed tar archive with the extension 'tar.gz' of this text file must be provided.  This can be generated using the following command, using 'test.txt' as an example:

    $ tar czf test.tar.gz test.txt
    
    
## Submitting the Test Workflow

An example GEM, 'Yeast-GEM.txt', is cloned in the task-files directory in this repository.  Please inspect this file to see an example of a properly formatted input file. The task-files directory also has the corresponding 'Yeast-GEM.tar.gz' file.  

Once the input files are placed in the task-files directory, the workflow can be submitted by executing the *submit* script, with one additional argument representing the number of jobs that you want to submit.  For example:

    $ ./submit 8000
    
This will submit the workflow, and split the computation into 1000 jobs.  This is the suggested number of jobs for submitting this test workflow.  
    
    
## Customizing the Workflow

In addition to properly formatting the input GEM, the user must specify an appropriate number of jobs.  The number of pairwise comparisons performed scales quickly with the number of rows in the matrix:

(n x (n - 1)) / 2, where n = the number of rows in the matrix.  

For example, a GEM containing 88,520 rows will result in over 3.9 billion comparisons being performed.  For a matrix of this size, with less than 500 samples,  we recommend submitting the workflow with 80,000 jobs.  

The number of columns (samples) also has a large affect on the computational time needed to run this workflow.  As a result, we have not yet determined a formula or algorithm that decides the optimum number of jobs for a given matrix.  However, please aim for less than 1 GB of output per job, and an average job runtime of less than 4 hours.  If you submit a workflow and none of the jobs are finishing within several hours, please resubmit with a larger number of jobs.    

The *kinc-wrapper* in the *tools* directory contains the parameters that are passed to the KINC software.  The user may modify this file to change clustering or correlation parameters.  In addition, the user may specify missing value fields (Default is NA).  Do not remove the --header parameter, as this will result in an incorrect identification of matrix dimensions.  

Once the input GEM.txt, and corresponding GEM.tar.gz file have been placed in the task-files directory, the user must delete the 'test.txt' and 'test.tar.gz' files before submitting the workflow.  To avoid confusion, the workflow will fail to submit if multiple input datasets are present in the task-files directory.  

## Monitoring the Workflow

Pegasus provides a set of commands to monitor the progress of the workflow.  

        $ pegasus-analyzer
        $ pegasus-status
        $ pegasus-statistics 

- *pegasus-analyzer* will identify failed jobs for troubleshooting.  
- *pegasus-statistics* will report workflow progress, presented as number of succesful, queued, and failed jobs
- *pegasus-statistics* will produce basic workflow statistics once it has completed.  Use the following command to generate a detailed breakdown of job statistics:

        $ pegasus-statistics -s all

To run these commands, the user must provide the full path to the workflow directory, or cd into this directory.  This directory is separate from where the workflow is submitted, and will be located on the /local-scratch filesystem:

/local-scratch/<user_id>/workflows/kinc-<workflow_id>/workflow/kinc-<workflow_id>

Here is an example of a full path to the workflow directory:

/local-scratch/wpoehlm/workflows/kinc-1489505008/workflow/kinc-1489505008

In the event that the workflow finishes with failed jobs, the failed jobs can be resubmitted with the following command:

        $ pegasus-run
        
## Workflow Output

Output will be temporarily stored on a scratch filesystem, and then copied onto the /local-scratch filesystem.  This output directory is present at the base of the workflow directory:

/local-scratch/<user_id>/workflows/kinc-<workflow_id>/outputs

for example:

/local-scratch/wpoehlm/workflows/kinc-1489505008/outputs


## Using iRODS as Workflow Staging Site

OSG-KINC may pull in an input dataset from a remote iRODS server, use iRODS as the workflow staging site, and transfer output files to the iRODS server.  To do so, the user must take the following steps:

* install the iRODS icommands on the submit host and any worker nodes
* create irods environment file: ~/.irods/irods_environment.json 

This file must have the following content:

    {
    "irods_host": "some.host.edu",
    "irods_port": 1247,
    "irods_user_name": "someuser",
    "irods_zone_name": "somezone",
    "irodsPassword" : "somesecretpassword"
    }

* provide an iRODS path to a compressed input file as a second argument for the sumit script.  For example:

      ./submit 1000 /myirodszone/home/user/test.tar.gz 















        
