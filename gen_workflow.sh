#!/bin/bash

# Usage: gen_workflow.sh [-c command_name] num_jobs
#
# command_name = the name of the command to be used in the output
#                workflow.json
#
# num_jobs = the number of jobs to be generated in the workflow
#

if [ $# -eq 0 ] ; then
	echo
	echo "Usage: gen_workflow.sh [-c command_name] num_jobs"
	echo
	exit 1
fi

cmdname=""
if [ $1 = "-c" ] ; then
	cmdname="-c $2"
	shift 
	shift 
fi

export RUN_ID=kinc-`date +'%s'`
RUN_DIR=$PWD
JOB_COUNT=$1

docker run -v $PWD:/wfdir hyperflowwms/hflow-pegasus $cmdname $RUN_ID $RUN_DIR $JOB_COUNT

