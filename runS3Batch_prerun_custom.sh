

##################################################
# MODIFICATION FOR  LOADING GENOME FILE FOR TOPHAT FROM S3
##################################################
# mount pre-compiled libs from S3
echo "FOR R3. 13 CUSTOMIZING: aws s3 sync $S3_ROOT$R_LIBS_S3 $R_LIBS --quiet"

#time {
    #command block that takes time to complete...
    #........
#    aws s3 sync $S3_ROOT$R_LIBS_S3 $R_LIBS --quiet
#}


#aws s3 sync $S3_ROOT$R_LIBS_S3 $R_LIBS --quiet




