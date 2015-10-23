/****************************************************************************
 Copyright (c) 2013      cocos2d-x.org
 Copyright (c) 2013-2014 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import "RootViewController.h"
#import "cocos2d.h"
#import "platform/ios/CCEAGLView-ios.h"
#import "NativeHelper.h"
#include "SimpleAudioEngine.h"

@implementation RootViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

}

*/

// Override to allow orientations other than the default portrait orientation.
// This method is deprecated on ios6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape( interfaceOrientation );
}

// For ios6, use supportedInterfaceOrientations & shouldAutorotate instead
- (NSUInteger) supportedInterfaceOrientations{
#ifdef __IPHONE_6_0
    return UIInterfaceOrientationMaskAllButUpsideDown;
#endif
}
- (void)showParentSection{
    if (!_popup) {
        _popup = [[IDEOPopUpGate alloc] initWithFrame:self.view.bounds];
        _popup.delegate = self;
    }

    [_popup showInView:self.view];
}

- (void)showMoreFunAppsButton {
    if (moreFunAppButton) {
        [moreFunAppButton appear];
        return;
    }
    moreFunAppButton = [[IDEOMoreFunAppView alloc] init];
    moreFunAppButton.delegate            = self;
    moreFunAppButton.appearCorner        = kIDEOMoreFunAppViewAnimateLowerRightCorner;
    moreFunAppButton.animateDirection    = kIDEOMoreFunAppViewAnimateDirectionUp;
    
    [self.view addSubview:moreFunAppButton];

}

- (void)hideMoreFunAppsButton {
//    [moreFunAppButton disappear];
    [moreFunAppButton removeFromSuperview];
    moreFunAppButton = nil;
}

- (void)dismissParentSection {
    [[IDEOParentsSectionLib sharedInstance] dismissParentsSecionWithController:self];
    CocosDenshion::SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}

- (void)popupGateDidEnterCorrectAnswer
{
    [[IDEOParentsSectionLib sharedInstance] setDelegate:self];
    [[IDEOParentsSectionLib sharedInstance] showParentsSecionWithController:self];
    CocosDenshion::SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

- (void)parentsSectionDidDismiss {
    CocosDenshion::SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    auto glview = cocos2d::Director::getInstance()->getOpenGLView();

    if (glview)
    {
        CCEAGLView *eaglview = (CCEAGLView*) glview->getEAGLView();

        if (eaglview)
        {
            CGSize s = CGSizeMake([eaglview getWidth], [eaglview getHeight]);
            cocos2d::Application::getInstance()->applicationScreenSizeChanged((int) s.width, (int) s.height);
        }
    }
}

//fix not hide status on ios7
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    if (_popup) {
        [_popup release];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [super dealloc];
}


- (void)prepareVideo {
    CGFloat screenRatio = LONG_SIDE / SHORT_SIDE;
    NSString *videoName = @"splash4x3";
    
    if (screenRatio >= 1.5) {
        videoName = @"splash16x9";
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:videoName ofType:@"mp4"];
    NSURL *sourceMovieURL = [NSURL fileURLWithPath:filePath];
    
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    _player = [AVPlayer playerWithPlayerItem:playerItem];
//    [_player addObserver:self forKeyPath:@"status" options:0 context:nil];
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avplayerItemPlayFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    if (screenRatio == 1.5) {
        playerLayer.frame = CGRectMake(-44, 0, 568, 320);
    } else {
        playerLayer.frame = self.view.layer.bounds;
    }
    
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    
    
    [self.view.layer addSublayer:playerLayer];
    
    [self performSelector:@selector(removeFlickCover) withObject:nil afterDelay:0.7];
    
//    [_player play];
}

- (void)removeFlickCover {
    NativeEvent e;
    e.listenerId = self.listenerId;
    e.state = 1;
    
    NativeHelper::getInstance()->dispatchNativeEvent(e);
}

- (void)playVideo {
    [_player play];
}

- (void)avplayerItemPlayFinish:(NSNotification*)noti{
    [self dismissVideo];
}

- (void)moreFunAppViewDidClick:(IDEOMoreFunAppView *)moreFunAppView
{
    [[IDEOParentsSectionLib sharedInstance] showMoreFunAppsWithController:self];
    CocosDenshion::SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

- (void)moreFunAppViewDidClose:(IDEOMoreFunAppView *)moreFunAppView {
    CocosDenshion::SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}

- (void)dismissVideo
{
    NativeEvent e;
    e.listenerId = self.listenerId;
    e.state = 2;
    
    NativeHelper::getInstance()->dispatchNativeEvent(e);
    
    if (playerLayer) {
        [playerLayer removeFromSuperlayer];
        playerLayer = nil;
    }
    
    if (_player) {
        _player = nil;
    }
    
}


@end
