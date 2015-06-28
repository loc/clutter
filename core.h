#ifndef CORE_H
#define CORE_H

#include <CoreServices/CoreServices.h>
#include <dirent.h>
#include <string>
#include <unordered_map>
#include <iostream>


using namespace std;

enum Event {
  modified = 1 << 0,
  created = 1 << 1,
  renamed = 1 << 2,
  deleted = 1 << 3,
  accessed = 1 << 4
};

typedef struct file {
  string fileName;
  string previousName;
  string path;
  unsigned int inode;
  time_t last_access;
  time_t last_modification;
  time_t created;

  bool _checked;
} file;

typedef function<void(Event, file)> WatcherCallback;

class Watcher {
  string path;
  unordered_map<unsigned long, file*> m;
  unordered_map<string, file*> names;

  WatcherCallback callback;

  public:
  Watcher(string p, WatcherCallback cb);
  
  void loop(void );
  void directoryChanged(void);

};

void osxHandler(
    ConstFSEventStreamRef streamRef, 
    void *clientCallBackInfo, 
    size_t numEvents, 
    void* eventPaths, 
    const FSEventStreamEventFlags eventFlags[], 
    const FSEventStreamEventId eventIds[]);



#endif
