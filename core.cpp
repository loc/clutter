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

static CFDataRef messageCallback(CFMessagePortRef port,
                          SInt32 messageID,
                          CFDataRef data,
                          void *info)
{
  Watcher* watcher = (Watcher*)info;
  
  //
  if (messageID & (CLRequestExpirationMessageType | CLExtensionMessageType | CLRequestExpirationInWordsMessageType)) {
    long stringLen = CFDataGetLength(data);
    if (messageID == CLExtensionMessageType) {
      stringLen -= sizeof(long);
    }
    
    // unpack string from data pointer
    CFStringRef name = CFStringCreateWithBytes(nil, CFDataGetBytePtr(data), stringLen, kCFStringEncodingUTF8, false);
    char* fileName = new char[255];
    CFStringGetCString(name, fileName, 255, kCFStringEncodingUTF8);
    
    file* f = watcher->fileFromName(fileName);
    
    // don't need this anymore, we have the file!
    delete fileName;
    CFRelease(name);
    
    if (!f) {
      return nil;
    }
    
    if (messageID == CLExtensionMessageType) {
      long days = 0;
      memcpy(&days, CFDataGetBytePtr(data) + stringLen, sizeof(long));
      printf("extend %s %ld\n", f->fileName.c_str(), days);
      watcher->extend(f, (int)days);
      
      return nil;
    } else if (messageID == CLRequestExpirationMessageType) {
      UInt8* returnData = new UInt8[sizeof(time_t)];
      
      memcpy(returnData, &f->expiring, sizeof(time_t));
      CFDataRef returnDataRef = CFDataCreate(nil, returnData, sizeof(time_t));
      
      delete returnData;
      
      return returnDataRef;
    } else if (messageID == CLRequestExpirationInWordsMessageType) {
      CFStringRef wordsRef;
      string words = timeLeftWords(f->expiring);
      wordsRef = CFStringCreateWithCString(nil, words.c_str(), kCFStringEncodingUTF8);
      CFDataRef returnData = CFStringCreateExternalRepresentation(nil, wordsRef, kCFStringEncodingUTF8, 0);
      CFRelease(wordsRef);
      return returnData;
    }
  } else if (messageID & (CLStoppedListeningAtPortMessageType | CLListeningAtPortMessageType)) {
    CFStringRef name = CFStringCreateWithBytes(nil, CFDataGetBytePtr(data), CFDataGetLength(data), kCFStringEncodingUTF8, false);
    if (messageID & CLListeningAtPortMessageType) {
      watcher->remotePorts.push_back(CFMessagePortCreateRemote(nil, name));
      
    } else if (messageID & CLStoppedListeningAtPortMessageType) {
      CFMessagePortRef port = CFMessagePortCreateRemote(nil, name);
      CFMessagePortInvalidate(port);

      for (auto it = watcher->remotePorts.begin(); it != watcher->remotePorts.end(); it++) {
        if (port == *it) {
          watcher->remotePorts.erase(it);
          break;
        }
      }
      CFRelease(port);
    }
    CFRelease(name);
  } else if (messageID & CLRequestDirectoryMessageType) {
    CFStringRef path = CFStringCreateWithCString(nil, watcher->path.c_str(), kCFStringEncodingUTF8);
    printf("cstring path: %s", watcher->path.c_str());
    CFDataRef returnData = CFStringCreateExternalRepresentation(nil, path, kCFStringEncodingUTF8, 0);
    CFRelease(path);
    return returnData;
  }
  return nil;
}

CFDataRef Watcher::broadcastMessage(MessageType messageType, CFDataRef data) {
  for (auto it = this->remotePorts.begin(); it != this->remotePorts.end(); it++) {
    CFMessagePortRef port = *it;
    if (CFMessagePortIsValid(port)) {
      CFMessagePortSendRequest(port, messageType, data, 3, 3, nil, nil);
    }
  }
  return nil;
}

