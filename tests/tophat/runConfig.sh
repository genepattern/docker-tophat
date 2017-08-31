#!/bin/bash

TOPHATDIR=/bin/tophat-2.0.14.Linux_x86_64/
INDEXDIR=/xchip/gpdev/gpftp/pub/module_support_files/bowtie2/index/by_genome/Homo_sapiens_hg19_UCSC/
BOWTIEDIR=/bin/bowtie2-2.2.3/
SAMTOOLSDIR=/usr/bin/
INPUT_FILE_DIRECTORIES=$PWD/data


TASKLIB=$PWD/src/

COMMAND_LINE="perl $TASKLIB/tophat_wrapper.pl --tophatDir $TOPHATDIR --samtoolsDir $SAMTOOLSDIR --bowtieDir $BOWTIEDIR --libdir $TASKLIB --index $INDEXDIR --pair1 --pair2 --mateDist 50 --mateStd --readEditDist --readGapLength --oprefix 1470911_null --gtf $INPUT_FILE_DIRECTORIES/Homo_sapiens_hg19_UCSC.gtf --transcriptomeIndex --juncs --transcriptomeOnly no --minALen 8 --maxSpliceM 0 --minILen --maxILen 500000 --maxInsLen 3 --maxDelLen 3 --maxMHit 20 --readMis 2 --maxTHit --fAnchorLen 20 --fReadMis 2 --fusion -- --no-coverage-search -p 2"



CONTAINER_OVERRIDE_MEMORY=3100
JOB_DEFINITION_NAME="Tophat"
JOB_ID=TOPHAT_$1
JOB_QUEUE=TedTest
S3_ROOT=s3://moduleiotest
WORKING_DIR=$PWD/job_52345

DOCKER_CONTAINER=genepattern/docker-tophat


