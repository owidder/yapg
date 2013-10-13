//
//  PauseScene.m
//  yapg
//
//  Created by Oliver Widder on 10/13/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "PauseScene.h"
#import "drawutil.h"
#import "Constants.h"

#define STD_LENGTH 10.0
#define MIN_WAIT_TIME 1.0
#define MAX_WAIT_TIME 5.0

@interface PauseScene ()

-(void)createEdge;
-(void)dropText:(NSString *)text;
-(void)scheduleDropPauseText;

@end

@implementation PauseScene

-(id)initWithSize:(CGSize)size {
    if(self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blackColor];
        [self createEdge];
        [self scheduleDropPauseText];
    }
    
    return self;
}

-(void)createEdge {
    SKNode *edge = [SKNode node];
    
    float xEdgeRandom = RandomFloatBetween(0.0, STD_LENGTH);
    float yEdgeRandom = RandomFloatBetween(0.0, STD_LENGTH);
    CGPathRef rect = CreateRectanglePath(STD_LENGTH, STD_LENGTH);
    edge.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:rect];
    edge.position = CGPointMake(self.size.width/2+xEdgeRandom, self.size.height/2+yEdgeRandom);
    
    [self addChild:edge];
}

-(void)scheduleDropPauseText {
    [self dropText:@"Pause"];
    float waitTime = RandomFloatBetween(MIN_WAIT_TIME, MAX_WAIT_TIME);
    [NSTimer scheduledTimerWithTimeInterval:waitTime target:self selector:@selector(scheduleDropPauseText) userInfo:NULL repeats:NO];
}

-(void)dropText:(NSString *)text {
    SKLabelNode *textNode = [SKLabelNode labelNodeWithFontNamed:STD_FONT];
    textNode.text = text;
    textNode.fontColor = [SKColor whiteColor];
    textNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width/2, STD_LENGTH)];
    textNode.physicsBody.mass = RandomFloatBetween(0.1, 1.0);
    textNode.physicsBody.friction = RandomFloatBetween(0.5, 5.0);
    textNode.physicsBody.restitution = RandomFloatBetween(0.1, 1.0);
    
    float xPos = RandomFloatBetween(self.frame.size.width/3, self.frame.size.width/3*2);
    float yPos = self.frame.size.height*2;
    textNode.position = CGPointMake(xPos, yPos);
    
    [textNode runAction:[SKAction sequence:@[[SKAction waitForDuration:MAX_WAIT_TIME], [SKAction removeFromParent]]]];
    
    [self addChild:textNode];
}

@end
