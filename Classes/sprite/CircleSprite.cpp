//
//  CircleSprite.cpp
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/21.
//
//

#include "CircleSprite.h"

bool CircleSprite::init(Color4F fc, Color4F sc, float r, float lw)
{
    if ( !GLSprite::init() )
    {
        return false;
    }
    
    m_fillColor = fc;
    m_strokeColor = sc;
    m_lineWidth = lw;
    
    setRadiaus(r);
    
    return true;
}

void CircleSprite::setRadiaus(float r)
{
    m_radius = r;
    _contentSize = Size(m_radius * 2.0, m_radius * 2.0);
}

void CircleSprite::onDraw(const Mat4 &transform, uint32_t flags) {
    GLSprite::onDraw(transform, flags);
    
    Color4F finalFillColor = Color4F(m_fillColor.r, m_fillColor.g, m_fillColor.b, m_fillColor.a * (getOpacity() / 255.0));
    Color4F finalStrokeColor = Color4F(m_strokeColor.r, m_strokeColor.g, m_strokeColor.b, m_strokeColor.a * (getOpacity() / 255.0));
    
    fillCircle(getPosition(), m_radius * getScale(), finalFillColor, finalStrokeColor, m_lineWidth);
}

