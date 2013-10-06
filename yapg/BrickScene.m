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
}

-(void)shutDownScene;
-(void)resetScene;
-(void)deployStuffOnField;

-(void)decrementTime;
-(void)gameOver;
-(void)restartTimer;

-(void)collisionWithStuff:(Stuff *)stuff;

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
        [self resetScene];
        
        currentBrick = NULL;
        
        residualTimeInSeconds = SCENE_DURATION_IN_SECONDS;
    }
    return self;
}

-(void)addStuffWithType:(StuffType)type {
    float x = RandomFloatBetween(0, MainScreenSize().size.width);
    float y = RandomFloatBetween(0, MainScreenSize().size.height-50);
    CGPoint position = CGPointMake(x, y);
    
    [Stuff addStuffWithType:type andPosition:position];
}

-(void)deployStuffOnField {
    for(int i = 0; i < 20; i++) {
        [self addStuffWithType:kCircle];
    }

    for(int i = 0; i < 20; i++) {
        [self addStuffWithType:kTriangle];
    }

    for(int i = 0; i < 20; i++) {
        [self addStuffWithType:kSquare];
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

#pragma mark stuff handling

-(void)collisionWithStuff:(Stuff *)stuff {
    int points = stuff.points;
    [stuff collided];
    [[Field instance] addPoints:-points];
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
        if([contact.bodyA.node.name isEqualToString:STUFF_NAME]) {
            [self collisionWithStuff:(Stuff *)contact.bodyA.node];
        }
        if([contact.bodyB.node.name isEqualToString:STUFF_NAME]) {
            [self collisionWithStuff:(Stuff *)contact.bodyB.node];
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
    if(![[Field instance] doesNodeExistInGameLayer:[Ball name]]) {
        UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
        CGPoint positionOfFirstTouch = [firstTouch locationInNode:self];
        
        if(currentBrick == NULL) {
            currentBrick = [[Brick alloc] initWithAbsolutePositionOfBrick:positionWhenTouchBegan];
        }
        
        [currentBrick updateWithAbsolutePositionOfBrickSegment:positionOfFirstTouch];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    currentBrick = NULL;
}

#pragma mark SKScene

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
