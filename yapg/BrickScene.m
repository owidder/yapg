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
#define SCENE_DURATION_IN_SECONDS 30

static const float NORMAL_BACKGROUND_RED = 1.0;
static const float NORMAL_BACKGROUND_BLUE = 1.0;
static const float NORMAL_BACKGROUND_GREEN = 1.0;
static const float NORMAL_BACKGROUND_ALPHA = 1.0;

static const float MAX_TIME_BETWEEN_TOUCHES_TO_DRAW_BALL = 0.3;

@interface BrickScene() {
    CGPoint positionWhenTouchBegan;
    NSTimeInterval timeWhenTouchBegan;
    
    Brick *currentBrick;
    
    int residualTimeInSeconds;
    NSTimer *timer;
}

-(void)shutDownScene;
-(void)resetScene;
-(void)deployStuffOnField;

-(void)decrementTime;
-(void)gameOver;
-(void)restartTimer;

@end

@implementation BrickScene

#pragma mark initialization

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        self.physicsWorld.contactDelegate = self;
        self.backgroundColor = [SKColor colorWithRed:NORMAL_BACKGROUND_RED green:NORMAL_BACKGROUND_GREEN blue:NORMAL_BACKGROUND_BLUE alpha:NORMAL_BACKGROUND_ALPHA];
        
        timeWhenTouchBegan = 0;
        
        [self addChild:[Field instance]];
        [self resetScene];
        
        currentBrick = NULL;
        
        residualTimeInSeconds = SCENE_DURATION_IN_SECONDS;
    }
    return self;
}

-(void)deployStuffOnField {
    for(int i = 0; i < 20; i++) {
        float x = RandomFloatBetween(0, self.frame.size.width);
        float y = RandomFloatBetween(0, self.frame.size.height);
        CGPoint position = CGPointMake(x, y);
        [Stuff addStuffWithType:kCircle andPosition:position andPoints:5];
    }

    for(int i = 0; i < 20; i++) {
        float x = RandomFloatBetween(0, self.frame.size.width);
        float y = RandomFloatBetween(0, self.frame.size.height);
        CGPoint position = CGPointMake(x, y);
        [Stuff addStuffWithType:kTriangle andPosition:position andPoints:10];
    }

    for(int i = 0; i < 20; i++) {
        float x = RandomFloatBetween(0, self.frame.size.width);
        float y = RandomFloatBetween(0, self.frame.size.height);
        CGPoint position = CGPointMake(x, y);
        [Stuff addStuffWithType:kSquare andPosition:position andPoints:20];
    }
}

-(void)resetScene {
    [[Field instance] reset];
    [self deployStuffOnField];
    [timer invalidate];
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
    SKAction *reset = [SKAction performSelector:@selector(resetScene) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[wait, reset]];
    
    [self runAction:sequence completion:^(void){[finish removeFromParent];}];
}

#pragma mark time handling

-(void)gameOver {
    [timer invalidate];
    Ball *ball = (Ball *) [[Field instance] findNodeInGameLayerWithName:[Ball name]];
    [ball die];
}

-(void)decrementTime {
    residualTimeInSeconds--;
    [[Field instance] showNumberOfSecondsAsMinSec:residualTimeInSeconds];
    if(residualTimeInSeconds == 0) {
        [timer invalidate];
        [self gameOver];
    }
}

-(void)restartTimer {
    residualTimeInSeconds = SCENE_DURATION_IN_SECONDS;
    [[Field instance] showNumberOfSecondsAsMinSec:residualTimeInSeconds];
    if([timer isValid]) {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(decrementTime) userInfo:NULL repeats:YES];
}

#pragma mark contact handling

-(void)didBeginContact:(SKPhysicsContact *)contact {
    if([contact.bodyA.node.name isEqualToString:[Field bottomName]] || [contact.bodyA.node.name isEqualToString:[Field bottomName]]) {
        [self gameOver];
    }
    
    if([contact.bodyA.node.name isEqualToString:STUFF_NAME] || [contact.bodyB.node.name isEqualToString:STUFF_NAME]) {
        Stuff *stuff;
        if([contact.bodyA.node.name isEqualToString:STUFF_NAME]) {
            stuff = (Stuff *)contact.bodyA.node;
            if(stuff.physicsBody.dynamic == NO) {
                [stuff collided];
                [[Field instance] addPoints:stuff.points];
                stuff.points = 0;
            }
        }
        if([contact.bodyB.node.name isEqualToString:STUFF_NAME]) {
            stuff = (Stuff *)contact.bodyB.node;
            if(stuff.physicsBody.dynamic == NO) {
                [stuff collided];
                [[Field instance] addPoints:stuff.points];
                stuff.points = 0;
            }
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
            if(![[Field instance] doesNodeExistInGameLayer:[Ball name]]) {
                [self restartTimer];
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
