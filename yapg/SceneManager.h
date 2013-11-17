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
    kBrickScene = 2,
    kPauseScene = 3
} SceneType;

@interface SceneManager : NSObject

+(SceneManager *)instance;

// clear scene stack and change scene to the given scene type
-(void)changeSceneToSceneType:(SceneType)sceneType fromCurrentScene:(SKScene *)currentScene;
// gosub into the given scene
-(void)gosubIntoSceneWithType:(SceneType)sceneType fromCurrentScene:(SKScene *)currentScene;
// resume from the current scene and go back to scene on top of stack
-(void)resume;



@property SKView* view;

@end
