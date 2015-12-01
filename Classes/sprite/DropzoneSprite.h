//
//  DropzoneSprite.h
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/29.
//
//

#ifndef __MonsterMove__DropzoneSprite__
#define __MonsterMove__DropzoneSprite__

#include "TileSprite.h"

class DropzoneSprite : public Sprite
{
public:
    
    TileSprite *m_tile;
    
    int m_index;
    
    Sprite* m_circle;
    
    Color4F m_tileColor;
    
public:
    
    static DropzoneSprite* create(const std::string& filename);
    
    virtual bool initWithFile(const std::string& filename);
    
    void dropTile(TileSprite *tile);
    
    void removeCircle();
    
    void removeCurrentTile();
    
//    Texture2D *getTileColorTexture();
    
    void bounce();
    
    void scaleUp();
    
    void scaleDown();
    
    void restore();
    
private:
    
    float m_frameTime;
    float m_totalDanceTime;
    
    float scaleAdjust;
    
private:
    
    void showCircle();
    
};


#endif /* defined(__MonsterMove__DropzoneSprite__) */
