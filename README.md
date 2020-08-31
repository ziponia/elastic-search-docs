# Elasticsearch (ES) 학습하기

- [x] 환경은 docker 로 구성 할 수 있다.
- [ ] 플러그인을 설치 할 수 있다.
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

```Dockerfile
FROM docker.elastic.co/elasticsearch/elasticsearch:7.4.2

WORKDIR /usr/share/elasticsearch
```

```
$ docker-compose up -d

Creating es ... done
```
