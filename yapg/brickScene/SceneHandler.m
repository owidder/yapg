//
//  SceneHandler.m
//  yapg
//
//  Created by Oliver Widder on 24/12/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "SceneHandler.h"
#import "TouchHandler.h"
#import "SceneManager.h"

@interface SceneHandler ()

@property SKScene *scene;

@end

@implementation SceneHandler

-(id)initWithScene:(SKScene *)scene {
    if(self = [super init]) {
        self.scene = scene;
    }
    
    return self;
}

-(BOOL)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL processed = NO;

    if([touches count] > 1) {
        // multitouch --> pause game
        [[SceneManager instance] gosubIntoSceneWithType:kPauseScene fromCurrentScene:self.scene];
        processed = YES;
    }

    return processed;
}

@end
