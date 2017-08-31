#!/bin/sh
#
# custom runLocal.sh due to custom mounts that are handles on s3 bu
# the customization script
#
. runConfig.sh

: ${STDOUT_FILENAME=stdout.txt}
: ${STDERR_FILENAME=stderr.txt}
: ${GP_METADATA_DIR=$WORKING_DIR/.gp_metadata}
: ${EXITCODE_FILENAME=$GP_METADATA_DIR/exit_code.txt}
: ${S3_ROOT=s3://moduleiotest}

# Make the input file directory since we need to put the script to execute in it
cd $TEST_ROOT
mkdir -p $WORKING_DIR
mkdir -p $GP_METADATA_DIR

EXEC_SHELL=$GP_METADATA_DIR/local_exec.sh
echo "#!/bin/bash\n" > $EXEC_SHELL
echo $COMMAND_LINE >>$EXEC_SHELL
echo "\n " >>$EXEC_SHELL
chmod a+x $EXEC_SHELL


REMOTE_COMMAND="/usr/local/bin/runLocal.sh $TASKLIB $INPUT_FILE_DIRECTORIES $S3_ROOT $WORKING_DIR $EXEC_SHELL"

echo "Container will execute $REMOTE_COMMAND  <EOM>\n"


outer_INDEXDIR=/Users/liefeld/GenePattern/gp_dev/docker/docker-tophat/tests/tophat/indices
container_INDEXDIR=/xchip/gpdev/gpftp/pub/module_support_files/bowtie2/index/by_genome/

#docker run -v $outer_INDEXDIR:$container_INDEXDIR -v $SRCDIR:$SRCDIR -it genepattern/docker-tophat bash


docker run -e GP_METADATA_DIR="$GP_METADATA_DIR" -e STDOUT_FILENAME=$STDOUT_FILENAME -e STDERR_FILENAME=$STDERR_FILENAME -v $outer_INDEXDIR:$container_INDEXDIR -v $GP_METADATA_DIR:$GP_METADATA_DIR -v $TASKLIB:$TASKLIB -v $INPUT_FILE_DIRECTORIES:$INPUT_FILE_DIRECTORIES -v $WORKING_DIR:$WORKING_DIR  $DOCKER_CONTAINER $REMOTE_COMMAND

