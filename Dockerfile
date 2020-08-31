FROM docker.elastic.co/elasticsearch/elasticsearch:7.4.2

WORKDIR /usr/share/elasticsearch
RUN bin/elasticsearch-plugin install analysis-nori