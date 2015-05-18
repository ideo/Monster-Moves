//
//  GLSprite.cpp
//  Almost
//
//  Created by Zhou Yang on 5/21/14.
//
//

#include "GLSprite.h"
#include "Constants.h"

static bool s_initialized = false;
static GLProgram* s_shader = nullptr;

static void lazy_init( void )
{
    if( ! s_initialized ) {
        
        //
        // Position and 1 color passed as a uniform (to simulate glColor4ub )
        //
        s_shader = ShaderCache::getInstance()->getGLProgram(GLProgram::SHADER_NAME_POSITION_COLOR);
        s_shader->retain();
                
        s_initialized = true;
    }
}

bool GLSprite::init() {
    //////////////////////////////
    // 1. super init first
    if ( !Sprite::init() )
    {
        return false;
    }
    
    lazy_init();
    
    return true;
}

void GLSprite::draw(Renderer *renderer, const Mat4 &transform, uint32_t flags)
{
    _customCommand.init(_globalZOrder);
    _customCommand.func = CC_CALLBACK_0(GLSprite::onDraw, this, transform, flags);
    renderer->addCommand(&_customCommand);
}

void GLSprite::onDraw(const Mat4 &transform, uint32_t flags)
{
    s_shader->use();
    s_shader->setUniformsForBuiltins();
    GL::enableVertexAttribs(GL::VERTEX_ATTRIB_FLAG_POSITION | GL::VERTEX_ATTRIB_FLAG_COLOR);
    
//    Director::getInstance()->loadMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW, transform);
//
//    Size visibleSize = Director::getInstance()->getVisibleSize();
//    Point origin = Director::getInstance()->getVisibleOrigin();
//    
//    this->drawLine(origin, Point(visibleSize.width / 2, visibleSize.height / 2), 2, WHITE_COLOR_4F);
//    
//    this->fillArc(Point(visibleSize.width / 2, visibleSize.height / 2), 45, 90, 100, 3, BLUE_FILL_COLOR_4F, WHITE_COLOR_4F, 1, true);
//    
//    kmGLPopMatrix();
}

void GLSprite::setOpacity(GLubyte opacity) {
    Sprite::setOpacity(opacity);
    
    for (auto iter = _children.crbegin(); iter != _children.crend(); ++iter) {
        Sprite* child = dynamic_cast<Sprite*>(*iter);
        if (child) {
            child->setOpacity(opacity);
        }
    }
}

void GLSprite::drawLine(Point p1, Point p2, float width, Color4F color, bool re) {
    if (width < 0.5) {
        width = 0.5;
    }
    float overdraw = 1.0;
    
    float dx = p2.x - p1.x;
    float dy = p2.y - p1.y;
    
    if (dx != 0 && dy != 0) {
        width -= overdraw;
    }
    if (width < 0) {
        overdraw += width;
        width = 0;
        if (overdraw < 0) {
            overdraw = 0;
        }
    }
    
    Point dir = p2 - p1;
    Point perpendicular = dir.getPerp();
    perpendicular.normalize();
    Point A = p1 + perpendicular * width / 2;
    Point B = p1 - perpendicular * width / 2;
    Point C = p2 + perpendicular * width / 2;
    Point D = p2 - perpendicular * width / 2;
    
    GLfloat lineVertices[8];
    lineVertices[0] = A.x;
    lineVertices[1] = A.y;
    lineVertices[2] = B.x;
    lineVertices[3] = B.y;
    lineVertices[4] = C.x;
    lineVertices[5] = C.y;
    lineVertices[6] = D.x;
    lineVertices[7] = D.y;
    
    Color4F vertices[4];
    vertices[0] = color;
    vertices[1] = color;
    vertices[2] = color;
    vertices[3] = color;
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_POSITION, 2, GL_FLOAT, GL_FALSE, 0, lineVertices);
    glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_FLOAT, GL_FALSE, 0, vertices);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    if (overdraw > 0.0001 && p1.x != p2.x && p1.y != p2.y) {
        
        Point F = A + perpendicular * overdraw;
        Point G = C + perpendicular * overdraw;
        Point H = B - perpendicular * overdraw;
        Point I = D - perpendicular * overdraw;
        
        GLfloat lineVerticesL[8];
        GLfloat lineVerticesR[8];
        lineVerticesL[0] = F.x;
        lineVerticesL[1] = F.y;
        lineVerticesL[2] = A.x;
        lineVerticesL[3] = A.y;
        lineVerticesL[4] = G.x;
        lineVerticesL[5] = G.y;
        lineVerticesL[6] = C.x;
        lineVerticesL[7] = C.y;
        
        lineVerticesR[0] = H.x;
        lineVerticesR[1] = H.y;
        lineVerticesR[2] = B.x;
        lineVerticesR[3] = B.y;
        lineVerticesR[4] = I.x;
        lineVerticesR[5] = I.y;
        lineVerticesR[6] = D.x;
        lineVerticesR[7] = D.y;
        
        Color4F blendColor = {color.r, color.g, color.b, 0};
        
        Color4F verticesL[4];
        Color4F verticesR[4];
        verticesL[0] = blendColor;
        verticesL[1] = color;
        verticesL[2] = blendColor;
        verticesL[3] = color;
        
        verticesR[0] = blendColor;
        verticesR[1] = color;
        verticesR[2] = blendColor;
        verticesR[3] = color;
        
        glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_POSITION, 2, GL_FLOAT, GL_FALSE, 0, lineVerticesL);
        glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_FLOAT, GL_FALSE, 0, verticesL);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_POSITION, 2, GL_FLOAT, GL_FALSE, 0, lineVerticesR);
        glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_FLOAT, GL_FALSE, 0, verticesR);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
    }
    
    float r = p1.getDistance(p2);
    
    float degree = CC_RADIANS_TO_DEGREES(acosf(dx / r));
    if (dy < 0) {
        degree = 360 - degree;
    }
    degree += 90;
    
    float endWidth = width / 2;
    if (dx == 0 || dy == 0) {
        endWidth -= 0.4;
    }
    if (re) {
        fillArc(p1, degree, 180, endWidth, 8, color, color, 0);
        fillArc(p2, degree + 180, 180, endWidth, 8, color, color, 0);
    }

    
}