void Watcher::setupMessagePorts() {
  CFMessagePortContext context = {0, this, NULL, NULL, NULL};
  localPort = CFMessagePortCreateLocal(nil, CFSTR("com.bubble.tea.Clutter.ToMain"), messageCallback, &context, nil);
  CFRunLoopSourceRef runLoopSource =
  CFMessagePortCreateRunLoopSource(nil, localPort, 0);
  
  CFRunLoopAddSource(CFRunLoopGetCurrent(),
                     runLoopSource,
                     kCFRunLoopCommonModes);
}

Watcher::Watcher(string p, string support, WatcherCallback cb) {
  path = p;
  supportPath = support;
  if (p.compare(path.length(), 1, "/")) {
    path.append("/");
  }
  if (supportPath.compare(supportPath.length(), 1, "/")) {
    supportPath.append("/");
  }
  
  cout << path << endl;

  callback = cb;
  this->loadWatcher();
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
  
  for (auto it = expired->begin(); it != expired->end(); it++) {
    file* f = new file();
    *f = **it;
    archived[(*it)->inode] = f;
    this->callback(removeRequestEvent, f);
//    remove(((*it)->path + (*it)->fileName).c_str());
    // 
  }
  
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
  this->timerFired();
}

void Watcher::updateTimer(double expiry) {
  this->nextExpiration = expiry;
  cout << "timer updated to " << expiry << endl;

  CFRunLoopTimerSetNextFireDate(timer, expiry);
}

void Watcher::loop() {
  this->setupMessagePorts();
  this->setupFileWatcher();
  this->setupTimer();
  CFRunLoopRun();
}

vector<file*>* Watcher::listFiles() {
  vector<file*> * files = new vector<file*>;
  for (auto it = m.begin(); it != m.end(); it++) {
    files->push_back(it->second);
  }
//  kTrashFolderType
  return files;
}

unsigned long Watcher::count() {
    return m.size();
}

file* Watcher::fileFromName(string name) {
    return names[name];
}

void Watcher::keep(file *f, int days) {
  f->expiring = CFAbsoluteTimeGetCurrent() + durationFromUnit(days, "d");
  this->saveWatcher();
  this->timerFired();
}

void Watcher::move(file *f, string path) {
  ::rename((f->path + f->fileName).c_str(), (path + f->fileName).c_str());
}

void Watcher::extend(file *f, int days) {
  if (days < 0) {
    // keep forever
    f->expiring = -1;
    this->saveWatcher();
    this->timerFired();
  }
  else if (f->expiring < 0) {
    this->keep(f, days);
  }
  else {
    f->expiring += durationFromUnit(days, "d");
    this->saveWatcher();
    this->timerFired();
  }
  this->sendExtensionMessage(f);
}

void Watcher::sendExtensionMessage(file *f) {
  CFStringRef fileNameRef = CFStringCreateWithCString(nil, f->fileName.c_str(), kCFStringEncodingUTF8);
  CFDataRef data = CFStringCreateExternalRepresentation(nil, fileNameRef, kCFStringEncodingUTF8, 0);
  this->broadcastMessage(CLRefreshExpirationMessageType, data);
}

void Watcher::rename(file* f, string name) {
  // maybe do santization here?
  names.erase(f->fileName);
  names[name] = f;
  ::rename((f->path + f->fileName).c_str(), (f->path + name).c_str());
  f->fileName = name;
}

