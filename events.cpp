#include <CoreServices/CoreServices.h>
#include <iostream>

using namespace std;

void callback(
    ConstFSEventStreamRef streamRef, 
    void *clientCallBackInfo, 
    size_t numEvents,
    void* eventPaths,
    const FSEventStreamEventFlags eventFlags[], 
    const FSEventStreamEventId eventIds[]) 
{
  int i;
  cout << numEvents << endl;

  for (i = 0; i < numEvents; i++) {
    cout << (eventFlags[i] == kFSEventStreamEventFlagItemCreated) << endl;
    cout << (eventFlags[i] == kFSEventStreamEventFlagItemRenamed) << endl;
    cout << (eventFlags[i] == kFSEventStreamEventFlagItemRemoved) << endl;
    cout << endl;
  }


}

void startWatcher() {
  CFStringRef mypath = CFSTR("/Users/Andy/Downloads/");
  CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
  FSEventStreamRef stream;
  CFAbsoluteTime latency = 1.0; /* Latency in seconds */

  stream = FSEventStreamCreate(NULL,
      &callback,
      NULL,
      pathsToWatch,
      kFSEventStreamEventIdSinceNow,
      latency,
      kFSEventStreamCreateFlagFileEvents
  );

  FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
  FSEventStreamStart(stream);
}

int main(int argc, char* argv[]) {
  startWatcher();
  CFRunLoopRun();
  return 0;
}

