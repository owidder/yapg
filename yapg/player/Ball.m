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

@interface Ball() {
    SKNode *circle;
}

-(void)createBallNode;

@end

@implementation Ball

+(NSString*)name {
    return NAME;
}

#pragma mark initialization

-(id)initWithPosition:(CGPoint)position {
    if(self = [super init]) {
        self.position = position;
        self.name = NAME;
        [self createBallNode];
    }
    return self;
}

+(void)addBallAtPosition:(CGPoint)position {
    Ball *ball = [[Ball alloc] initWithPosition:position];
    [Field addToGameLayer:ball];
    NSLog(@"Ball created: (%@)", ball.description);
}

-(void)createBallNode {
    CGMutablePathRef ballPath = CreateCirclePath(RADIUS);
    self.path = ballPath;
    
    self.lineWidth = LINE_WIDTH;
    self.fillColor = [SKColor blackColor];

    SKPhysicsBody *physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:RADIUS];
    physicsBody.restitution = RESTITUTION;
    physicsBody.dynamic = YES;
    physicsBody.categoryBitMask = [Categories ballCategory];
    physicsBody.contactTestBitMask = [Categories bottomCategory] | [Categories stuffCategory];
    
    self.physicsBody = physicsBody;
}

#pragma mark behaviour

-(void)die {
    CGPoint currentPosition = [self position];
    
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.1];
    [self runAction:fadeOut];
    
    SKEmitterNode *smoke = [EmitterNodeFactory newSmokeEmitter];
    smoke.position = currentPosition;
    [Field addToGameLayer:smoke];
    
    SKAction *waitBeforeRemoveEmitter = [SKAction waitForDuration:1.0];
    SKAction *scaleOutEmitter = [SKAction scaleTo:0 duration:1.0];
    SKAction *removeEmitter = [SKAction removeFromParent];
    SKAction *removeEmitterSeq = [SKAction sequence:@[waitBeforeRemoveEmitter, scaleOutEmitter, removeEmitter]];
    [smoke runAction:removeEmitterSeq];
}

@end