vector<file*>* Watcher::expireFiles() {
  // should set the next expiring time
  // expire old files
  // return all expired files

  float min = std::numeric_limits<float>::max();
  float now = CFAbsoluteTimeGetCurrent();
  float fiveMinsFromNow = now;// + durationFromUnit(5, "min");
  vector<file*>* expired = new vector<file*>;

  for (auto it = m.begin(); it != m.end(); it++) {
    // skip if expiring is unset
    if (it->second->expiring < 0) continue;
    printf("%s %ld %f\n", it->second->fileName.c_str(), it->second->expiring, CFAbsoluteTimeGetCurrent());

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
  file * oldFile = nullptr;
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
    if (!(event & created)) {
      event |= -(f->fileName != nameList[i]->d_name) & renamed;
    }
    //event |= -(f->last_access != info.st_atimespec.tv_sec) & accessed;

    // in bytes
    f->fileSize = info.st_size;
//    printf("%llu\n", f->fileSize);
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
      if (names.count(nameList[i]->d_name)) {
        oldFile = names[nameList[i]->d_name];
        if (oldFile && oldFile->inode != f->inode) {
          // update new file with old file start ts and mark modification date as right now
          f->last_modification = info.st_mtimespec.tv_sec;
          f->created = oldFile->created;
          f->expiring = oldFile->expiring;
          event = modified;
          m.erase(oldFile->inode);
          names.erase(oldFile->fileName);
        }
      }
      
      f->downloadedFrom = getDownloadURL(f);
      printf("downloaded from: %s\n", f->downloadedFrom.c_str());
    }
    
    // add it to the names index if it's not already there.
    names[f->fileName] = f;
    
    if (event & renamed) {
      names.erase(f->previousName);
      if (f->downloadedFrom.empty()) {
        f->downloadedFrom = getDownloadURL(f);
        printf("rn: downloaded from: %s\n", f->downloadedFrom.c_str());
      }
    }

    if (event != 0) {
      if (!suppress) {
        callback(static_cast<Event>(event), f);
      }
      shouldSave = true;
    }
  }

  auto it = m.begin();
  // check for deleted files
  while (it != m.end()) {
    if (!it->second->_checked) {
      file* f = it->second;
      callback(deleted, f);
      names.erase(f->fileName);
      it = m.erase(it);
      delete f;
      shouldSave = true;
    }
    else {
      it->second->_checked = false;
      it++;
    }
  }

  // if any one thing happened, update the file
  if (shouldSave) {
    this->saveWatcher();
  }
}

string getDisplayName(string fileName) {
    string chromeDownloadExt = ".crdownload";
    if (fileName.size() > chromeDownloadExt.size() &&
        fileName.compare(fileName.size() - chromeDownloadExt.size(), chromeDownloadExt.size(), chromeDownloadExt) == 0)
    {
        return fileName.substr(0, fileName.size() - chromeDownloadExt.size());
    }
    
    return fileName;
}

void Watcher::loadWatcher() {
  ifstream mainIfs(this->path + ".clutter.dat");
  ifstream supportIfs(this->supportPath + ".archive.dat");
  
  if (mainIfs.good()) {
    boost::archive::text_iarchive mainAr(mainIfs);
    mainAr & this->m;
  }
  if (supportIfs.good()) {
    boost::archive::text_iarchive supportAr(supportIfs);
    supportAr & this->archived;
  }
}
void Watcher::saveWatcher() {
  ofstream mainOfs(this->path + ".clutter.dat");
  ofstream supportOfs(this->supportPath + ".archive.dat");
  
  boost::archive::text_oarchive mainAr(mainOfs);
  mainAr & this->m;
  boost::archive::text_oarchive supportAr(supportOfs);
  supportAr & this->archived;
}

string getDownloadURL(file* f) {
  CFStringRef pathRef = CFStringCreateWithCString(NULL, (f->path + f->fileName).c_str(), kCFStringEncodingUTF8);
  CFStringRef attrRef = CFStringCreateWithCString(NULL, "kMDItemWhereFroms", kCFStringEncodingUTF8);
  MDItemRef itemRef = MDItemCreate(NULL, pathRef);
  CFTypeRef valueRef = MDItemCopyAttribute(itemRef, attrRef);
  string value;
  
  if (valueRef != NULL) {
    if (CFGetTypeID(valueRef) == CFArrayGetTypeID() && CFArrayGetCount((CFArrayRef)valueRef) > 1) {
      valueRef = CFArrayGetValueAtIndex((CFArrayRef) valueRef, 1);
    }
    if (CFGetTypeID(valueRef) == CFStringGetTypeID()) {
      value = CFStringGetCStringPtr((CFStringRef)valueRef, kCFStringEncodingUTF8);
    }
  }
  return value;
}


