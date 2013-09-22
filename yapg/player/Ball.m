//
//  Ball.m
//  yapg
//
//  Created by Oliver Widder on 9/21/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "Ball.h"
#import "Categories.h"
#import "EmitterNodeFactory.h"
#import "Field.h"

static const float RADIUS = 3.0;
static const float LINE_WIDTH = 0.0;
static const float RESTITUTION = 0.1;

NSString *NAME = @"ball";

@interface Ball() {
    SKNode *circle;
}

-(void)createBallNode;
-(SKShapeNode *)makeCircleWithRadius:(CGFloat)radius;

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
    NSLog(@"Ball created: (%@)", ball.description);
}

-(void)createBallNode {
    SKPhysicsBody *physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:RADIUS];
    physicsBody.restitution = RESTITUTION;
    physicsBody.dynamic = YES;
    physicsBody.categoryBitMask = [Categories ballCategory];
    physicsBody.contactTestBitMask = [Categories bottomCategory] | [Categories stuffCategory];
    
    self.physicsBody = physicsBody;

    circle = [self makeCircleWithRadius:RADIUS];
    
    [self addChild:circle];
    
    [Field addToGameLayer:self];
}

-(SKShapeNode *)makeCircleWithRadius:(CGFloat)radius
{
    SKShapeNode *ball = [[SKShapeNode alloc] init];
    
    CGMutablePathRef ballPath = CGPathCreateMutable();
    CGPathAddArc(ballPath, NULL, 0,0, radius, 0, M_PI*2, YES);
    ball.path = ballPath;
    
    ball.lineWidth = LINE_WIDTH;
    ball.fillColor = [SKColor blackColor];
    
    return ball;
}

#pragma mark behaviour

-(void)die {
    // self.physicsBody.dynamic = NO;
    
    SKEmitterNode *smoke = [EmitterNodeFactory newSmokeEmitter];
    [self addChild:smoke];
    
    SKAction *fadeOutNode = [SKAction fadeOutWithDuration:0.1];
    SKAction *removeNode = [SKAction removeFromParent];
    SKAction *removeNodeSeq = [SKAction sequence:@[fadeOutNode, removeNode]];
    [circle runAction:removeNodeSeq];
    
    SKAction *waitBeforeRemoveEmitter = [SKAction waitForDuration:1.0];
    SKAction *scaleOutEmitter = [SKAction scaleTo:0 duration:1.0];
    SKAction *removeEmitter = [SKAction removeFromParent];
    SKAction *removeEmitterSeq = [SKAction sequence:@[waitBeforeRemoveEmitter, scaleOutEmitter, removeEmitter]];
    [smoke runAction:removeEmitterSeq];
}

@end
