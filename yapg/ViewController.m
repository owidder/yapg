//
//  ViewController.m
//  yapg
//
//  Created by Oliver Widder on 8/18/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import "BrickScene.h"
#import "MenuScene.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    BrickScene *brickScene = [BrickScene sceneWithSize:skView.bounds.size];
    brickScene.scaleMode = SKSceneScaleModeAspectFill;
    
    MenuScene *menuScene = [MenuScene sceneWithSize:skView.bounds.size];
    menuScene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:menuScene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
