//
//  Utils.cpp
//  MonsterMove
//
//  Created by Zhou Yang on 4/2/15.
//
//

#include "Utils.h"

bool Utils::startsWith(std::string longStr, std::string shortStr)
{
    return shortStr.length() <= longStr.length()
    && equal(shortStr.begin(), shortStr.end(), longStr.begin());
}

unsigned long long Utils::timeInMillisecond()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (unsigned long long)(tv.tv_sec) * 1000 + (unsigned long long)(tv.tv_usec) / 1000;
}
