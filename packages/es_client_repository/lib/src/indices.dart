/// Contains indices mappings that are accessed with appropriate names.
const indices = {
  "users": {
    "settings": {
      "analysis": analysisEdgeNgram
    },
    "mappings": {
      "dynamic": "strict",
      "properties": userProperties
    }
  },


  "rooms": {
    "settings": {
      "analysis": analysisEdgeNgram
    },
    "mappings": {
      "dynamic": "strict",
      "properties": {
        "id": notSearchedStringMapping,
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


  // Merged friendships subcollection with friend_invites collection from firebase.
  // It is not deleted on user deleting an invite, only when the friendship ends.
  // New documents are indexed with invite id.
  "friendships_invites": {
    "settings": {
      "analysis": analysisEdgeNgram
    },
    "mappings": {
      "dynamic": "strict",
      "properties": {
        // Invites related
        "fromUser": notSearchedStringMapping,
        "id": notSearchedStringMapping,
        "status": {
          "type": "integer"
        },
        "timestamp": {
          "type": "date"
        },
        "toUser": notSearchedStringMapping,

        // Friendships related.
        // Will only be included when the friendship is settled.
        "firstUser": {
          "properties": { // Important ones taken from users index
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
        },
        "secondUser": {
          "properties": { // Important ones taken from users index
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
        },
        "since": {
          "type": "date"
        }
      }
    }
  }
};

const analysisEdgeNgram = {
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
};

const notSearchedStringMapping = {
  "type": "keyword",
  "norms": false
};

const userProperties = {
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
};