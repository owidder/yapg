//
//  SceneManager.h
//  yapg
//
//  Created by Oliver Widder on 10/13/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
    kMenuScene = 1,
    kBrickScene = 2
} SceneType;

@interface SceneManager : NSObject

+(SceneManager *)instance;

-(void)changeScene:(SceneType)sceneType;
-(void)pushScene:(SceneType)sceneType;
-(void)popScene;

@property SKView* view;

@end
