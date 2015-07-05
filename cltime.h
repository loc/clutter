#ifndef CLTIME_H
#define CLTIME_H

#include "time.h"
#include <CoreServices/CoreServices.h>
#include <chrono>
#include <string>
#define unixConverter 978307200

using namespace std;

double durationFromUnit(double n, string unit);
CFAbsoluteTime unixToAbsolute(time_t unix_ts);
time_t unixToAbsolute(CFAbsoluteTime mac_ts);

#endif
