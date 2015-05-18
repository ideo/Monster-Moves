//
//  GLSprite.h
//  Almost
//
//  Created by Zhou Yang on 5/21/14.
//
//

#ifndef __Almost__GLSprite__
#define __Almost__GLSprite__

#include "cocos2d.h"

USING_NS_CC;

class GLSprite : public Sprite {
    
public:
    
    void drawLine(Point p1, Point p2, float width, Color4F color, bool re = true);
    
    void fillArc(Point center, float degree, float range, float radius, int seg, Color4F color, Color4F strokeColor, float lineWidth, bool ltc = false);
    
    void fillCircle(Point center, float radius, Color4F color, Color4F strokeColor, float lineWidth);
    
    virtual bool init();
    
    virtual void setOpacity(GLubyte opacity);
    
    CREATE_FUNC(GLSprite);
    
    virtual void draw(Renderer *renderer, const Mat4& transform, uint32_t flags);
    
protected:
    virtual void onDraw(const Mat4 &transform, uint32_t flags);
    CustomCommand _customCommand;
};


#endif /* defined(__Almost__GLSprite__) */
