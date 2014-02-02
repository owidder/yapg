//
//  Ball.m
//  yapg
//
//  Created by Oliver Widder on 9/21/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "drawutil.h"

#import "Ball.h"
#import "Categories.h"
#import "EmitterNodeFactory.h"
#import "Field.h"

#define RADIUS 3.0
#define LINE_WIDTH 0.0
#define RESTITUTION 0.1
#define NAME @"ball"

@interface Ball()

-(void)createBallNodeWithDuration:(float)duration;

@end

@implementation Ball

+(NSString*)name {
    return NAME;
}

#pragma mark initialization

-(id)initWithPosition:(CGPoint)position andDuration:(float)duration {
    if(self = [super init]) {
        self.position = position;
        self.name = NAME;
        [self createBallNodeWithDuration:duration];
    }
    return self;
}

+(void)addBallAtPosition:(CGPoint)position withDuration:(float)duration {
    Ball *ball = [[Ball alloc] initWithPosition:position andDuration:duration];
    [[Field instance] addToGameLayer:ball];
}

-(void)createBallNodeWithDuration:(float)duration {
    CGMutablePathRef ballPath = CreateCirclePath(RADIUS);
    self.path = ballPath;
    
    self.lineWidth = LINE_WIDTH;
    self.fillColor = [SKColor whiteColor];

    SKPhysicsBody *physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:RADIUS];
    physicsBody.restitution = RESTITUTION;
    physicsBody.categoryBitMask = [Categories ballCategory];
    physicsBody.contactTestBitMask = [Categories bottomCategory] | [Categories stuffCategory];
    
    self.physicsBody = physicsBody;

    if(duration > 0.0) {
        physicsBody.dynamic = NO;
        SKAction *switchOnDynamic = [SKAction runBlock:^{
            physicsBody.dynamic = YES;
        }];
        SKAction *waitAction = [SKAction waitForDuration:duration];
        SKAction *waitAndSwitch = [SKAction sequence:@[waitAction, switchOnDynamic]];
        [self runAction:waitAndSwitch]; 
    }
    else {
        physicsBody.dynamic = YES;
    }
}

#pragma mark behaviour

-(void)die {
    CGPoint currentPosition = [self position];
    
    [self removeFromParent];
    
    SKEmitterNode *smoke = [EmitterNodeFactory newSmokeEmitter];
    smoke.position = currentPosition;
    [[Field instance] addToGameLayer:smoke];
    
    SKAction *waitBeforeRemoveEmitter = [SKAction waitForDuration:1.0];
    SKAction *scaleOutEmitter = [SKAction scaleTo:0 duration:1.0];
    SKAction *removeEmitter = [SKAction removeFromParent];
    SKAction *removeEmitterSeq = [SKAction sequence:@[waitBeforeRemoveEmitter, scaleOutEmitter, removeEmitter]];
    [smoke runAction:removeEmitterSeq];
}

@end
