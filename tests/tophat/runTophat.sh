#!/bin/bash

#aws s3 synch s3://moduleiotest/xchip/gpdev/gpftp/pub/module_support_files/bowtie2/index/by_genome/Homo_sapiens_hg19_UCSC /xchip/gpdev/gpftp/pub/module_support_files/bowtie2/index/by_genome/Homo_sapiens_hg19_UCSC

TOPHATDIR=/bin/tophat-2.0.14.Linux_x86_64/
INDEXDIR=/xchip/gpdev/gpftp/pub/module_support_files/bowtie2/index/by_genome/Homo_sapiens_hg19_UCSC/
BOWTIEDIR=/bin/bowtie2-2.2.3/
SAMTOOLSDIR=/usr/bin/
TASKLIB=/Users/liefeld/GenePattern/gp_dev/docker/docker-tophat/tests/tophat/src/
ANNOT_DIR=/Users/liefeld/GenePattern/gp_dev/docker/docker-tophat/tests/tophat/indices/annotation


# perl $TASKLIB/tophat_wrapper.pl  --tophatDir  $TOPHATDIR  --samtoolsDir $SAMTOOLSDIR  --bowtieDir $BOWTIEDIR --libdir  $TASKLIB  --index $INDEXDIR  --pair1  $INPUT_FILE_DIRECTORIES/reads.pair.1.list.txt  --pair2  $INPUT_FILE_DIRECTORIES/reads.pair.2.list.txt  --mateDist  50  --mateStd  --readEditDist  --readGapLength  --oprefix  SRR1039508  --gtf  --transcriptomeIndex  /xchip/gpprod/servers/genepattern/jobResults/1470911/transcriptome_index  --juncs  --transcriptomeOnly  yes  --minALen  8  --maxSpliceM  0  --minILen  --maxILen  500000  --maxInsLen  3  --maxDelLen  3  --maxMHit  20  --readMis  2  --maxTHit  --fAnchorLen  20  --fReadMis  2  --fusion  --  --library-type  fr-unstranded  --no-coverage-search  -p  6

perl $TASKLIB/tophat_wrapper.pl --tophatDir $TOPHATDIR --samtoolsDir $SAMTOOLSDIR --bowtieDir $BOWTIEDIR --libdir $TASKLIB --index $INDEXDIR --pair1 --pair2 --mateDist 50 --mateStd --readEditDist --readGapLength --oprefix 1470911_null --gtf $ANNOT_DIR/Homo_sapiens_hg19_UCSC.gtf --transcriptomeIndex --juncs --transcriptomeOnly no --minALen 8 --maxSpliceM 0 --minILen --maxILen 500000 --maxInsLen 3 --maxDelLen 3 --maxMHit 20 --readMis 2 --maxTHit --fAnchorLen 20 --fReadMis 2 --fusion -- --no-coverage-search -p 6



