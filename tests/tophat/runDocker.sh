#!/bin/bash

SRCDIR=/Users/liefeld/GenePattern/gp_dev/docker/docker-tophat/tests/tophat
outer_INDEXDIR=/Users/liefeld/GenePattern/gp_dev/docker/docker-tophat/tests/tophat/indices
container_INDEXDIR=/xchip/gpdev/gpftp/pub/module_support_files/bowtie2/index/by_genome/
echo $SRCDIR

docker run -v $outer_INDEXDIR:$container_INDEXDIR -v $SRCDIR:$SRCDIR -it genepattern/docker-tophat bash

