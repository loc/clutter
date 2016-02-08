//
//  clrequest.cpp
//  Clutter
//
//  Created by Andy Locascio on 2/6/16.
//  Copyright © 2016 Bubble Tea Apps. All rights reserved.
//

#include "clrequest.h"
#include <CoreFoundation/CoreFoundation.h>

#define ANALYTICS_URL "http://www.google-analytics.com/collect"
#define ANALYTICS_BATCH_URL "http://www.google-analytics.com/batch"


void reachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void * info) {
    AnalyticsManager* self = (AnalyticsManager*)info;
    
    
    if (isReachableFlags(flags)) {
        self->isReachable = true;
        self->dequeueHits();
    } else {
        self->isReachable = false;
    }
}
void queueTimerCallback(CFRunLoopTimerRef timer, void *info) {
    AnalyticsManager * analytics = static_cast<AnalyticsManager*>(info);
    analytics->dequeueHits();
}

AnalyticsManager::AnalyticsManager() {
    
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    
    /* See if we can reach the interwebs! */
    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (const struct sockaddr*)&zeroAddress);
    SCNetworkReachabilityContext context = {0, this, NULL, NULL, NULL};
    
    SCNetworkReachabilitySetCallback(reachabilityRef, reachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    
    if (reachabilityRef != NULL)
    {
        SCNetworkReachabilityFlags flags = 0;
        
        if(SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
            isReachable = isReachableFlags(flags);
        
        CFRelease(reachabilityRef);
    }   
    
    /* set up a timer for batch analytics */
    CFRunLoopTimerContext timerContext = {0, this, NULL, NULL, NULL};
    
    CFRunLoopTimerRef timer = CFRunLoopTimerCreate(
                                 NULL, // allocator
                                 CFAbsoluteTimeGetCurrent() + 30, // set actual fire date later, this is just setup
                                 120, // interval between invocation
                                 0, // flags, ignored
                                 0, // priority, ignored
                                 queueTimerCallback, // callback
                                 &timerContext // okay that this memory will go out of scope. CFRLTC copies it
                                 );
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes);
    
    queue = new std::vector<QueueTuple>();
    timingMap = new std::unordered_map<TimingKey, time_t>;
}

bool post_request(std::vector<QueueTuple>* queue) {
    std::string postField = "";
    
    CURL *curl;
    CURLcode res;
    
    /* In windows, this will init the winsock stuff */
    curl_global_init(CURL_GLOBAL_ALL);
    
    /* get a curl handle */
    curl = curl_easy_init();
    if(curl) {
        for (auto q_iter = queue->begin(); q_iter != queue->end(); ++q_iter) {
//            KeyValVec* postData = (KeyValVec*) std::get<1>(*q_iter);
            KeyValVec* postData = q_iter->data;
            
            unsigned long long queueTime = (CFAbsoluteTimeGetCurrent() - q_iter->timeAdded) * 1000;
            
            for (auto iter = postData->begin(); iter != postData->end(); ++iter) {
                std::string val = curl_easy_escape(curl, iter->second.c_str(), iter->second.length());
                postField.append(iter->first + "=" + val);
                postField.append("&");
            }
            
            postField.append("qt=" + std::to_string(queueTime) + "\n");
        }
        const char* data = postField.c_str();

        curl_easy_setopt(curl, CURLOPT_URL, ANALYTICS_BATCH_URL);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)strlen(data));
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, data);
//        curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
//        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        std::cout << postField << std::endl;
        
        /* Perform the request, res will get the return code */
        res = curl_easy_perform(curl);
        /* Check for errors */
        if(res != CURLE_OK)
            fprintf(stderr, "curl_easy_perform() failed: %s\n",
                    curl_easy_strerror(res));
        
        /* always cleanup */
        curl_easy_cleanup(curl);
    }
    curl_global_cleanup();
    
    return res == CURLE_OK;
}


#ifdef __APPLE__
std::string getPreference(std::string key) {
    CFStringRef keyRef = CFStringCreateWithCString(nil, key.c_str(), kCFStringEncodingMacRoman);
    CFStringRef valRef;
    std::string val;
    valRef = (CFStringRef)CFPreferencesCopyAppValue(keyRef,
                                           kCFPreferencesCurrentApplication);
    
    if (valRef == NULL) val = "";
    else {
    
        CFIndex length = CFStringGetLength(valRef);
        CFIndex maxSize =
        CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8) + 1;
        char *buffer = (char *)malloc(maxSize);
        
        CFStringGetCString(valRef, buffer, maxSize, kCFStringEncodingUTF8);
        val = buffer;
    //    string val = CFStringGetCStringPtr(valRef, kCFStringEncodingMacRoman)   ;
    }
    
    CFRelease(valRef);
    CFRelease(keyRef);
    
    return val;
}
#endif

