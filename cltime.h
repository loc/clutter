#ifndef CLTIME_H
#define CLTIME_H

#include "time.h"
#include <CoreServices/CoreServices.h>
#include <chrono>
#include <string>

using namespace std;

/* all represented in seconds */
double clMinute = 60;
double clHour = 60 * clMinute;
double clDay = 24 * clHour;

double durationFromUnit(double n, string unit) {
  if (unit == "d") {
    return n * clDay;
  }
  else if (unit == "h") {
    return n * clHour;
  }
  else if (unit == "min") {
    return n * clMinute;
  }
  return n;
}

#define unixConverter 978307200

CFAbsoluteTime unixToAbsolute(time_t unix_ts) {
  return unix_ts + unixConverter;
}
time_t unixToAbsolute(CFAbsoluteTime mac_ts) {
  return mac_ts - unixConverter;
}

#endif
