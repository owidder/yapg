//
//  BrickScene.m
//  yapg
//
//  Created by Oliver Widder on 8/18/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "BrickScene.h"

#define BRICK_WIDTH 3
#define BRICK_HEIGHT 3
#define BRICK_NAME @"brick"

#define BALL_RADIUS 3
#define BALL_LINE_WIDTH 0.1
#define BALL_RESTITUTION 0.8
#define BALL_NAME @"ball"

#define MIN_TIME_TO_START_BRICK_DRAWING_IN_SECONDS 0.5

#define NORMAL_BACKGROUND_RED 1.0
#define NORMAL_BACKGROUND_BLUE 1.0
#define NORMAL_BACKGROUND_GREEN 1.0
#define NORMAL_BACKGROUND_ALPHA 1.0

#define BRICKDRAW_BACKGROUND_RED 0.5
#define BRICKDRAW_BACKGROUND_BLUE 0.5
#define BRICKDRAW_BACKGROUND_GREEN 0.5
#define BRICKDRAW_BACKGROUND_ALPHA 1.0

typedef enum {
    kCreationModeBall,
    kCreationModeBrick
    
} CreationMode;

@interface BrickScene() {
    UITouch *latestFirstTouch;
    
    CreationMode creationMode;
    
    NSTimer *creationModeTimer;
}

-(SKShapeNode *)createBallShapeNodeWithRadius:(CGFloat)radius;
-(SKShapeNode *)createBrickShapeNodeWithWidth:(CGFloat)width andHeight:(CGFloat)height;
-(void)beginBallMode;
-(void)beginBrickMode;
-(void)stopCreationModeTimer;
-(void)startCreationModeTimer;
-(void)drawBallAtLocation:(CGPoint)location;
-(void)drawBrickAtLocation:(CGPoint)location;
-(BOOL)checkWhetherThereIsAlreadyABrickAtLocation:(CGPoint)location;
@end

@implementation BrickScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        [self beginBallMode];
    }
    return self;
}

#pragma mark mode handling

-(void)beginBallMode {
    if(creationMode != kCreationModeBall) {
        self.backgroundColor = [SKColor colorWithRed:NORMAL_BACKGROUND_RED green:NORMAL_BACKGROUND_GREEN blue:NORMAL_BACKGROUND_BLUE alpha:NORMAL_BACKGROUND_ALPHA];
        creationMode = kCreationModeBall;
    }
}

-(void)beginBrickMode {
    if(creationMode != kCreationModeBrick) {
        creationMode = kCreationModeBrick;
        self.backgroundColor = [SKColor colorWithRed:BRICKDRAW_BACKGROUND_RED green:BRICKDRAW_BACKGROUND_GREEN blue:BRICKDRAW_BACKGROUND_BLUE alpha:BRICKDRAW_BACKGROUND_ALPHA];
        [self drawBrickAtLocation:[latestFirstTouch locationInNode:self]];
    }
}

-(void)stopCreationModeTimer {
    [creationModeTimer invalidate];
    creationModeTimer = nil;
}

-(void)startCreationModeTimer {
    creationModeTimer = [NSTimer scheduledTimerWithTimeInterval:MIN_TIME_TO_START_BRICK_DRAWING_IN_SECONDS target:self selector:@selector(beginBrickMode) userInfo:NULL repeats:NO];
}

#pragma mark draw bricks and balls

-(void)drawBallAtLocation:(CGPoint)location {
    SKShapeNode *ball = [self createBallShapeNodeWithRadius:BALL_RADIUS];
    ball.position = location;
    [self addChild:ball];
}

-(void)drawBrickAtLocation:(CGPoint)location {
    SKShapeNode *brick = [self createBrickShapeNodeWithWidth:BRICK_WIDTH andHeight:BRICK_HEIGHT];
    brick.position = location;
    [self addChild:brick];
}

-(BOOL)checkWhetherThereIsAlreadyABrickAtLocation:(CGPoint)location {
    __block BOOL foundBrickAtLocation = NO;
    
    [self enumerateChildNodesWithName:BRICK_NAME usingBlock:^(SKNode *node, BOOL *stop) {
        CGPoint locationOfBrick = node.position;
        if(ABS(locationOfBrick.x - location.x) <= BRICK_WIDTH ||
           ABS(locationOfBrick.y - location.y) <= BRICK_HEIGHT) {
            foundBrickAtLocation = YES;
            *stop = YES;
        }
    }];
    
    return foundBrickAtLocation;
}

-(SKShapeNode *)createBallShapeNodeWithRadius:(CGFloat)radius
{
    SKShapeNode *ball = [[SKShapeNode alloc] init];
    ball.name = BALL_NAME;
    
    CGMutablePathRef ballPath = CGPathCreateMutable();
    CGPathAddArc(ballPath, NULL, 0,0, radius, 0, M_PI*2, YES);
    ball.path = ballPath;
    
    ball.lineWidth = BALL_LINE_WIDTH;
    ball.strokeColor = [SKColor blackColor];
    
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    ball.physicsBody.restitution = BALL_RESTITUTION;
    ball.physicsBody.dynamic = YES;
    
    return ball;
}

-(SKShapeNode *)createBrickShapeNodeWithWidth:(CGFloat)width andHeight:(CGFloat)height {
    SKShapeNode *brick = [[SKShapeNode alloc] init];
    brick.name = BRICK_NAME;
    
    CGMutablePathRef brickPath = CGPathCreateMutable();
    CGPathAddRect(brickPath, NULL, CGRectMake(0, 0, width, height));
    brick.path = brickPath;
    
    brick.lineWidth = 0.0;
    brick.fillColor = [SKColor redColor];
    
    brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(width, height)];
    brick.physicsBody.dynamic = NO;
    
    return brick;
}

#pragma mark touch handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    latestFirstTouch = firstTouch;
    [self startCreationModeTimer];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self stopCreationModeTimer];
    if(creationMode == kCreationModeBall) {
        UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
        [self drawBallAtLocation:[firstTouch locationInNode:self]];
    }
    else {
        [self beginBallMode];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(creationMode == kCreationModeBrick) {
        UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
        CGPoint locationOfFirstTouch = [firstTouch locationInNode:self];
        if(![self checkWhetherThereIsAlreadyABrickAtLocation:locationOfFirstTouch]) {
            [self drawBrickAtLocation:locationOfFirstTouch];
        }
    }
}

#pragma mark SKScene

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
