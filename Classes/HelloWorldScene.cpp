#include "HelloWorldScene.h"
#include "HueSprite.h"
#include "JsonSprite.h"

USING_NS_CC;

Scene* HelloWorld::createScene()
{
    // 'scene' is an autorelease object
    auto scene = Scene::create();
    
    // 'layer' is an autorelease object
    auto layer = HelloWorld::create();

    // add layer as a child to scene
    scene->addChild(layer);

    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
bool HelloWorld::init()
{
    if ( !Layer::init() )
    {
        return false;
    }
    Size visibleSize = Director::getInstance()->getVisibleSize();
    Vec2 origin = Director::getInstance()->getVisibleOrigin();
    
    auto sprite = Sprite::create("images/iPad/Space.png");
    sprite->setPosition(Vec2(visibleSize.width/2 + origin.x, visibleSize.height/2 + origin.y));
    this->addChild(sprite, 0);
    
    auto p = ParticleSystemQuad::create("particles/aurora.plist");
    p->setScale(4.0);
    p->setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height + 230);
    addChild(p);

//    runAction(Sequence::create(
//                               DelayTime::create(1.0),
//                               CallFunc::create(std::bind(&HelloWorld::test, this)),
//                               NULL));
    
    auto spaceship = Sprite::create("Spaceship.png");
//    spaceship->setScale(2.0);
    spaceship->setPosition(origin.x + visibleSize.width / 2 - 600, origin.y + visibleSize.height / 2 + 500);
    
    spaceship->runAction(Sequence::create(
                                          Spawn::create(
                                                        ScaleTo::create(0.6, 2.0),
                                                        MoveTo::create(0.6, Point(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2 + 280)),
                                                        RotateBy::create(0.6, 20),
                                                        NULL),
                                          RotateBy::create(0.1, -25),
                                          RotateBy::create(0.1, 5),
                                          CallFunc::create(std::bind(&HelloWorld::showEggs, this)),
                                          Spawn::create(
                                                        MoveBy::create(2.0, Point(0, -100)),
                                                        RotateBy::create(1.0, -3.0),
                                                        NULL),
                                          Spawn::create(
                                                        RotateBy::create(0.6, 53),
                                                        MoveBy::create(1.2, Point(origin.x + visibleSize.width + 300, origin.y + visibleSize.height + 200)),
                                                        ScaleTo::create(1.2, 0.5),
                                                        NULL),
                                          NULL));
    addChild(spaceship, 10);

    
    return true;
}


void HelloWorld::menuCloseCallback(Ref* pSender)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WP8) || (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
	MessageBox("You pressed the close button. Windows Store Apps do not implement a close button.","Alert");
    return;
#endif

    Director::getInstance()->end();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    exit(0);
#endif
}

void HelloWorld::test()
{
    JsonSprite* sprite = (JsonSprite*)getChildByTag(200);
    if (sprite) {
        sprite->setHue(0.5);
        sprite->playAction("blow");
    }
}

void HelloWorld::showEggs()
{
    Size visibleSize = Director::getInstance()->getVisibleSize();
    Vec2 origin = Director::getInstance()->getVisibleOrigin();
    
    float eggOffX = 90;
    auto blob = JsonSprite::createWithConfigFile("actors/blob/blob.json");
    
    blob->setPosition(origin.x + visibleSize.width / 2 + eggOffX, origin.y + visibleSize.height / 2 + 300);
    blob->setTag(101);
    addChild(blob);
    
    blob->runAction(MoveTo::create(0.5, Point(origin.x + visibleSize.width / 2 + eggOffX - 400, origin.y + visibleSize.height / 2 - 200)));
}
