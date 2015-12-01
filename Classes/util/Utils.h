//
//  Utils.h
//  MonsterMove
//
//  Created by Zhou Yang on 4/2/15.
//
//

#ifndef __MonsterMove__Utils__
#define __MonsterMove__Utils__

#include <stdio.h>

class Utils
{
public:
    
    static bool startsWith(std::string longStr, std::string shortStr);
    
    static unsigned long long timeInMillisecond();
    
};

#endif /* defined(__MonsterMove__Utils__) */
