#include "cltime.h"

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

string timeLeftWords(time_t expiration) {
    time_t now = CFAbsoluteTimeGetCurrent();
    // get to minutes
    double elapsed = (expiration - now) / (double)(60);
    string word = "";
    
    if (elapsed < 0) return "";
    if (elapsed < 1) return "now";
    // get to weeks
    elapsed /= (double)(60 * 24 * 7);
    if (elapsed > 1) { word = "week"; goto ret; }
    elapsed *= 7;
    if (elapsed > 1) { word = "day"; goto ret; }
    elapsed *= 24;
    if (elapsed > 1) { word = "hour"; goto ret; }
    elapsed *= 60;
    if (elapsed > 1) { word = "minute"; goto ret; }

ret:
    return stringifyCount(round(elapsed), word);
}

string stringifyCount(long count, string word) {
//    string words = "%ld"
    string words = to_string(count) + " " + word;
    
    if (count > 1) {
        words += "s";
    }
    return words;
}

CFAbsoluteTime unixToAbsolute(time_t unix_ts) {
  return unix_ts + unixConverter;
}
time_t unixToAbsolute(CFAbsoluteTime mac_ts) {
  return mac_ts - unixConverter;
}
