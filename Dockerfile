FROM docker.elastic.co/elasticsearch/elasticsearch:7.9.1

WORKDIR /usr/share/elasticsearch

COPY ./esdata /usr/share/elasticsearch

RUN bin/elasticsearch-plugin install analysis-nori

ENV discovery.type single-node
ENV ES_JAVA_OPTS "-Xms512m -Xmx512m"
ENV http.cors.enabled "true"
ENV http.cors.allow-origin "*"
ENV cluster.name "ics-cluster"
ENV node.name "es-node01"

ADD ./esdata /usr/share/elasticsearch/data
RUN chmod -R 777 /usr/share/elasticsearch/data

EXPOSE 9200
EXPOSE 9300