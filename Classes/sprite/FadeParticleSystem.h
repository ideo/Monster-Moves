//
//  FadeParticleSystem.h
//  MonsterMove
//
//  Created by Zhou Yang on 15/3/20.
//
//

#ifndef __MonsterMove__FadeParticleSystem__
#define __MonsterMove__FadeParticleSystem__

#include <stdio.h>

#endif /* defined(__MonsterMove__FadeParticleSystem__) */

#include "cocos2d.h"

USING_NS_CC;


class FadeParticleSystem : public ParticleSystemQuad
{
public:
    
    float m_fadeOutTime;
    float m_fadeInTime;
    
    float m_scaleUpTime;
    
    float m_scaleDownTime;
    
public:

    static FadeParticleSystem * create(const std::string& filename);
    
    virtual void update(float dt);
};
