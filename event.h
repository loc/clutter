//
//  event.h
//  Clutter
//
//  Created by Andy Locascio on 10/5/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

enum Event {
    modified = 1 << 0,
    created = 1 << 1,
    renamed = 1 << 2,
    deleted = 1 << 3,
    accessed = 1 << 4,
    expired = 1 << 5,
    expirationChanged = 1 << 6,
    restored = 1 << 7
};

typedef enum MessageType {
    CLRequestExpirationMessageType = 1 << 0,
    CLExtensionMessageType = 1 << 1,
    CLListeningAtPortMessageType = 1 << 2,
    CLRefreshExpirationMessageType = 1 << 3,
    CLRequestExpirationInWordsMessageType = 1 << 4,
    CLStoppedListeningAtPortMessageType = 1 << 5,
    CLRequestDirectoryMessageType = 1 << 6
} MessageType;

typedef enum MessageReturnType {
    CLNoReturnType = 0,
    CLLongReturnType = 1,
    CLArrayReturnType = 2,
    CLStringReturnType = 3
} MessageReturnType;

typedef struct Message {
    MessageReturnType type;
    union data {
        long long_data;
        void* array_data;
        char str_data[255];
    };
} Message;


//enum Message {
//    
//};

