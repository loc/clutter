#include "core.h"
#include <sys/stat.h>

void osxHandler(
    ConstFSEventStreamRef streamRef, 
    void *clientCallBackInfo, 
    size_t numEvents, 
    void* eventPaths, 
    const FSEventStreamEventFlags eventFlags[], 
    const FSEventStreamEventId eventIds[]) {

  Watcher * watcher = static_cast<Watcher*>(clientCallBackInfo);
  watcher->directoryChanged();
}

Watcher::Watcher(string p, function<void(Event, file)> cb) {
  struct stat info;
  struct dirent **nameList;
  int numEntries, i;
  path = p;
  file *f;

  cout << path << endl;

  callback = cb;

  numEntries = scandir(path.c_str(), &nameList, NULL, NULL);

  for (i = 0; i < numEntries; i++) {
    f = new file();
    stat((path + nameList[i]->d_name).c_str(), &info);
    f->fileName = nameList[i]->d_name;
    f->path = path;
    f->last_access = info.st_atimespec.tv_sec;
    
    m[info.st_ino] = f;
  }
}

void Watcher::loop() {
  CFStringRef mypath = CFStringCreateWithCString(NULL, path.c_str(), kCFStringEncodingUTF8);
  CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
  FSEventStreamRef stream;
  CFAbsoluteTime latency = 1.0; /* Latency in seconds */
  FSEventStreamContext context = { 0, this, NULL, NULL, NULL };

  stream = FSEventStreamCreate(NULL,
      &osxHandler,
      &context,
      pathsToWatch,
      kFSEventStreamEventIdSinceNow,
      latency,
      kFSEventStreamCreateFlagFileEvents
  );

  FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
  FSEventStreamStart(stream);
  CFRunLoopRun();
}

void Watcher::directoryChanged(void) {
  struct stat info;
  struct dirent **nameList;
  int numEntries, i;
  file* f;
  unsigned long inode;
  bool isNew, changed;
  unsigned int event;

  numEntries = scandir(path.c_str(), &nameList, NULL, NULL);

  for (i = 0; i < numEntries; i++) {
    event = 0;
    inode = nameList[i]->d_ino;

    if (m.count(inode)) {
      f = m[inode];
    }
    else {
      f = m[inode] = new file();
      event |= created;
    }

    stat((path + nameList[i]->d_name).c_str(), &info);

    event |= (f->fileName != nameList[i]->d_name) & modified;
    event |= (f->last_access != info.st_atimespec.tv_sec) & accessed;

    f->fileName = nameList[i]->d_name;
    f->last_access = info.st_atimespec.tv_sec;
    
    m[info.st_ino] = f;
    if (event != 0) { 
      callback(static_cast<Event>(event), *f);
    }
  }
}
