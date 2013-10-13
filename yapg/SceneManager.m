//
//  SceneManager.m
//  yapg
//
//  Created by Oliver Widder on 10/13/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "SceneManager.h"

#import "MenuScene.h"
#import "BrickScene.h"
#import "ErrorScene.h"
#import "PauseScene.h"

#import "drawutil.h"

@interface SceneManager () {
    NSMutableArray *stack;
}

-(SKScene *)createSceneFromType:(SceneType)type;

-(void)presentScene:(SKScene *)scene;

-(void)clearSceneStack;
-(void)pushSceneOnStack:(SKScene *)scene;
-(SKScene *)popSceneFromStack;

@end

@implementation SceneManager

@synthesize view = _view;

+(SceneManager*)instance {
    static SceneManager *instance = NULL;
    
    @synchronized(self) {
        if(instance == NULL) {
            instance = [[SceneManager alloc] init];
        }
    }
    
    return instance;
}

-(id)init:(SKView *)view {
    if(self = [super init]) {
        stack = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark private

-(SKScene *)createSceneFromType:(SceneType)type {
    SKScene *scene;
    
    CGSize sceneSize = DefaultSceneSize().size;
    
    switch (type) {
        case kMenuScene:
            scene = [MenuScene sceneWithSize:sceneSize];
            break;
            
        case kBrickScene:
            scene = [BrickScene sceneWithSize:sceneSize];
            break;
            
        case kPauseScene:
            scene = [PauseScene sceneWithSize:sceneSize];
            break;
            
        default:
            scene = [ErrorScene sceneWithSize:sceneSize];
    }
    
    return scene;
}

-(void)clearSceneStack {
    [stack removeAllObjects];
}

-(void)pushSceneOnStack:(SKScene *)scene {
    [stack addObject:scene];
}

-(SKScene *)popSceneFromStack {
    SKScene *topOfStack = [stack objectAtIndex:[stack count]-1];
    [stack removeLastObject];
    
    return topOfStack;
}

-(void)presentScene:(SKScene *)scene {
    [self.view presentScene:scene];
}

#pragma mark SceneManager

-(void)changeScene:(SceneType)sceneType {
    [self clearSceneStack];
    [self pushScene:sceneType];
}

-(void)pushScene:(SceneType)sceneType {
    SKScene *newScene = [self createSceneFromType:sceneType];
    [self pushSceneOnStack:newScene];
    
    [self presentScene:newScene];
}

-(void)popScene {
    SKScene *nextScene = [self popSceneFromStack];
    
    [self presentScene:nextScene];
}

@end
