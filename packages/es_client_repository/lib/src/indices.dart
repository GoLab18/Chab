/// Contains indices mappings that are accessed with appropriate names.
const indices = {
  "users": {
    "settings": {
      "analysis": analysisEdgeNgram
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


  // Holds denormalized members data directly if a private chat room.
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
        },

        // Stored only when the room is private.
        "firstMember": {
          "properties": denormalizedUserProperties
        },
        "secondMember": {
          "properties": denormalizedUserProperties
        }
      }
    }
  },


  // Only holds group chat rooms members.
  // Field userId is omitted for elasticsearch storage.
  // _id field is equal to `<room_id><member_id>`
  "members": {
    "settings": {
      "analysis": analysisEdgeNgram
    },
    "mappings": {
      "dynamic": "strict",
      "properties": {
        "roomId": notSearchedStringMapping,
        "member": {
          "properties": denormalizedUserProperties
        },
        "kickOutTime": {
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
          "properties": denormalizedUserProperties
        },
        "secondUser": {
          "properties": denormalizedUserProperties
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

const denormalizedUserProperties = {
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
  "picture": notSearchedStringMapping
};
