#ifndef CLTIME_H
#define CLTIME_H

#include "time.h"
#include <CoreServices/CoreServices.h>
#include <chrono>
#include <string>
#define unixConverter 978307200

using namespace std;

double durationFromUnit(double n, string unit);
string stringifyCount(long count, string word);
CFAbsoluteTime unixToAbsolute(time_t unix_ts);
time_t unixToAbsolute(CFAbsoluteTime mac_ts);
string timeLeftWords(time_t expiration);
string timeSinceDaysWords(time_t expiration);

#endif
