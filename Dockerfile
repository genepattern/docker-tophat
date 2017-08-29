FROM genomicpariscentre/tophat2:2.0.14

#COPY common/container_scripts/runS3OnBatch.sh /usr/local/bin/runS3OnBatch.sh
#COPY common/container_scripts/runLocal.sh /usr/local/bin/runLocal.sh

RUN  mkdir /build

RUN apt-get update && apt-get upgrade --yes && \
    apt-get install curl --yes && \
    apt-get install build-essential --yes && \
    apt-get install python-dev --yes && \
    curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py 

RUN    pip install awscli 

RUN apt-get update && apt-get -y install samtools=0.1.19-1  && apt-get clean
    
#RUN chmod ugo+x /usr/local/bin/runS3OnBatch.sh
COPY Dockerfile /build/Dockerfile
COPY jobdef.json /build/jobdef.json
 

CMD ["/usr/local/bin/runS3OnBatch.sh" ]
