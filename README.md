# Elasticsearch (ES) 학습하기

- [x] 환경은 docker 로 구성 할 수 있다.
- [x] 플러그인을 설치 할 수 있다.
- [ ] bulk api 를 사용해서, 데이터를 insert 할 수 있다.
- [ ] 한글 형태소 분석기인, nori_tokenizer 를 사용 할 수 있다.
- [ ] 한글 사전을 커스터마이징 할 수 있다.

## 환경은 docker 로 구성 할 수 있다.

_docker-compose.yml_

```yml
# docker-compose version
version: "3.1"

# service
services:
  es: # service 이름은 es
    container_name: es # docker 가 관리 할 container 이름은 es.
    build:
      context: .
      dockerfile: ./Dockerfile # ./Dockerfile 로 빌드한다.
    environment: # 환경변수
      discovery.type: single-node # 클러스터 없이, 싱글 노드로 설정
    ports:
      - 9200:9200 # 외부 9200 -> 내부 9200 번 바인드
    volumes:
      - ./es/data:/usr/share/elasticsearch/data # 외부 볼륨과 연결
```

_Dockerfile_

```diff
+ FROM docker.elastic.co/elasticsearch/elasticsearch:7.4.2

+ WORKDIR /usr/share/elasticsearch
```

```
$ docker-compose up -d

Creating es ... done
```

```curl
curl -XGET http://localhost:9200?pretty

{
  "name" : "3f4c6984b25a",
  "cluster_name" : "docker-cluster",
  "cluster_uuid" : "1rPhJrYuRAaiT262VuFKtw",
  "version" : {
    "number" : "7.4.2",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "2f90bbf7b93631e52bafb59b3b049cb44ec25e96",
    "build_date" : "2019-10-28T20:40:44.881551Z",
    "build_snapshot" : false,
    "lucene_version" : "8.2.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

## 플러그인을 설치 할 수 있다.

한글 형태소 nori 설치

_Dockerfile_

```diff
FROM docker.elastic.co/elasticsearch/elasticsearch:7.4.2

WORKDIR /usr/share/elasticsearch
+ RUN bin/elasticsearch-plugin install analysis-nori
```

```bash
$ docker-compose restart
```

확인.

```curl
curl -XGET 'http://localhost:9200/_analyze?pretty' \
-H 'Content-Type: application/json' \
-d '{
  "tokenizer": "nori_tokenizer",
  "text": [
    "동해물과 백두산이"
  ]
}'

{
  "tokens" : [
    {
      "token" : "동해",
      "start_offset" : 0,
      "end_offset" : 2,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "물",
      "start_offset" : 2,
      "end_offset" : 3,
      "type" : "word",
      "position" : 1
    },
    {
      "token" : "과",
      "start_offset" : 3,
      "end_offset" : 4,
      "type" : "word",
      "position" : 2
    },
    {
      "token" : "백두",
      "start_offset" : 5,
      "end_offset" : 7,
      "type" : "word",
      "position" : 3
    },
    {
      "token" : "산",
      "start_offset" : 7,
      "end_offset" : 8,
      "type" : "word",
      "position" : 4
    },
    {
      "token" : "이",
      "start_offset" : 8,
      "end_offset" : 9,
      "type" : "word",
      "position" : 5
    }
  ]
}
```

## ISSUE

#### ElasticSearch cluster_block_exception

데이터를 추가 삭제하다보면, 가끔 `ElasticSearch cluster_block_exception` 이라고 뜨면서 인덱스가 `read-only` 로 잠기는 상태가 된다.

```curl
curl -XGET http://localhost:9200/addresses/_settings?pretty -H 'application/json'

{
    "addresses": {
        "settings": {
            "index": {
                "number_of_shards": "1",
                "blocks": {
                    "read_only_allow_delete": "true" // 요기
                },
                "provided_name": "addresses",
                "creation_date": "1598892564166",
                "number_of_replicas": "1",
                "uuid": "FPcGD8KfSnyAQ5642YBoKw",
                "version": {
                    "created": "7040299"
                }
            }
        }
    }
}
```

검색해보면, 아마... 아래 상황들일 때 잠기는 것 같다.

- 디스크가 es 가 허용하는 범위를 초과함. (디스크 용량)
- CPU 과부하

_해결_

아래 두가지 방법으로 해결 할 수 있다.

일시적 해결.

```curl
curl -XPUT 'http://localhost:9200/addresses/_settings' \
-H 'Content-Type: application/json' \
--data-raw '{
    "index": {
        "blocks": {
            "read_only_allow_delete": "false"
        }
    }
}'
```

잠슴상태 (안전한 상태) 를 사용하지 않음.

```curl
curl -XPUT 'http://localhost:9200/_cluster/settings' \
--header 'Content-Type: application/json' \
--data-raw '{
    "persistent": {
        "cluster.routing.allocation.disk.threshold_enabled": false
    }
}'
```
