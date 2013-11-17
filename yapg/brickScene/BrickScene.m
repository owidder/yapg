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
#import "drawutil.h"
#import "EmitterNodeFactory.h"
#import "Categories.h"
#import "Ball.h"
#import "Field.h"
#import "Brick.h"
#import "Stuff.h"

#import "debugutil.h"
#import "SceneManager.h"

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
    
    BOOL gameOver;
    
    CGPoint lastBallPosition;
    
    int numberOfStuff;
}

-(void)startNextLevel;
-(void)resetScene;
-(void)deployStuffOnField;

-(void)decrementTime;
-(void)levelFinished;
-(void)gameOver;
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
        gameOver = NO;
        
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

-(void)startNextLevel {
    numberOfStuff+=INC_NUMBER_OF_STUFF;
    
    SKLabelNode *finishText = [SKLabelNode node];
    finishText.text = @"Next Level";
    finishText.position = CGPointMake(MainScreenSize().size.width/2, MainScreenSize().size.height/2);
    finishText.fontSize = 50;
    finishText.fontColor = [SKColor whiteColor];
    finishText.alpha = 0.2;
    [self addChild:finishText];
    
    SKAction *wait = [SKAction waitForDuration:3.0];
    SKAction *reset = [SKAction performSelector:@selector(resetScene) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[wait, reset]];
    
    [self runAction:sequence completion:^(void){[finishText removeFromParent];}];
}

#pragma mark stuff handling

-(void)collisionWithStuff:(Stuff *)stuff andRandomWait:(BOOL)doRandomWait {
    [stuff collidedWithRandomWait:doRandomWait];
}

#pragma mark time handling

-(void)levelFinished {
    [timer invalidate];
    Ball *ball = (Ball *) [[Field instance] findNodeInGameLayerWithName:[Ball name]];
    [ball die];
    if([Field instance].points < 0) {
        [self gameOver];
    }
    else {
        [self startNextLevel];
    }
}

-(void)gameOver {
    gameOver = YES;
    for(Stuff *stuff in [[Field instance] findAllNodesInGameLayerWithName:[Stuff name]]) {
        [self collisionWithStuff:stuff andRandomWait:YES];
    }
}

-(void)decrementTime {
    residualTimeInSeconds--;
    [[Field instance] showNumberOfSecondsAsMinSec:residualTimeInSeconds];
    if(residualTimeInSeconds == 0) {
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
    if([contact.bodyA.node.name isEqualToString:[Field bottomName]] || [contact.bodyB.node.name isEqualToString:[Field bottomName]]) {
        [self gameOver];
    }
    else if([contact.bodyA.node.name isEqualToString:[Field targetName]] || [contact.bodyB.node.name isEqualToString:[Field targetName]]) {
        [self levelFinished];
    }
    else if([contact.bodyA.node.name isEqualToString:STUFF_NAME] || [contact.bodyB.node.name isEqualToString:STUFF_NAME]) {
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
    if(gameOver) {
        [[Field instance] removeFromParent];
        [[SceneManager instance] changeSceneToSceneType:kMenuScene fromCurrentScene:self];
    }
    if([touches count] > 1) {
        // multitouch --> pause game
        [[SceneManager instance] gosubIntoSceneWithType:kPauseScene fromCurrentScene:self];
    }
    else {
        // no multitouch:
        UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
        CGPoint positionOfFirstTouch = [firstTouch locationInNode:self];
        
        if(timeWhenTouchBegan > 0) {
            // check whether it's a double touch inside the dropping area
            NSTimeInterval now = [event timestamp];
            NSTimeInterval timeSinceLastTouchBegan = now - timeWhenTouchBegan;
            if(timeSinceLastTouchBegan < MAX_TIME_BETWEEN_TOUCHES_TO_DRAW_BALL) {
                // time since first touch of this double touch is short enough
                if(!gameStarted) {
                    if(positionOfFirstTouch.y > [Field ballStartAreaRect].origin.y) {
                        // second touch was inside the dropping area
                        // and there is not already a ball --> drop ball
                        gameStarted = YES;
                        lastBallPosition = positionOfFirstTouch;
                        [Ball addBallAtPosition:positionOfFirstTouch];
                    }
                }
            }
        }
        
        timeWhenTouchBegan = [event timestamp];
        positionWhenTouchBegan = positionOfFirstTouch;
    }
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
