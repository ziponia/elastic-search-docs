## 은전한닢 (AWS Elasticsearch Service 지원)

2020. 09. 17. 현재 ES 는 7.7 Version.

소감.

- AWS ES 는 index `_close` 가 안된다.
- 안정성, 관리 차원에서는 그냥 AWS ES 앞으로 쓸듯.

_의문 1._

코사인유사도(cosinesimilarity) 를 사용할때,

java로 문자열을 vector 로 만든다는게 뭐지?


다음은 인덱스 생성시 `유사어` 지정 예시

```json
{
    "settings": {
        "number_of_shards": 2,
        "number_of_replicas": 1,
        "analysis": {
            "tokenizer": {
                "seunjeon": {
                    "type": "seunjeon_tokenizer",
                    "index_eojeol": true,
                    "decompound": true,
                    "index_poses": [
                        "UNK",
                        "EP",
                        "E",
                        "I",
                        "J",
                        "M",
                        "N",
                        "S",
                        "SL",
                        "SH",
                        "SN",
                        "V",
                        "VCP",
                        "XP",
                        "XS",
                        "XR"
                    ]
                }
            },
            "analyzer": {
                "korean_analyzer": {
                    "type": "custom",
                    "tokenizer": "seunjeon_tokenizer",
                    "filter": [
                        "synonym_filter"
                    ]
                }
            },
            "filter": {
                // 유사어 지정
                "synonym_filter": {
                    "type": "synonym",
                    "synonyms": [
                        "고객센터,센터,상담실",
                        "요금,얼마,비싸",
                        "이벤트,행사"
                    ]
                }
            }
        }
    },
    "mappings": {
        "properties": {
            "title": {
                "type": "text",
                "analyzer": "korean_analyzer"
            }
        }
    }
}
```

다음은, Querydsl 기본쿼리와 하이라이팅 예시

```json
{
    "sort": [
        "_score"
    ],
    "query": {
        "match": {
            "title": "요금좀 알려주세요"
        }
    },
    "highlight": {
        "pre_tags": ["<i>"],
        "post_tags": ["</i>"],
        "fields": {
            "*": {}
        }
    }
}
```