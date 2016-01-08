
#ifdef _cplusplus
extern "C" {
#endif

#ifndef CORE_H
#define CORE_H

#include <CoreServices/CoreServices.h>
#include <CoreFoundation/CoreFoundation.h>
#include <dirent.h>
#include <string>
#include <unordered_map>
#include <iostream>
#include <vector>
#include <fstream>
#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>
#include <boost/serialization/version.hpp>
#include <boost/serialization/unordered_map.hpp>
#include "cltime.h"
#include "event.h"

#define ARCHIVE_NAME ".clutter.dat"

using namespace std;

typedef struct file {
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) {
    ar & fileName;
    ar & previousName;
    ar & path;
    ar & inode;
    ar & last_access;
    ar & last_modification;
    ar & created;
    ar & expiring;
    ar & _checked;
    if (version > 1)
        ar & _expired;
    if (version > 2)
        ar & fileSize;
    if (version > 3)
      ar & downloadedFrom;
  }

  string fileName;
  string previousName;
  string path;
  string downloadedFrom;
  unsigned long long inode;
  unsigned long long fileSize;
  time_t last_access;
  time_t last_modification;
  time_t created;
  time_t expiring;

  bool _checked;
  bool _expired;
} file;

typedef function<string(Event, file*)> WatcherCallback;

class Watcher {
//  friend class boost::serialization::access;
//  template<class Archive>
//  void serialize(Archive & ar, const unsigned int version) {
//    ar & m;
//  }

  
  unordered_map<unsigned long, file*> m;
  unordered_map<unsigned long, file*> archived;
  unordered_map<string, file*> names;
  double nextExpiration;
  CFRunLoopTimerRef timer;
  CFMessagePortRef localPort;
  
  void sendExtensionMessage(file *f);
  void setupTimer(void);
  void setupFileWatcher(void);
  bool safeLoadArchiveWithBackup(string name, string path, string backupPath, void* _map);
  bool safeLoadArchive(string name, string path, void* _map);

  public:
  
  Watcher(string p, string support, WatcherCallback cb);
    
  WatcherCallback callback;

  string path;
  string supportPath;
  void loop(void);
  vector<file*>* listFiles(void);
  vector<file*>* expireFiles(void);
  unsigned long count(void);
  void directoryChanged(bool supressEvents);
  void timerFired(void);
  void updateTimer(double expiry);
  file * fileFromName(string name);
  void keep(file* f, int days);
  void move(file* f, string path);
  void extend(file *f, int days);
  void rename(file* f, string name);
  void save();
  void setupMessagePorts();
  CFDataRef broadcastMessage(MessageType messageType, CFDataRef data);
  vector<CFMessagePortRef> remotePorts;
  void loadWatcher();
  void saveWatcher();
};


/* Run loop handlers */
void osxHandler(
    ConstFSEventStreamRef streamRef, 
    void *clientCallBackInfo, 
    size_t numEvents, 
    void* eventPaths, 
    const FSEventStreamEventFlags eventFlags[], 
    const FSEventStreamEventId eventIds[]);

void osxTimerHandler(CFRunLoopTimerRef timer, void *info);
    
string getDisplayName(string fileName);
string getDownloadURL(file* f);

BOOST_CLASS_VERSION(Watcher, 4)

#endif

#ifdef _cplusplus
}
#endif
