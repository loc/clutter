
#ifdef _cplusplus
extern "C" {
#endif

#ifndef CORE_H
#define CORE_H

#include <CoreServices/CoreServices.h>
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

#define ARCHIVE_NAME ".clutter.dat"

using namespace std;

enum Event {
  modified = 1 << 0,
  created = 1 << 1,
  renamed = 1 << 2,
  deleted = 1 << 3,
  accessed = 1 << 4
};

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
    ar & _expired;
  }

  string fileName;
  string previousName;
  string path;
  unsigned long long inode;
  time_t last_access;
  time_t last_modification;
  time_t created;
  time_t expiring;

  bool _checked;
  bool _expried;
} file;

typedef function<void(Event, file)> WatcherCallback;

class Watcher {
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) {
    ar & m;
  }

  string path;
  unordered_map<unsigned long, file*> m;
  unordered_map<string, file*> names;
  double nextExpiration;
  CFRunLoopTimerRef timer;

  WatcherCallback callback;

  void setupTimer(void);
  void setupFileWatcher(void);

  public:
  Watcher(string p, WatcherCallback cb);

  void loop(void);
  vector<file*>* listFiles(void);
  vector<file*>* expireFiles(void);
  unsigned long count(void);
  void directoryChanged(bool supressEvents);

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

/* I/O */
void loadWatcher(Watcher * watcher, string path); 

void saveWatcher(Watcher * watcher, string path);

BOOST_CLASS_VERSION(Watcher, 1)

#endif

#ifdef _cplusplus
}
#endif
