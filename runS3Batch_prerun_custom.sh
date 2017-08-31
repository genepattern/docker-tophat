
##################################################
# MODIFICATION FOR  LOADING GENOME INDEX Directory FOR TOPHAT FROM S3
##################################################

indexDir=$(python /usr/local/bin/findIndex.py $@)
mkdir -p $indexDir

# mount pre-compiled libs from S3
echo "13. FOR TopHat customizations: Sync the Genome Index to the container,   aws s3 sync $S3_ROOT$indexDir $indexDir --quiet"
aws s3 sync $S3_ROOT$indexDir $indexDir --quiet

echo 14. ls on index follows,  ls /xchip/gpdev/gpftp/pub/module_support_files/bowtie2/index/by_genome/Homo_sapiens_hg19_UCSC/ 
ls -lrt /xchip/gpdev/gpftp/pub/module_support_files/bowtie2/index/by_genome/Homo_sapiens_hg19_UCSC/




