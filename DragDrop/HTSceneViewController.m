//
//  ViewController.m
//  DragDrop
//
//  Created by Main Account on 9/4/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "HTSceneViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MainScene.h"

@interface HTSceneViewController ()
@property (nonatomic) AVAudioPlayer *backgroundMusicPlayer;
@end

@implementation HTSceneViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    NSError *error;
    NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"background-music-aac" withExtension:@"caf"];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    self.backgroundMusicPlayer.numberOfLoops = -1;
    [self.backgroundMusicPlayer prepareToPlay];
    [self.backgroundMusicPlayer play];
    
    // Configure the view.
    SKView *skView = (SKView *)self.view;
    if (!skView.scene) {
      skView.showsFPS = YES;
      skView.showsNodeCount = YES;
      
      // Create and configure the scene.
      SKScene *scene = [MainScene sceneWithSize:skView.bounds.size];
      scene.scaleMode = SKSceneScaleModeResizeFill;
      
      // Present the scene.
      [skView presentScene:scene];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.backgroundMusicPlayer stop];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
