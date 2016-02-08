//
//  clrequest.hpp
//  Clutter
//
//  Created by Andy Locascio on 2/6/16.
//  Copyright © 2016 Bubble Tea Apps. All rights reserved.
//
#ifdef _cplusplus
extern "C" {
#endif
    
#ifndef CLREQ_H
#define CLREQ_H

#include <stdio.h>
#include <curl/curl.h>
#include <string>
#include <iostream>
#include <unordered_map>
#include <vector>

#include <SystemConfiguration/SystemConfiguration.h>

typedef struct TimingKey {
    std::string category;
    std::string name;
    std::string label;
} TimingKey;
typedef std::pair<std::string, std::string> StringTuple;
typedef std::vector<std::pair<std::string, std::string>> KeyValVec;

inline bool const operator==(const TimingKey& l, const TimingKey& r) {
    return (l.category == r.category || l.name == r.name);
}

inline bool const operator<(const TimingKey& l, const TimingKey& r) {
    return (l.category < r.category || l.name < r.name);
}

typedef struct QueueTuple {
    KeyValVec* data;
    time_t timeAdded;
} QueueTuple;

inline bool isReachableFlags(SCNetworkReachabilityFlags flags) {
    return (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
}

template <>
struct std::hash<TimingKey>
{
    std::size_t operator()(const TimingKey& k) const
    {
        return ((hash<std::string>()(k.category)
                 ^ (hash<std::string>()(k.name) << 1)) >> 1);
    }
};

class AnalyticsManager {
private:
    std::vector<QueueTuple>* queue;
    std::unordered_map<TimingKey, time_t>* timingMap;
    
    bool isDevelopment;
    bool isReachable;
    void queueHit(std::string url, KeyValVec* postData);
    void dequeueHits();
    void enqueueHit(KeyValVec* postData);
    /* give special access to our run loop callbacks */
    friend void reachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void * info);
    friend void queueTimerCallback(CFRunLoopTimerRef timer, void *info);
    
public:
    AnalyticsManager();
    
    bool event(std::string category, std::string action);
    bool event(std::string category, std::string action, std::string label);
    bool customHit(KeyValVec* params);
    void endTimer(std::string category, std::string name, std::string label);
    void startTimer(std::string category, std::string name);
    
};

//void reachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void * info);
#endif /* CLREQ_H */
    
#ifdef _cplusplus
}
#endif
