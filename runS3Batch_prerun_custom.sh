

##################################################
# MODIFICATION FOR  LOADING GENOME FILE FOR TOPHAT FROM S3
##################################################

indexDir=$(python /usr/local/bin/findIndex.py $@)
echo "Index dir is in shell " $indexDir

# mount pre-compiled libs from S3
echo "FOR TopHat. 13 CUSTOMIZING: aws s3 sync $S3_ROOT$indexDir $indexDir --quiet"


