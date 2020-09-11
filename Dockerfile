FROM docker.elastic.co/elasticsearch/elasticsearch:7.9.1

WORKDIR /usr/share/elasticsearch

RUN bin/elasticsearch-plugin install analysis-nori

