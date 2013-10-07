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

#import "debugutil.h"

#define STUFF_NAME @"stuff"
#define SCENE_DURATION_IN_SECONDS 30
#define START_NUMBER_OF_STUFF 5
#define INC_NUMBER_OF_STUFF 5

static const float NORMAL_BACKGROUND_RED = 0.0;
static const float NORMAL_BACKGROUND_BLUE = 0.0;
static const float NORMAL_BACKGROUND_GREEN = 0.0;
static const float NORMAL_BACKGROUND_ALPHA = 0.0;

static const float MAX_TIME_BETWEEN_TOUCHES_TO_DRAW_BALL = 0.3;

@interface BrickScene() {
    CGPoint positionWhenTouchBegan;
    NSTimeInterval timeWhenTouchBegan;
    
    Brick *currentBrick;
    
    int residualTimeInSeconds;
    NSTimer *timer;
    
    BOOL gameStarted;
    
    CGPoint lastBallPosition;
    
    int numberOfStuff;
}

-(void)shutDownScene;
-(void)resetScene;
-(void)deployStuffOnField;

-(void)decrementTime;
-(void)nextLevel;
-(void)timeOver;
-(void)restartTimer;

-(void)collisionWithStuff:(Stuff *)stuff andRandomWait:(BOOL)doRandomWait;

-(void)addStuffWithType:(StuffType)type;

@end

@implementation BrickScene

#pragma mark initialization

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.name = @"brickScene";

        self.physicsWorld.contactDelegate = self;
        self.backgroundColor = [SKColor colorWithRed:NORMAL_BACKGROUND_RED green:NORMAL_BACKGROUND_GREEN blue:NORMAL_BACKGROUND_BLUE alpha:NORMAL_BACKGROUND_ALPHA];
        
        timeWhenTouchBegan = 0;
        
        [self addChild:[Field instance]];
        
        currentBrick = NULL;
        gameStarted = NO;
        
        residualTimeInSeconds = SCENE_DURATION_IN_SECONDS;
        
        numberOfStuff = START_NUMBER_OF_STUFF;

        [self resetScene];
    }
    return self;
}

-(void)addStuffWithType:(StuffType)type {
    float x = RandomFloatBetween(0, [Field mainAreaRect].size.width);
    float y = RandomFloatBetween(0, [Field mainAreaRect].size.height);
    CGPoint position = CGPointMake(x, y);
    
    [Stuff addStuffWithType:type andPosition:position];
}

-(void)deployStuffOnField {
    for(int i = 0; i < numberOfStuff; i++) {
        [self addStuffWithType:kCircle];
    }

    for(int i = 0; i < numberOfStuff; i++) {
        [self addStuffWithType:kTriangle];
    }

    for(int i = 0; i < numberOfStuff; i++) {
        [self addStuffWithType:kSquare];
    }
}

-(void)resetScene {
    [[Field instance] reset];
    [self deployStuffOnField];
    [timer invalidate];
    gameStarted = NO;
    [self restartTimer];
}

-(void)shutDownScene {
    SKLabelNode *finish = [SKLabelNode node];
    finish.text = @"NEXT LEVEL";
    finish.position = CGPointMake(MainScreenSize().size.width/2, MainScreenSize().size.height/2);
    finish.fontSize = 100;
    finish.fontColor = [SKColor whiteColor];
    finish.alpha = 0.2;
    [self addChild:finish];
    
    SKAction *wait = [SKAction waitForDuration:3.0];
    SKAction *reset = [SKAction performSelector:@selector(resetScene) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[wait, reset]];
    
    [self runAction:sequence completion:^(void){[finish removeFromParent];}];
}

#pragma mark stuff handling

-(void)collisionWithStuff:(Stuff *)stuff andRandomWait:(BOOL)doRandomWait {
    [stuff collidedWithRandomWait:doRandomWait];
}

#pragma mark time handling

-(void)nextLevel {
    if([Field instance].points < 0) {
        [self timeOver];
        numberOfStuff = START_NUMBER_OF_STUFF;
    }
    else {
        [timer invalidate];
        Ball *ball = (Ball *) [[Field instance] findNodeInGameLayerWithName:[Ball name]];
        [ball die];
        [self shutDownScene];
        numberOfStuff+=INC_NUMBER_OF_STUFF;
    }
}

-(void)timeOver {
    [timer invalidate];
    Ball *ball = (Ball *) [[Field instance] findNodeInGameLayerWithName:[Ball name]];
    [ball die];
    for(Stuff *stuff in [[Field instance] findAllNodesInGameLayerWithName:[Stuff name]]) {
        [self collisionWithStuff:stuff andRandomWait:YES];
    }
}

-(void)decrementTime {
    residualTimeInSeconds--;
    [[Field instance] showNumberOfSecondsAsMinSec:residualTimeInSeconds];
    if(residualTimeInSeconds == 0) {
        [self timeOver];
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
        [self nextLevel];
    }
    
    if([contact.bodyA.node.name isEqualToString:STUFF_NAME] || [contact.bodyB.node.name isEqualToString:STUFF_NAME]) {
        if([contact.bodyA.node.name isEqualToString:STUFF_NAME]) {
            [self collisionWithStuff:(Stuff *)contact.bodyA.node andRandomWait:NO];
        }
        if([contact.bodyB.node.name isEqualToString:STUFF_NAME]) {
            [self collisionWithStuff:(Stuff *)contact.bodyB.node andRandomWait:NO];
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
            if(!gameStarted) {
                if(positionOfFirstTouch.y > [Field ballStartAreaRect].origin.y) {
                    gameStarted = YES;
                    lastBallPosition = positionOfFirstTouch;
                    [Ball addBallAtPosition:positionOfFirstTouch];
                }
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
    if(!gameStarted) {
        if(currentBrick == NULL) {
            currentBrick = [[Brick alloc] initWithAbsolutePositionOfBrick:positionWhenTouchBegan];
        }
        
        [currentBrick updateWithAbsolutePositionOfBrickSegment:positionOfFirstTouch];
    }
    else {
        [[Field instance] removeAllNodesInGameLayerWithName:[Brick name] andPosition:positionOfFirstTouch];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    currentBrick = NULL;
}

#pragma mark SKScene

-(void)didEvaluateActions {
    if([[Field instance] doesNodeExistInGameLayer:[Ball name]]) {
        CGPoint currentBallPosition = [[Field instance] positionOfNodeInGameLayerWithName:[Ball name]];
        if(currentBallPosition.y < lastBallPosition.y) {
            CGFloat distance = Distance(lastBallPosition, currentBallPosition);
            if(distance > 10.0) {
                lastBallPosition = currentBallPosition;
                [[Field instance] addPoints:(int)(distance/10)];
            }
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
