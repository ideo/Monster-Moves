//
//  FadeParticleSystem.cpp
//  MonsterMove
//
//  Created by Zhou Yang on 15/3/20.
//
//

#include "FadeParticleSystem.h"

FadeParticleSystem * FadeParticleSystem::create(const std::string& filename)
{
    FadeParticleSystem *ret = new (std::nothrow) FadeParticleSystem();
    if (ret && ret->initWithFile(filename))
    {
        ret->autorelease();
        return ret;
    }
    CC_SAFE_DELETE(ret);
    return ret;
}

void FadeParticleSystem::update(float dt)
{
    CC_PROFILER_START_CATEGORY(kProfilerCategoryParticles , "CCParticleSystem - update");
    
    if (_isActive && _emissionRate)
    {
        float rate = 1.0f / _emissionRate;
        //issue #1201, prevent bursts of particles, due to too high emitCounter
        if (_particleCount < _totalParticles)
        {
            _emitCounter += dt;
        }
        
        while (_particleCount < _totalParticles && _emitCounter > rate)
        {
            this->addParticle();
            _emitCounter -= rate;
        }
        
        _elapsed += dt;
        if (_duration != -1 && _duration < _elapsed)
        {
            this->stopSystem();
        }
    }
    
    _particleIdx = 0;
    
    Vec2 currentPosition = Vec2::ZERO;
    if (_positionType == PositionType::FREE)
    {
        currentPosition = this->convertToWorldSpace(Vec2::ZERO);
    }
    else if (_positionType == PositionType::RELATIVE)
    {
        currentPosition = _position;
    }
    
    {
        Mat4 worldToNodeTM = getWorldToNodeTransform();
        
        while (_particleIdx < _particleCount)
        {
            tParticle *p = &_particles[_particleIdx];
            p->timeLived += dt;
            // life
            p->timeToLive -= dt;
            
            if (p->timeToLive > 0)
            {
                // Mode A: gravity, direction, tangential accel & radial accel
                if (_emitterMode == Mode::GRAVITY)
                {
                    Vec2 tmp, radial, tangential;
                    
                    radial = Vec2::ZERO;
                    // radial acceleration
                    if (p->pos.x || p->pos.y)
                    {
                        radial = p->pos.getNormalized();
                    }
                    tangential = radial;
                    radial = radial * p->modeA.radialAccel;
                    
                    // tangential acceleration
                    float newy = tangential.x;
                    tangential.x = -tangential.y;
                    tangential.y = newy;
                    tangential = tangential * p->modeA.tangentialAccel;
                    
                    // (gravity + radial + tangential) * dt
                    tmp = radial + tangential + modeA.gravity;
                    tmp = tmp * dt;
                    p->modeA.dir = p->modeA.dir + tmp;
                    
                    // this is cocos2d-x v3.0
                    //                    if (_configName.length()>0 && _yCoordFlipped != -1)
                    
                    // this is cocos2d-x v3.0
                    tmp = p->modeA.dir * dt * _yCoordFlipped;
                    p->pos = p->pos + tmp;
                }
                
                // Mode B: radius movement
                else
                {
                    // Update the angle and radius of the particle.
                    p->modeB.angle += p->modeB.degreesPerSecond * dt;
                    p->modeB.radius += p->modeB.deltaRadius * dt;
                    
                    p->pos.x = - cosf(p->modeB.angle) * p->modeB.radius;
                    p->pos.y = - sinf(p->modeB.angle) * p->modeB.radius;
                    p->pos.y *= _yCoordFlipped;
                }
                
                // color
                p->color.r += (p->deltaColor.r * dt);
                p->color.g += (p->deltaColor.g * dt);
                p->color.b += (p->deltaColor.b * dt);
//                p->color.a += (p->deltaColor.a * dt);
                
                if (p->timeLived <= m_fadeInTime) {
                    p->color.a = p->timeLived / m_fadeInTime * _startColor.a;
                }
                
                if (p->timeToLive <= m_fadeOutTime) {
                    float a = p->timeToLive;
                    if (a < 0.0) {
                        a = 0.0;
                    }
                    p->color.a = a / m_fadeOutTime * _startColor.a;
                }
                
                // size
                
                p->reservedSize += (p->deltaSize * dt);
                p->size = MAX( 0, p->reservedSize );
                
                if (m_scaleUpTime > 0.0 && p->timeLived < m_scaleUpTime) {
                    p->size *= p->timeLived / m_scaleUpTime;
                }
                
                if (p->timeToLive <=  m_scaleDownTime) {
                    float a = p->timeToLive;
                    if (a < 0.0) {
                        a = 0.0;
                    }
                    p->size *= a / m_scaleDownTime;
//                    CCLOG("setting : %f, %f", p->color.a, p->size);
                }
                
                // angle
                p->rotation += (p->deltaRotation * dt);
                
                //
                // update values in quad
                //
                
                Vec2    newPos;
                
                if (_positionType == PositionType::FREE)
                {
                    Vec3 p1(currentPosition.x,currentPosition.y,0),p2(p->startPos.x,p->startPos.y,0);
                    worldToNodeTM.transformPoint(&p1);
                    worldToNodeTM.transformPoint(&p2);
                    p1 = p1 - p2;
                    newPos = p->pos - Vec2(p1.x,p1.y);
                }
                else if(_positionType == PositionType::RELATIVE)
                {
                    Vec2 diff = currentPosition - p->startPos;
                    newPos = p->pos - diff;
                }
                else
                {
                    newPos = p->pos;
                }
                
                // translate newPos to correct position, since matrix transform isn't performed in batchnode
                // don't update the particle with the new position information, it will interfere with the radius and tangential calculations
                if (_batchNode)
                {
                    newPos.x+=_position.x;
                    newPos.y+=_position.y;
                }
                
                updateQuadWithParticle(p, newPos);
                //updateParticleImp(self, updateParticleSel, p, newPos);
                
                // update particle counter
                ++_particleIdx;
            }
            else
            {
                // life < 0
                int currentIndex = p->atlasIndex;
                if( _particleIdx != _particleCount-1 )
                {
                    _particles[_particleIdx] = _particles[_particleCount-1];
                }
                if (_batchNode)
                {
                    //disable the switched particle
                    _batchNode->disableParticle(_atlasIndex+currentIndex);
                    
                    //switch indexes
                    _particles[_particleCount-1].atlasIndex = currentIndex;
                }
                
                
                --_particleCount;
                
                if( _particleCount == 0 && _isAutoRemoveOnFinish )
                {
                    this->unscheduleUpdate();
                    _parent->removeChild(this, true);
                    return;
                }
            }
        } //while
        _transformSystemDirty = false;
    }
    
    // only update gl buffer when visible
    if (_visible && ! _batchNode)
    {
        postStep();
    }
    
    CC_PROFILER_STOP_CATEGORY(kProfilerCategoryParticles , "CCParticleSystem - update");
//    CCLOG("FadeParticleRunning");
}
