//
//  JsonSprite.cpp
//  MonsterMove
//
//  Created by Zhou Yang on 15/1/19.
//
//

#include "JsonSprite.h"
#include "json/rapidjson.h"
#include "json/document.h"
//#include "HueSprite.h"
#include "SimpleAudioEngine.h"
#include "Constants.h"
#include "GameManager.h"
#include "Utils.h"

JsonSprite* JsonSprite::create(const std::string& filename)
{
    JsonSprite *sprite = new (std::nothrow) JsonSprite();
    if (sprite && sprite->initWithConfigFile(filename))
    {
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}

JsonSprite* JsonSprite::create(const std::string& filename, const std::string& defaultAction)
{
    JsonSprite *sprite = new (std::nothrow) JsonSprite();
    if (sprite && sprite->initWithConfigFile(filename, defaultAction))
    {
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}

bool JsonSprite::initWithConfigFile(const std::string &filename)
{
    return initWithConfigFile(filename, "");
}

bool JsonSprite::initWithConfigFile(const std::string &filename, const std::string& defaultAction)
{
    
    if (!Sprite::init()) {
        return false;
    }
    
    m_lastPlayTime = 0;
    
    m_hue = 0.0;
    
    m_silenceMode = false;

    rapidjson::Document doc;
    std::string fileData = FileUtils::getInstance()->getStringFromFile(filename);
    doc.Parse<0>(fileData.c_str());
    m_name = doc["name"].GetString();
    
    std::string basePath = "actors/" + m_name + "/";
    
    std::string loadAction = defaultAction;
    if (loadAction.empty() && doc.HasMember("defaultAction")) {
        loadAction = doc["defaultAction"].GetString();
    }
    
    if (doc.HasMember("backgroundSound"))
    {
        m_backgroundSound = doc["backgroundSound"].GetString();
    }
    
    if (doc.HasMember("selectedEffect"))
    {
        m_selectedEffect = doc["selectedEffect"].GetString();
    }
    
    if (doc.HasMember("backgroundColor"))
    {
        rapidjson::Value &backgroundColor = doc["backgroundColor"];
        m_backgroundColor.r = backgroundColor["r"].GetInt();
        m_backgroundColor.g = backgroundColor["g"].GetInt();
        m_backgroundColor.b = backgroundColor["b"].GetInt();
        m_backgroundColor.a = backgroundColor["a"].GetInt();
    }
    
    if (doc.HasMember("circleColor"))
    {
        rapidjson::Value &color = doc["circleColor"];
        m_circleColor.r = color["r"].GetInt();
        m_circleColor.g = color["g"].GetInt();
        m_circleColor.b = color["b"].GetInt();
        m_circleColor.a = color["a"].GetInt();
    }
    
    if (doc.HasMember("tileColor"))
    {
        rapidjson::Value &color = doc["tileColor"];
        m_tileColor.r = color["r"].GetInt();
        m_tileColor.g = color["g"].GetInt();
        m_tileColor.b = color["b"].GetInt();
        m_tileColor.a = color["a"].GetInt();
    }
    
    if (doc.HasMember("starColor"))
    {
        rapidjson::Value &color = doc["starColor"];
        m_starColor.r = color["r"].GetInt();
        m_starColor.g = color["g"].GetInt();
        m_starColor.b = color["b"].GetInt();
        m_starColor.a = color["a"].GetInt();
    }
    
    if (doc.HasMember("touchArea"))
    {
        rapidjson::Value &touchArea = doc["touchArea"];
        m_touchArea.origin.x = touchArea["x"].GetDouble();
        m_touchArea.origin.y = touchArea["y"].GetDouble();
        m_touchArea.size.width = touchArea["width"].GetDouble();
        m_touchArea.size.height = touchArea["height"].GetDouble();
    } else {
        m_touchArea.origin = Point::ZERO;
        m_touchArea.size = getContentSize();
    }
    
    if (doc.HasMember("touchArea2"))
    {
        rapidjson::Value &touchArea = doc["touchArea2"];
        m_touchArea2.origin.x = touchArea["x"].GetDouble();
        m_touchArea2.origin.y = touchArea["y"].GetDouble();
        m_touchArea2.size.width = touchArea["width"].GetDouble();
        m_touchArea2.size.height = touchArea["height"].GetDouble();
    } else {
        m_touchArea2.origin = Point::ZERO;
        m_touchArea2.size = getContentSize();
    }
    
    if (doc.HasMember("feetOffset"))
    {
        m_feetOffset = doc["feetOffset"].GetDouble();
    } else {
        m_feetOffset = 0.0;
    }
    
    if (doc.HasMember("pixelFormat"))
    {
        rapidjson::Value &pixelFormat = doc["pixelFormat"];
        if (pixelFormat.GetInt() == 4) {
            m_pixelFormat = Texture2D::PixelFormat::RGBA4444;
        } else {
            m_pixelFormat = Texture2D::PixelFormat::RGBA8888;
        }
    } else {
        m_pixelFormat = Texture2D::PixelFormat::RGBA8888;
    }
    
    if (doc.HasMember("actions")) {
        rapidjson::Value &actionDocArray = doc["actions"];
        if (actionDocArray.IsArray())
        {
            for (rapidjson::SizeType i = 0; i < actionDocArray.Size(); i++)
            {
                rapidjson::Value& actionDoc = actionDocArray[i];
                ActionData ad;
                ad.actionName = actionDoc["name"].GetString();

                if (actionDoc.HasMember("realName"))
                {
                    ad.realName = actionDoc["realName"].GetString();
                } else {
                    ad.realName = ad.actionName;
                }
                
                if (actionDoc.HasMember("filePrefix"))
                {
                    ad.filePrefix = actionDoc["filePrefix"].GetString();
                } else {
                    ad.filePrefix = m_name;
                }
                ad.frameStart = actionDoc["frameStart"].GetInt();
                ad.frameEnd = actionDoc["frameEnd"].GetInt();
                ad.repeat = actionDoc["repeat"].GetInt();
                if (actionDoc.HasMember("framerate"))
                {
                    ad.framerate = actionDoc["framerate"].GetDouble();
                } else {
                    ad.framerate = 20.0;
                }
                if (actionDoc.HasMember("soundEffect"))
                {
                    ad.soundEffect = actionDoc["soundEffect"].GetString();
                    CocosDenshion::SimpleAudioEngine::getInstance()->preloadEffect(ad.soundEffect.c_str());
                }
                if (actionDoc.HasMember("type"))
                {
                    ad.type = actionDoc["type"].GetInt();
                } else {
                    ad.type = 0;
                }
                
                if (actionDoc.HasMember("followedAction"))
                {
                    ad.followedAction = actionDoc["followedAction"].GetString();
                }
                
                m_actions[ad.actionName] = ad;
                
                if (ad.actionName == loadAction) {
                    // initial the inner sprite;
                    m_currentActorHolder = addBatchNode(m_name, loadAction, ad.frameStart, ad.frameEnd);
                    m_actorHolders[loadAction]->setVisible(true);
                }
            }
        }
    }
    
    return true;
}

void JsonSprite::playAction(std::string actionName)
{
    playActionWithDirection(actionName, false);
}

void JsonSprite::playActionReverse(std::string actionName)
{
    playActionWithDirection(actionName, true);
}

void JsonSprite::playActionWithDirection(std::string actionName, bool reverse)
{
    ActionData action = m_actions[actionName];

    m_nextActionHolder = m_actorHolders[actionName];
    
    if (!m_nextActionHolder) {
        m_nextActionHolder = addBatchNode(m_name, actionName, action.frameStart, action.frameEnd);
    } else {
        std::string textureFile = "actors/" + m_name + "/" + actionName + ".png";
        
        auto texture = Director::getInstance()->getTextureCache()->getTextureForKey(textureFile);
        if (!texture) {
            CCLOG("Missing texture : %s", textureFile.c_str());
            m_nextActionHolder->removeFromParent();
            m_nextActionHolder = addBatchNode(m_name, actionName, action.frameStart, action.frameEnd);
        }        
    }

    char filename[100];
    
    Sprite* currentInnerActor = (Sprite*)m_currentActorHolder->getChildByTag(TILE_INNER_ACTOR_TAG);
    
    if (currentInnerActor) {
        currentInnerActor->stopAllActions();
    }

    Sprite *innerActor = (Sprite*)m_nextActionHolder->getChildByTag(TILE_INNER_ACTOR_TAG);
    sprintf(filename, "%s%04d.png", m_name.c_str(), action.frameStart);
    if (!innerActor) {
        innerActor = Sprite::createWithSpriteFrameName(filename);
        innerActor->setBlendFunc(BlendFunc::ALPHA_PREMULTIPLIED);
        innerActor->setPosition(Point::ZERO);
        innerActor->setTag(TILE_INNER_ACTOR_TAG);
        m_nextActionHolder->addChild(innerActor);
    } else {
        innerActor->stopAllActions();
        innerActor->setTexture(SpriteFrameCache::getInstance()->getSpriteFrameByName(filename)->getTexture());
    }
    
    
    if (m_currentActorHolder != m_nextActionHolder) {
        m_currentActorHolder->setZOrder(0);
        m_nextActionHolder->setZOrder(1);
        m_nextActionHolder->setVisible(true);
        m_currentActorHolder->setVisible(false);
        m_currentActorHolder = m_nextActionHolder;
        
        currentInnerActor->removeFromParent();
        
//        if (currentInnerActor && !m_currentActionName.empty()) {
//            ActionData oldAction = m_actions[m_currentActionName];
//            sprintf(filename, "%s%04d.png", m_name.c_str(), oldAction.frameStart);
//            currentInnerActor->setTexture(SpriteFrameCache::getInstance()->getSpriteFrameByName(filename)->getTexture());
//            CCLOG("%s %s reset to frame %d", m_name.c_str(), m_currentActionName.c_str(), oldAction.frameStart);
//        }

    }
    
    setHue(m_hue);
//    CCLOG("Frag shader log : %s", m_currentActorHolder->getGLProgram()->getFragmentShaderLog().c_str());
    
    m_currentActionName = actionName;
    
    Vector<SpriteFrame *> spriteFrames;
    
    Size screenSize = Director::getInstance()->getOpenGLView()->getFrameSize();
    
    if (reverse) {
        for(int i = action.frameEnd; i >= action.frameStart; i--)
        {
            sprintf(filename, "%s%04d.png", m_name.c_str(), i);
            auto frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(filename);;
            spriteFrames.pushBack(frame);
        }
    } else {
        for(int i = action.frameStart; i <= action.frameEnd; i++)
        {
            sprintf(filename, "%s%04d.png", m_name.c_str(), i);
            auto frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(filename);;
            spriteFrames.pushBack(frame);
        }
    }
    auto animation = Animation::createWithSpriteFrames(spriteFrames);
    CCLOG("action framerate : %f", action.framerate);
    
    float delayPerUnit = 1.0 / 15;
    int frameCount = action.frameEnd - action.frameStart + 1;
    
    if (Utils::startsWith(actionName, "dance")) {
        delayPerUnit = (PACE_TIME - 0.2) / frameCount;
    }
    animation->setDelayPerUnit(delayPerUnit);
    
    unsigned long long t = Utils::timeInMillisecond();
    unsigned long long tDiff = t - m_lastPlayTime;
    m_lastPlayTime = t;
//    CCLOG("%s is playing %s, %s, %d", m_name.c_str(), action.actionName.c_str(), action.realName.c_str(), (action.frameEnd - action.frameStart + 1));
    CCLOG("%s is playing %s, %s, %d, %f, %lld", m_name.c_str(), action.actionName.c_str(), action.realName.c_str(), (action.frameEnd - action.frameStart + 1), animation->getDelayPerUnit(), tDiff);
    

    animation->setDelayPerUnit(1.0 / action.framerate);
    
    Animate* animate = Animate::create(animation);
//    Animate* animate = m_animates[actionName];
    if (action.repeat <= 0) {
        innerActor->runAction(RepeatForever::create(animate));
    } else if (action.repeat == 1) {
        innerActor->runAction(Sequence::create(
                                   animate,
                                   CallFunc::create(std::bind(&JsonSprite::actionStopped, this)),
                                   NULL));
    } else {
        innerActor->runAction(Repeat::create(animate, action.repeat));
    }
    
    if (!m_silenceMode && !action.soundEffect.empty()) {
        if (m_soundId) {
            CocosDenshion::SimpleAudioEngine::getInstance()->stopEffect(m_soundId);
        }
        m_soundId = CocosDenshion::SimpleAudioEngine::getInstance()->playEffect(action.soundEffect.c_str());
    }

}

Rect JsonSprite::getTouchAreaInParent()
{
    Rect r;
    Size screenSize = Director::getInstance()->getOpenGLView()->getFrameSize();
    if (screenSize.width <= 1024.0) {
        r.origin = Point(getPosition().x - (getContentSize().width * getAnchorPoint().x * getScaleX()),
                         getPosition().y - getContentSize().height * getAnchorPoint().y * getScaleY()) +
        Point(m_touchArea2.origin.x * getScaleX(), m_touchArea2.origin.y * getScaleY());
        
        r.size = Size(m_touchArea2.size.width * getScaleX(), m_touchArea2.size.height * getScaleY());
    } else {
        r.origin = Point(getPosition().x - (getContentSize().width * getAnchorPoint().x * getScaleX()),
                         getPosition().y - getContentSize().height * getAnchorPoint().y * getScaleY()) +
                    Point(m_touchArea.origin.x * getScaleX(), m_touchArea.origin.y * getScaleY());
        
        r.size = Size(m_touchArea.size.width * getScaleX(), m_touchArea.size.height * getScaleY());
    }
    return r;
}

void JsonSprite::actionStopped()
{
    ActionData ad = m_actions[m_currentActionName];
    if (!ad.followedAction.empty()) {
        playAction(ad.followedAction);
    }
    
    if (m_delegate && !m_stopped) {
        m_delegate->actionStopped(this);
    }
}

SpriteBatchNode* JsonSprite::addBatchNode(std::string actorName, std::string actionName, int start, int end)
{
    char filename[100];
    sprintf(filename, "actors/%s/%s.png", actorName.c_str(), actionName.c_str());
    
    Texture2D *texture = Director::getInstance()->getTextureCache()->addImage(filename);
    
    auto actorHolder = SpriteBatchNode::createWithTexture(texture, 1);
    
    auto shader = new GLProgram();
    shader->initWithFilenames("ccPositionTextureColor.vert", "hueAdjust.frag");

    actorHolder->setGLProgram(shader);
    
    actorHolder->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
    actorHolder->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
    actorHolder->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORDS);
    actorHolder->getGLProgram()->link();
    actorHolder->getGLProgram()->updateUniforms();
    actorHolder->getGLProgram()->setUniformLocationWith1f(getGLProgram()->getUniformLocation("hueAdjust"), 0.0);

    sprintf(filename, "actors/%s/%s.plist", actorName.c_str(), actionName.c_str());
    SpriteFrameCache::getInstance()->removeSpriteFramesFromFile(filename);
    SpriteFrameCache::getInstance()->addSpriteFramesWithFile(filename, texture);
    
    Size screenSize = Director::getInstance()->getOpenGLView()->getFrameSize();
    
    sprintf(filename, "%s%04d.png", actorName.c_str(), start);
    auto actor = Sprite::createWithSpriteFrameName(filename);
    if (getContentSize().width <= actor->getContentSize().width || getContentSize().height < actor->getContentSize().height) {
        setContentSize(actor->getContentSize());
    }
    
//    actor->setPosition(Point(getContentSize() / 2));
    
    actor->setBlendFunc(BlendFunc::ALPHA_PREMULTIPLIED);
    
    actor->setPosition(Point::ZERO);
    
    actor->setTag(TILE_INNER_ACTOR_TAG);
    
//    CCLOG("Load %s action : %s", m_name.c_str(), action.c_str());
    
    actorHolder->addChild(actor);
    
    actorHolder->setVisible(false);
    
    actorHolder->setPosition(Point(getContentSize().width / 2.0, getContentSize().height / 2.0));
    
    addChild(actorHolder);
    
    m_actorHolders[actionName] = actorHolder;
    
//    ActionData action = m_actions[actionName];
//
//    Vector<SpriteFrame *> spriteFrames;
//
//    for(int i = action.frameStart; i <= action.frameEnd; i++)
//    {
//        sprintf(filename, "%s%04d.png", m_name.c_str(), i);
//        auto frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(filename);;
//        spriteFrames.pushBack(frame);
//    }
//    auto animation = Animation::createWithSpriteFrames(spriteFrames);
//
//    float delayPerUnit = 1.0 / 15;
//    int frameCount = action.frameEnd - action.frameStart + 1;
//    
//    if (Utils::startsWith(actionName, "dance")) {
//        delayPerUnit = (PACE_TIME - 0.2) / frameCount;
//    }
//    animation->setDelayPerUnit(delayPerUnit);
//
//    Animate* animate = Animate::create(animation);
//    animate->retain();
//
//    m_animates[actionName] = animate;
    
    return actorHolder;
}

void JsonSprite::preloadActions(std::vector<std::string> actions)
{
    m_preloadActions.clear();
    m_preloadActions = actions;
    for(std::vector<std::string>::iterator iter = m_preloadActions.begin(); iter != m_preloadActions.end(); ++iter)
    {
        std::string actionName = *iter;
        std::string n = "actors/" + m_name + "/" + actionName + ".png";
//        CCLOG("Preload %s action : %s ", m_name.c_str(), n.c_str());
        Director::getInstance()->getTextureCache()->addImageAsync(n, CC_CALLBACK_1(JsonSprite::imageLoaded, this));
    }
}

void JsonSprite::imageLoaded(cocos2d::Texture2D *texture)
{
    if (m_cancelLoading) return;
    for(std::vector<std::string>::iterator iter = m_preloadActions.begin(); iter != m_preloadActions.end(); ++iter)
    {
        std::string actionName = *iter;
        SpriteBatchNode* actorHolder = m_actorHolders[actionName];
        if (!actorHolder) {
            // test to load;
            std::string n = "actors/" + m_name + "/" + actionName + ".png";
            Texture2D *texture = Director::getInstance()->getTextureCache()->getTextureForKey(n);
            
            if (texture != nullptr)
            {
                //ready to load
//                CCLOG("Image loaded %s action : %s ", m_name.c_str(), n.c_str());
                ActionData ad = m_actions[actionName];
                addBatchNode(m_name, actionName, ad.frameStart, ad.frameEnd);
                if (m_delegate) {
                    m_delegate->actionPreloaded(actionName);
                }
            }
        } else {
//            CCLOG("Already loaded some where else : %s", actionName.c_str());
//            if (m_delegate) {
//                m_delegate->actionPreloaded(actionName);
//            }
        }
    }
}

void JsonSprite::setHue(float h)
{
    m_hue = h;
    if (m_currentActorHolder->getGLProgram()) {
        m_currentActorHolder->getGLProgram()->updateUniforms();
        m_currentActorHolder->getGLProgram()->setUniformLocationWith1f(m_currentActorHolder->getGLProgram()->getUniformLocation("hueAdjust"), h);
    }
}

void JsonSprite::stopPerform()
{
    m_stopped = true;
    stopAllActions();
}

void JsonSprite::clearAssets(bool reserveSequence)
{
    for(std::unordered_map<std::string, SpriteBatchNode*>::iterator it = m_actorHolders.begin(); it != m_actorHolders.end(); it++)
    {
        std::string n = it->first;
        clearAction(n, reserveSequence);
    }
}

void JsonSprite::clearUnusedAssets()
{
    for(std::unordered_map<std::string, SpriteBatchNode*>::iterator it = m_actorHolders.begin(); it != m_actorHolders.end(); it++)
    {
        std::string n = it->first;
        clearAction(n, true);
    }
}

void JsonSprite::clearAction(std::string actionName, bool reserveIfInSequence)
{
    GameManager *gm = GameManager::getInstance();
    ActorData ad;
    if (gm->m_currentActorIndex >= 0 && gm->m_currentActorIndex < 3) {
        ad = gm->m_currentActors[gm->m_currentActorIndex];
    }

    SpriteBatchNode* actorHolder = m_actorHolders[actionName];
    if (actorHolder && actionName != m_currentActionName)
    {
        bool foundInSequence = false;
        
        if (ad.name == m_name && reserveIfInSequence) {
            for(int i = 0; i < 4; i++){
                if (actionName == ad.sequence[i]) {
                    foundInSequence = true;
                    break;
                }
            }
        }
        
        std::string filename = "actors/" + m_name + "/" + actionName + ".png";
        if (!foundInSequence) {
            
            actorHolder->removeAllChildren();
            actorHolder->removeFromParent();
            
//            Animate *animate = m_animates[actionName];
//            m_animates.erase(actionName);
//            animate->release();
            
            Texture2D *texture = Director::getInstance()->getTextureCache()->getTextureForKey(filename);
            if (texture) {
                SpriteFrameCache::getInstance()->removeSpriteFramesFromTexture(texture);
            }
            Director::getInstance()->getTextureCache()->removeTexture(texture);
            
            CCLOG("Cleared : %s of %s", filename.c_str(), m_name.c_str());
            m_actorHolders[actionName] = NULL;
        } else {
            CCLOG("Reserved : %s", filename.c_str());
        }
        
    }
}

void JsonSprite::onExit()
{
    for(std::unordered_map<std::string, SpriteBatchNode*>::iterator it = m_actorHolders.begin(); it != m_actorHolders.end(); it++)
    {
        std::string n = it->first;
        clearAction(n, false);
    }
//    m_animates.clear();
    m_actorHolders.clear();
    CCLOG("Cleared ALL actorHolders of : %s", m_name.c_str());
    Sprite::onExit();
}
