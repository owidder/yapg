//
//  BrickScene.m
//  yapg
//
//  Created by Oliver Widder on 8/18/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import <limits.h>
#import <float.h>

#import "BrickScene.h"
#import "util/drawutil.h"
#import "EmitterNodeFactory.h"
#import "Categories.h"
#import "Ball.h"
#import "Field.h"
#import "Brick.h"
#import "Stuff.h"


#define STUFF_NAME @"stuff"

static const float NORMAL_BACKGROUND_RED = 1.0;
static const float NORMAL_BACKGROUND_BLUE = 1.0;
static const float NORMAL_BACKGROUND_GREEN = 1.0;
static const float NORMAL_BACKGROUND_ALPHA = 1.0;

static const float MAX_TIME_BETWEEN_TOUCHES_TO_DRAW_BALL = 0.3;

@interface BrickScene() {
    CGPoint positionWhenTouchBegan;
    NSTimeInterval timeWhenTouchBegan;
    
    Brick *currentBrick;
}

-(void)shutDownScene;
-(void)resetField;
-(void)deployStuffOnField;

@end

@implementation BrickScene

#pragma mark initialization

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        self.physicsWorld.contactDelegate = self;
        self.backgroundColor = [SKColor colorWithRed:NORMAL_BACKGROUND_RED green:NORMAL_BACKGROUND_GREEN blue:NORMAL_BACKGROUND_BLUE alpha:NORMAL_BACKGROUND_ALPHA];
        
        timeWhenTouchBegan = 0;
        
        [self addChild:[Field instance]];
        [self deployStuffOnField];
        
        currentBrick = NULL;
    }
    return self;
}

-(void)deployStuffOnField {
    for(int i = 0; i < 50; i++) {
        float x = RandomFloatBetween(0, self.frame.size.width);
        float y = RandomFloatBetween(0, self.frame.size.height);
        CGPoint position = CGPointMake(x, y);
        [Stuff addStuffAtPosition:position andPoints:i];
    }
}

-(void)resetField {
    [[Field instance] reset];
    [self deployStuffOnField];
}

-(void)shutDownScene {
    SKLabelNode *finish = [SKLabelNode node];
    finish.text = @"END";
    finish.position = CGPointMake(MainScreenSize().size.width/2, MainScreenSize().size.height/2);
    finish.fontSize = 100;
    finish.fontColor = [SKColor blackColor];
    finish.alpha = 0.2;
    [self addChild:finish];
    
    SKAction *wait = [SKAction waitForDuration:3.0];
    SKAction *reset = [SKAction performSelector:@selector(resetField) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[wait, reset]];
    
    [self runAction:sequence completion:^(void){[finish removeFromParent];}];
}

#pragma mark contact handling

-(void)didBeginContact:(SKPhysicsContact *)contact {
    if([contact.bodyA.node.name isEqualToString:[Field bottomName]] || [contact.bodyA.node.name isEqualToString:[Field bottomName]]) {
        if([contact.bodyA.node.name isEqualToString:[Ball name]]) {
            [((Ball *)contact.bodyA.node) die];
        }
        else if([contact.bodyB.node.name isEqualToString:[Ball name]]) {
            [((Ball *)contact.bodyB.node) die];
        }
    }
    
    if([contact.bodyA.node.name isEqualToString:STUFF_NAME] || [contact.bodyB.node.name isEqualToString:STUFF_NAME]) {
        Stuff *stuff;
        if([contact.bodyA.node.name isEqualToString:STUFF_NAME]) {
            stuff = (Stuff *)contact.bodyA.node;
            [stuff collided];
            [[Field instance] addPoints:stuff.points];
            stuff.points = 0;
        }
        if([contact.bodyB.node.name isEqualToString:STUFF_NAME]) {
            stuff = (Stuff *)contact.bodyB.node;
            [stuff collided];
            [[Field instance] addPoints:stuff.points];
            stuff.points = 0;
        }
    }
    
}

#pragma mark touch handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    CGPoint positionOfFirstTouch = [firstTouch locationInNode:self];
    
    if(timeWhenTouchBegan > 0) {
        NSTimeInterval now = [event timestamp];
        NSTimeInterval timeSinceLastTouchBegan = now - timeWhenTouchBegan;
        if(timeSinceLastTouchBegan < MAX_TIME_BETWEEN_TOUCHES_TO_DRAW_BALL) {
            SKNode *existingBalls = [[Field instance].gameLayer childNodeWithName:[Ball name]];
            if(existingBalls == nil) {
                [Ball addBallAtPosition:positionOfFirstTouch];
            }
            else {
                [self shutDownScene];
            }
        }
    }
    
    timeWhenTouchBegan = [event timestamp];
    positionWhenTouchBegan = positionOfFirstTouch;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    currentBrick = NULL;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    CGPoint positionOfFirstTouch = [firstTouch locationInNode:self];
    
    if(currentBrick == NULL) {
        currentBrick = [[Brick alloc] initWithAbsolutePositionOfBrick:positionWhenTouchBegan];
    }
    
    [currentBrick updateWithAbsolutePositionOfBrickSegment:positionOfFirstTouch];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    currentBrick = NULL;
}

#pragma mark SKScene

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
