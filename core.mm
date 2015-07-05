#include "core.h"
#include <sys/stat.h>
#include <cstring>

void osxHandler(
    ConstFSEventStreamRef streamRef, 
    void *clientCallBackInfo, 
    size_t numEvents, 
    void* eventPaths, 
    const FSEventStreamEventFlags eventFlags[], 
    const FSEventStreamEventId eventIds[]) {

  Watcher * watcher = static_cast<Watcher*>(clientCallBackInfo);
  watcher->directoryChanged(false);
}

void osxTimerHandler(CFRunLoopTimerRef timer, void *info) {
  Watcher * watcher = static_cast<Watcher*>(info);
  watcher->timerFired();
}

Watcher::Watcher(string p, WatcherCallback cb) {
  struct stat info;
  struct dirent **nameList;
  int numEntries, i;
  path = p;
  file *f;

  cout << path << endl;

  callback = cb;
  loadWatcher(this, path + ARCHIVE_NAME);
  this->directoryChanged(true);
}

void Watcher::setupFileWatcher() {

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
}

void Watcher::timerFired() {
  vector<file*>* expired = this->expireFiles();

  cout << expired->size() << " files expired" << endl;
}

void Watcher::setupTimer() {
  double max = std::numeric_limits<double>::max();
  CFRunLoopTimerContext context = {0, this, NULL, NULL, NULL};
  
  timer = CFRunLoopTimerCreate(
    NULL, // allocator
    max, // set actual fire date later, this is just setup
    max, // interval keeps the timer around until we know what to do with it next
    0, // flags, ignored
    0, // priority, ignored
    osxTimerHandler, // callback
    &context // okay that this memory will go out of scope. CFRLTC copies it
  );
  CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes);
  this->expireFiles();
}

void Watcher::updateTimer(double expiry) {
  this->nextExpiration = expiry;
  cout << "timer updated to " << expiry << endl;

  CFRunLoopTimerSetNextFireDate(timer, expiry);
}

void Watcher::loop() {
  this->setupFileWatcher();
  this->setupTimer();
  CFRunLoopRun();
}

vector<file*>* Watcher::listFiles() {
  vector<file*> * files = new vector<file*>;
  for (auto it = m.begin(); it != m.end(); it++) {
    files->push_back(it->second);
  }
  return files;
}

unsigned long Watcher::count() {
    return m.size();
}

vector<file*>* Watcher::expireFiles() {
  // should set the next expiring time
  // expire old files
  // return all expired files

  double min = std::numeric_limits<double>::max();
  double now = CFAbsoluteTimeGetCurrent();
  double fiveMinsFromNow = now + durationFromUnit(5, "min");
  vector<file*>* expired = new vector<file*>;

  for (auto it = m.begin(); it != m.end(); it++) {
    // skip if expiring is unset
    if (it->second->expiring < 0) continue;

    if (it->second->expiring <= fiveMinsFromNow) {
      expired->push_back(it->second);
      it->second->_expired = true;
    }
    else {
      if (it->second->_expired == true) {
        it->second->_expired = false;
      }
      if (it->second->expiring < min) {
        min = it->second->expiring;
      }
    }
  }

  cout << min << " <--min" << endl;
  if (min != this->nextExpiration) {
    this->updateTimer(min);
  }

  return expired;
}

void Watcher::directoryChanged(bool suppress) {
  struct stat info;
  struct dirent **nameList;
  int numEntries, i;
  file* f;
  unsigned long inode;
  unsigned int event;
  file * oldFile;
  bool shouldSave = false;

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
      f->expiring = -1;
      event |= created;
    }

    // mark as checked so we know it's still around (and not to send delete event)
    f->_checked = true;

    stat((path + nameList[i]->d_name).c_str(), &info);

    event |= -(f->last_modification != info.st_mtimespec.tv_sec) & modified;
    event |= -(f->fileName != nameList[i]->d_name) & renamed;
    //event |= -(f->last_access != info.st_atimespec.tv_sec) & accessed;

    f->previousName = f->fileName;
    f->fileName = nameList[i]->d_name;
    f->last_access = info.st_atimespec.tv_sec;
    f->last_modification = info.st_mtimespec.tv_sec;
    f->created = info.st_mtimespec.tv_sec;

    if (f->fileName == "hello.txt" && (event & created)) {
      f->expiring = CFAbsoluteTimeGetCurrent() + durationFromUnit(1, "min");
    }

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
      if (!suppress) {
        callback(static_cast<Event>(event), *f);
      }
      shouldSave = true;
    }
  }

  auto it = m.begin();
  // check for deleted files
  while (it != m.end()) {
    if (!it->second->_checked) {
      callback(deleted, *(it->second));
      names.erase(it->second->fileName);
      m.erase(it++);
      shouldSave = true;
    }
    else {
      it->second->_checked = false;
      it++;
    }
  }

  // if any one thing happened, update the file
  if (shouldSave) {
    saveWatcher(this, path + ARCHIVE_NAME);
    cout << "watcher saved" << endl;
  }
}

void loadWatcher(Watcher * watcher, string path) {
  int start = watcher->count();
  ifstream ifs(path);
  if (ifs.good()) {
    boost::archive::text_iarchive ar(ifs);
    ar & *watcher;
    if (start != watcher->count()) {
      cout << watcher->count() - start << "files loaded" << endl;
    }
  }
}

void saveWatcher(Watcher * watcher, string path) {
  ofstream ofs(path);
  boost::archive::text_oarchive ar(ofs);
  ar & *watcher;
}
