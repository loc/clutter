#include "core.h"

using namespace std;

void fileEventHandler(Event e, file f) {
  cout << f.fileName << " ";

  if (e & created) {
    cout << "created";
  }
  else if (e & accessed) {
    cout << "accessed";
  }
  else if (e & modified) {
    cout << "modified";
  }
  else if (e & deleted) {
    cout << "deleted";
  }
  else if (e & renamed) {
    cout << "renamed";
  }

  cout << " " << (unsigned int) e << endl;
}

int main(int argc, char* argv[]) {
  Watcher * watcher = new Watcher("/Users/Andy/Downloads/test/", fileEventHandler);

  watcher->loop();
  return 0;
}