void GLSprite::fillCircle(Point center, float radius, Color4F color, Color4F strokeColor, float lineWidth)
{
    this->fillArc(center, 0, 360, radius, 128, color, strokeColor, lineWidth);
}

void GLSprite::fillArc(Point center, float degree, float range, float radius, int seg, Color4F color, Color4F strokeColor, float lineWidth, bool ltc)
{
    float overdraw = 0.5;
    
    float *lineVertices = (float *)malloc(2 * sizeof(float) * (seg + 2));
    Color4F *colorVertices = (Color4F *)malloc(sizeof(Color4F) * (seg + 2));
    
    float *outerStrokeLineVertices = (float *)malloc(4 * sizeof(float) * (seg + 1));
    Color4F *outerStrokeColorVertices = (Color4F *)malloc(2 * sizeof(Color4F) * (seg + 1));
    
    float *strokeLineVertices = (float *)malloc(4 * sizeof(float) * (seg + 1));
    Color4F *strokeColorVertices = (Color4F *)malloc(2 * sizeof(Color4F) * (seg + 1));
    
    float *innerStrokeLineVertices = (float *)malloc(4 * sizeof(float) * (seg + 1));
    Color4F *innerStrokeColorVertices = (Color4F *)malloc(2 * sizeof(Color4F) * (seg + 1));
    
    lineVertices[0] = center.x;
    lineVertices[1] = center.y;
    colorVertices[0] = color;
    
    float degreeSeg = range / seg;
    
    Color4F transColor = Color4F(color.r, color.g, color.b, 0);
    Color4F strokeTransColor = Color4F(strokeColor.r, strokeColor.g, strokeColor.b, 0);
    
    bool shouldStroke = (strokeColor.a > 0 && lineWidth > 0);
    
    for(int i = 1; i <= seg + 1; i++) {
        lineVertices[i * 2] = center.x + radius * cosf(CC_DEGREES_TO_RADIANS(degree + degreeSeg * (i - 1)));
        lineVertices[i * 2 + 1] = center.y + radius * sinf(CC_DEGREES_TO_RADIANS(degree + degreeSeg * (i - 1)));
        colorVertices[i] = color;
        
        
        outerStrokeLineVertices[(i - 1) * 4] = center.x + radius * cosf(CC_DEGREES_TO_RADIANS(degree + degreeSeg * (i - 1)));
        outerStrokeLineVertices[(i - 1) * 4 + 1] = center.y + radius * sinf(CC_DEGREES_TO_RADIANS(degree + degreeSeg * (i - 1)));
        outerStrokeLineVertices[(i - 1) * 4 + 2] = center.x + (radius + overdraw) * cosf(CC_DEGREES_TO_RADIANS(degree + degreeSeg * (i - 1)));
        outerStrokeLineVertices[(i - 1) * 4 + 3] = center.y + (radius + overdraw) * sinf(CC_DEGREES_TO_RADIANS(degree + degreeSeg * (i - 1)));
        outerStrokeColorVertices[(i - 1) * 2] = shouldStroke ? strokeColor : color;
        outerStrokeColorVertices[(i - 1) * 2 + 1] = shouldStroke ? strokeTransColor : transColor;
        
        strokeLineVertices[(i - 1) * 4] = center.x + (radius - lineWidth) * cosf(CC_DEGREES_TO_RADIANS(degree + degreeSeg * (i - 1)));
        strokeLineVertices[(i - 1) * 4 + 1] = center.y + (radius - lineWidth) * sinf(CC_DEGREES_TO_RADIANS(degree + degreeSeg * (i - 1)));
        strokeLineVertices[(i - 1) * 4 + 2] = center.x + radius * cosf(CC_DEGREES_TO_RADIANS(degree + degreeSeg * (i - 1)));
        strokeLineVertices[(i - 1) * 4 + 3] = center.y + radius * sinf(CC_DEGREES_TO_RADIANS(degree + degreeSeg * (i - 1)));
        
        strokeColorVertices[(i - 1) * 2] = strokeColor;
        strokeColorVertices[(i - 1) * 2 + 1] = strokeColor;
        
        innerStrokeLineVertices[(i - 1) * 4] = center.x + (radius - lineWidth - overdraw) * cosf(CC_DEGREES_TO_RADIANS(degree + degreeSeg * (i - 1)));
        innerStrokeLineVertices[(i - 1) * 4 + 1] = center.y + (radius - lineWidth - overdraw) * sinf(CC_DEGREES_TO_RADIANS(degree + degreeSeg * (i - 1)));
        innerStrokeLineVertices[(i - 1) * 4 + 2] = center.x + (radius - lineWidth) * cosf(CC_DEGREES_TO_RADIANS(degree + degreeSeg * (i - 1)));
        innerStrokeLineVertices[(i - 1) * 4 + 3] = center.y + (radius - lineWidth) * sinf(CC_DEGREES_TO_RADIANS(degree + degreeSeg * (i - 1)));
        
        innerStrokeColorVertices[(i - 1) * 2] = strokeTransColor;
        innerStrokeColorVertices[(i - 1) * 2 + 1] = strokeColor;
        
    }
    
    if (color.a > 0) {
        
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_POSITION, 2, GL_FLOAT, GL_FALSE, 0, lineVertices);
        glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_FLOAT, GL_FALSE, 0, colorVertices);
        glDrawArrays(GL_TRIANGLE_FAN, 0, seg + 2);
        
    }
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_POSITION, 2, GL_FLOAT, GL_FALSE, 0, outerStrokeLineVertices);
    glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_FLOAT, GL_FALSE, 0, outerStrokeColorVertices);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (seg + 1) * 2);
    
    if (shouldStroke) {
        
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_POSITION, 2, GL_FLOAT, GL_FALSE, 0, strokeLineVertices);
        glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_FLOAT, GL_FALSE, 0, strokeColorVertices);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, (seg + 1) * 2);
        
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_POSITION, 2, GL_FLOAT, GL_FALSE, 0, innerStrokeLineVertices);
        glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_FLOAT, GL_FALSE, 0, innerStrokeColorVertices);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, (seg + 1) * 2);
        
        if (ltc) {
            drawLine(Point(lineVertices[0], lineVertices[1]), Point(lineVertices[2], lineVertices[3]), lineWidth, strokeColor);
            drawLine(Point(lineVertices[0], lineVertices[1]), Point(lineVertices[(seg + 1) * 2], lineVertices[(seg + 1) * 2 + 1]), lineWidth, strokeColor);
        }

    }
    
    free(lineVertices);
    free(colorVertices);
    
    free(outerStrokeLineVertices);
    free(outerStrokeColorVertices);
    free(strokeLineVertices);
    free(strokeColorVertices);
    free(innerStrokeLineVertices);
    free(innerStrokeColorVertices);
}


