/// Contains indices mappings that are accessed with appropriate names.
const indices = {
  "users": {
    "settings": {
      "analysis": {
        "analyzer": {
          "autocomplete": {
            "type": "custom",
            "tokenizer": "keyword",
            "filter": [
              "lowercase",
              "autocomplete_filter"
            ] 
          }
        },
        "filter": {
          "autocomplete_filter": {
            "type": "edge_ngram",
            "min_gram": "1",
            "max_gram": "20"
          }
        }
      }
    },
    "mappings": {
      "dynamic": "strict",
      "properties": {
        "bio": {
          "type": "text",
          "norms": false
        },
        "email": {
          "type": "keyword"
        },
        "id": notSearchedStringMapping,
        "name": {
          "type": "text",
          "search_analyzer": "standard",
          "analyzer": "autocomplete",
          "fields": {
            "keyword": {
              "type": "keyword"
            }
          }
        },
        "picture": notSearchedStringMapping,
        "timestamp": {
          "type": "date"
        }
      }
    }
  },


  "rooms": {
    "settings": {
      "analysis": {
        "analyzer": {
          "autocomplete": {
            "type": "custom",
            "tokenizer": "keyword",
            "filter": [
              "lowercase",
              "autocomplete_filter"
            ]
          }
        },
        "filter": {
          "autocomplete_filter": {
            "type": "edge_ngram",
            "min_gram": "1",
            "max_gram": "20"
          }
        }
      }
    },
    "mappings": {
      "dynamic": "strict",
      "properties": {
        "id": {
          "type": "keyword",
          "norms": false,
          "doc_values": false,
          "index": false
        },
        "isPrivate": {
          "type": "boolean"
        },
        "lastMessageContent": {
          "type": "text"
        },
        "lastMessageHasPicture": {
          "type": "boolean"
        },
        "lastMessageSenderId": notSearchedStringMapping,
        "lastMessageTimestamp": {
          "type": "date"
        },
        "name": {
          "type": "text",
          "search_analyzer": "standard",
          "analyzer": "autocomplete",
          "fields": {
            "keyword": {
              "type": "keyword"
            }
          }
        },
        "picture": notSearchedStringMapping,
        "timestamp": {
          "type": "date"
        }
      }
    }
  },


  // seenBy field is omitted for elasticsearch storage
  "messages": {
    "mappings": {
      "dynamic": "strict",
      "properties": {
        "content": {
          "type": "text"
        },
        "edited": {
          "type": "boolean"
        },
        "id": notSearchedStringMapping,
        "picture": notSearchedStringMapping,
        "senderId": notSearchedStringMapping,
        "timestamp": {
          "type": "date"
        }
      }
    }
  },


  "members": {
    "mappings": {
      "dynamic": "strict",
      "properties": {
        "roomId": notSearchedStringMapping,
        "userId": notSearchedStringMapping
      }
    }
  },


  "friend_invites": { 
    "mappings": {
      "dynamic": "strict",
      "properties": {
        "fromUser": notSearchedStringMapping,
        "id": notSearchedStringMapping,
        "status": {
          "type": "integer"
        },
        "timestamp": {
          "type": "date"
        },
        "toUser": notSearchedStringMapping
      }
    }
  }
};

const notSearchedStringMapping = {
  "type": "keyword",
  "norms": false
};