#include "core.h"
#include <sys/stat.h>
#include <vector>
#include <cstring>

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

Watcher::Watcher(string p, WatcherCallback cb) {
  struct stat info;
  struct dirent **nameList;
  int numEntries, i;
  path = p;
  file *f;

  cout << path << endl;

  callback = cb;

  numEntries = scandir(path.c_str(), &nameList, NULL, NULL);

  for (i = 0; i < numEntries; i++) {

    // hide hidden files/directories
    if (!strncmp(nameList[i]->d_name, ".", 1)) {
      continue;
    }

    f = new file();
    stat((path + nameList[i]->d_name).c_str(), &info);

    f->inode = nameList[i]->d_ino;
    f->fileName = nameList[i]->d_name;
    f->path = path;
    f->last_access = info.st_atimespec.tv_sec;
    f->last_modification = info.st_mtimespec.tv_sec;
    f->_checked = false;

    names[nameList[i]->d_name] = f;
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
  file * oldFile;

  numEntries = scandir(path.c_str(), &nameList, NULL, NULL);

  for (i = 0; i < numEntries; i++) {
    event = 0;
    inode = nameList[i]->d_ino;

    // hide hidden files/directories
    if (!strncmp(nameList[i]->d_name, ".", 1)) {
      continue;
    }

    // get it if it exists
    if (m.count(inode)) {
      f = m[inode];
    }
    // create it if it doesn't
    else {
      f = m[inode] = new file();
      f->inode = nameList[i]->d_ino;
      f->path = path;
      event |= created;
    }

    // mark as checked so we know it's still around (and not to send delete event)
    f->_checked = true;

    stat((path + nameList[i]->d_name).c_str(), &info);

    event |= -(f->last_modification != info.st_mtimespec.tv_sec) & modified;
    event |= -(f->fileName != nameList[i]->d_name) & renamed;
    event |= -(f->last_access != info.st_atimespec.tv_sec) & accessed;

    f->previousName = f->fileName;
    f->fileName = nameList[i]->d_name;
    f->last_access = info.st_atimespec.tv_sec;
    f->last_modification = info.st_mtimespec.tv_sec;
    f->created = info.st_mtimespec.tv_sec;

    if (event & created) {
      // for vim and Emacs like editors that create a new file on every save
      oldFile = names[nameList[i]->d_name];
      if (oldFile && oldFile->inode != f->inode) {
        // update new file with old file start ts and mark modification date as right now
        f->last_modification = info.st_mtimespec.tv_sec;
        f->created = oldFile->created;
        event = modified;
        m.erase(oldFile->inode);
        names.erase(oldFile->fileName);
      }

      names[nameList[i]->d_name] = f;
    }

    if (event != 0) { 
      callback(static_cast<Event>(event), *f);
    }
  }

  auto it = m.begin();
  // check for deleted files
  while (it != m.end()) {
    if (!it->second->_checked) {
      callback(deleted, *(it->second));
      names.erase(it->second->fileName);
      m.erase(it++);
    }
    else {
      it->second->_checked = false;
      it++;
    }
  }
}
