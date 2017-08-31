import sys
# look at the executable, find the tophat call in it and then find the index so we can mount it via s3
#
# the interface is such that this is called with the smae args as runS3OnBatch.sh, the main entry point
# for the container.  It is given 5 args, of which the 5th is the executable which for GenePattern
# should always be a file containing the 'real' module command line.
#
# we then read the tophat command line from that file and find the value for the index directory which
# comes after --index.
#
# This is normally a directory on the genepattern headnode's file system that before aws batch
# would be visible to the compute node.  Here we will get the path so that we can then aws sync that
# directory into the container for its use 

indexDir = ''
with open(sys.argv[5]) as f:
    for line in f:
        linetokens = line.split()
        if (len(linetokens) <= 2):
            continue
        if (not linetokens[0].startswith("#")):
             #print(linetokens)
             if (linetokens[1].endswith('tophat_wrapper.pl')):
	        #found the tophat call line
                for index, arg in enumerate(linetokens):
                    if (arg.startswith('--index')):
                        indexDir = linetokens[index+1]
                        break 
print( indexDir)


