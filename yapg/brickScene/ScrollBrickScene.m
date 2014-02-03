//
//  ScrollBrickScene.m
//  yapg
//
//  Created by Oliver Widder on 26/11/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "ScrollBrickScene.h"
#import "SceneManager.h"
#import "BrickDrawer.h"
#import "SceneHandler.h"
#import "Field.h"
#import "Ball.h"
#import "Stuff.h"

#import "drawutil.h"

#define STUFF_NAME @"stuff"

@interface ScrollBrickScene()

-(void)dropBall;
-(void)addStuff;
-(void)collisionWithStuff:(Stuff *)stuff andRandomWait:(BOOL)doRandomWait;

-(void)scroll;
-(void)ballPostProcessing;

@property BrickDrawer *brickDrawer;
@property SceneHandler *sceneHandler;
@property CGPoint positionWhereTouchBegan;

@property NSTimer *stuffTimer;
@property NSTimer *ballTimer;

@end

@implementation ScrollBrickScene

-(id)initWithSize:(CGSize)size {
    if(self = [super initWithSize:size]) {
        [Field setEdgesFlag:NO];
        
        self.physicsWorld.contactDelegate = self;
        
        self.brickDrawer = [[BrickDrawer alloc] initWithScene:self];
        self.sceneHandler = [[SceneHandler alloc] initWithScene:self];
        
        [self addChild:[Field instance]];
        
        [self dropBall];
        [self addStuff];

//        float randomTime = RandomFloatBetween(5.0, 10.0);
//        [NSTimer scheduledTimerWithTimeInterval:randomTime target:self selector:@selector(dropRandomBall) userInfo:NULL repeats:NO];
    }
    
    return self;
}

#pragma mark touch handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    self.positionWhereTouchBegan = [[Field instance] positionOfTouchInGameLayer:firstTouch];
    
    if([touches count] > 2) {
        [self.ballTimer invalidate];
        [self.stuffTimer invalidate];
        [[Field instance] removeFromParent];
        [[SceneManager instance] changeSceneToSceneType:kMenuScene fromCurrentScene:self];
    }
    else if([touches count] > 1) {
        // multitouch --> pause game
        [[SceneManager instance] gosubIntoSceneWithType:kPauseScene fromCurrentScene:self];
    }
    else if(![self.sceneHandler touchesBegan:touches withEvent:event]) {
        [self.brickDrawer touchesBegan:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.brickDrawer touchesEnded:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.brickDrawer touchesMoved:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.brickDrawer touchesCancelled:touches withEvent:event];
}

#pragma mark ScrollBrickScene

-(void)dropBall {
//    static int ballCtr = 0;
    
    float startX = [Field middleWidth];
    float startY = [Field middleHeight];
    CGPoint firstBallStartPoint = CGPointMake(startX, startY);
    [Ball addBallAtPosition:firstBallStartPoint withDuration:1.0];

//    ballCtr++;
//    if(ballCtr < 3) {
//        float randomTime = RandomFloatBetween(3.0, 5.0);
//        self.ballTimer = [NSTimer scheduledTimerWithTimeInterval:randomTime target:self selector:@selector(dropBall) userInfo:NULL repeats:NO];
//    }
}

#pragma mark stuff

-(void)addStuff {
    StuffType stuffType = [Stuff randomStuff];
    
    float x = RandomFloatBetween(0, [Field mainAreaRect].size.width);
    CGPoint position = [[Field instance] convertPointToGameLayerCoordinates:CGPointMake(x, -10)];
    
    [Stuff addStuffWithType:stuffType andPosition:position];

    float randomTime = RandomFloatBetween(1.0, 3.0);
    self.stuffTimer = [NSTimer scheduledTimerWithTimeInterval:randomTime target:self selector:@selector(addStuff) userInfo:NULL repeats:NO];
}

-(void)collisionWithStuff:(Stuff *)stuff andRandomWait:(BOOL)doRandomWait {
    [stuff collidedWithRandomWait:doRandomWait];
}

#pragma mark contact handling

-(void)didBeginContact:(SKPhysicsContact *)contact {
    if([contact.bodyA.node.name isEqualToString:STUFF_NAME] || [contact.bodyB.node.name isEqualToString:STUFF_NAME]) {
        if([contact.bodyA.node.name isEqualToString:STUFF_NAME]) {
            [self collisionWithStuff:(Stuff *)contact.bodyA.node andRandomWait:NO];
        }
        if([contact.bodyB.node.name isEqualToString:STUFF_NAME]) {
            [self collisionWithStuff:(Stuff *)contact.bodyB.node andRandomWait:NO];
        }
    }
}

#pragma mark post processing

-(void)didSimulatePhysics {
    [self scroll];
    [self ballPostProcessing];
}

-(void)scroll {
    [[Field instance] scrollGameLayer:.5];
}

-(void)ballPostProcessing {
    Ball *ball = (Ball *)[[Field instance] findNodeInGameLayerWithName:[Ball name]];
    
    CGPoint absoluteBallPosition = [[Field instance] convertPointFromGameLayerCoordinates:ball.position];
    
    if(absoluteBallPosition.y < -10) {
        float newX = [Field middleWidth];
        float newY = absoluteBallPosition.y;
        CGPoint newBallPosition = [[Field instance] convertPointToGameLayerCoordinates:CGPointMake(newX, newY)];
        [ball stopPhysics];
        ball.position = newBallPosition;
    }
    else if(absoluteBallPosition.y > [Field middleHeight]) {
        [ball startPhysics];
    }
}

@end
