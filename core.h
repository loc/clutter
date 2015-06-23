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
  string path;
  time_t last_access;
} file;

class Watcher {
  string path;
  unordered_map<unsigned long, file*> m;
  function<void(Event, file)> callback;

  public:
  Watcher(string p, function<void(Event, file)> cb);
  
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