KeyValVec* createDefaultAnalytics() {
    
    KeyValVec* vec = new KeyValVec();
    
    std::string osVersion = getPreference("osVersion");
    std::string userAgent = getPreference("userAgent");
    
    vec->push_back(StringTuple("v", "1"));
    vec->push_back(StringTuple("tid", "UA-73001610-2"));
    vec->push_back(StringTuple("cid", getPreference("uuid")));
    vec->push_back(StringTuple("uid", getPreference("uuid")));
    vec->push_back(StringTuple("an", "clutter"));
    vec->push_back(StringTuple("av", getPreference("version")));
    if (!userAgent.empty())
        vec->push_back(StringTuple("ua", userAgent));
    else if (!osVersion.empty())
        vec->push_back(StringTuple("cd1", osVersion));
    
    
//    (*m)["t"] = "UA-73001610-2";
    return vec;
}

KeyValVec* combineVectors(KeyValVec* a, KeyValVec* b) {
    KeyValVec* combine = new KeyValVec();
    
    combine->reserve( a->size() + b->size() );
    combine->insert( combine->end(), a->begin(), a->end() );
    combine->insert( combine->end(), b->begin(), b->end() );
    
    return combine;
}

void AnalyticsManager::enqueueHit(KeyValVec* postData) {
    queue->push_back({postData, static_cast<time_t>(CFAbsoluteTimeGetCurrent())});
}

void AnalyticsManager::dequeueHits() {
    
    if (!isReachable || queue->size() == 0) return;
    
    int limit = std::min(20, (int)queue->size());
    std::vector<QueueTuple>* toPost = new std::vector<QueueTuple>();
    toPost->insert(toPost->end(), queue->begin(), queue->begin() + limit);
    
    if (post_request(toPost)) {
        // success!
        for (auto iter = toPost->begin(); iter < toPost->end(); iter++) {
            delete iter->data;
        }
        
        queue->erase(queue->begin(), queue->begin() + limit);
        if (!queue->empty()) dequeueHits();
    }
    delete toPost;
}

void AnalyticsManager::startTimer(std::string category, std::string name) {
    TimingKey key = {category, name};
    
    (*this->timingMap)[key] = CFAbsoluteTimeGetCurrent();
    this->timingMap->insert(std::make_pair(key, CFAbsoluteTimeGetCurrent()));
}

void AnalyticsManager::endTimer(std::string category, std::string name, std::string label) {
    KeyValVec* vec = new KeyValVec();
    TimingKey key = {category, name};
    auto iter = this->timingMap->find(key);
    if (iter == this->timingMap->end()) return;
    
    unsigned long long time = (CFAbsoluteTimeGetCurrent() - iter->second) * 1000;
    
    vec->push_back(StringTuple("t", "timing"));
    vec->push_back(StringTuple("utc", category));
    vec->push_back(StringTuple("utv", name));
    if (!label.empty())
        vec->push_back(StringTuple("utl", label));
    vec->push_back(StringTuple("utt", std::to_string(time)));
    
    this->timingMap->erase(iter);
    
    this->customHit(vec);
}


bool AnalyticsManager::customHit(KeyValVec* customVec) {
    KeyValVec* defaults = createDefaultAnalytics();
    KeyValVec* combined = combineVectors(defaults, customVec);
    
    enqueueHit(combined);
    
    delete defaults;
    delete customVec;
    return true;
}

bool AnalyticsManager::event(std::string category, std::string action) {
    return this->event(category, action, "");
}
bool AnalyticsManager::event(std::string category, std::string action, std::string label) {
    KeyValVec* vec = new KeyValVec();
    
    vec->push_back(StringTuple("t", "event"));
    vec->push_back(StringTuple("ec", category));
    vec->push_back(StringTuple("ea", action));
    if (!label.empty())
        vec->push_back(StringTuple("el", label));
    
    return this->customHit(vec);
}

