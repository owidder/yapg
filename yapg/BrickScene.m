//
//  BrickScene.m
//  yapg
//
//  Created by Oliver Widder on 8/18/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "BrickScene.h"
#import "util/math.h"

#define DEBUG_LAYER_Z_POSITION 1000
#define GAME_LAYER_Z_POSITION 0

#define DEBUG_TEXT_NODE_NAME @"debugText"

#define BRICK_WIDTH 30
#define BRICK_HEIGHT 30
#define BRICK_NAME @"brick"

#define BALL_RADIUS 3
#define BALL_LINE_WIDTH 0.0
#define BALL_RESTITUTION 0.8
#define BALL_NAME @"ball"

#define MIN_TIME_TO_START_BRICK_DRAWING_IN_SECONDS 0.5

#define NORMAL_BACKGROUND_RED 1.0
#define NORMAL_BACKGROUND_BLUE 1.0
#define NORMAL_BACKGROUND_GREEN 1.0
#define NORMAL_BACKGROUND_ALPHA 1.0

#define BRICKDRAW_BACKGROUND_RED 0.9
#define BRICKDRAW_BACKGROUND_BLUE 0.9
#define BRICKDRAW_BACKGROUND_GREEN 0.9
#define BRICKDRAW_BACKGROUND_ALPHA 1.0

typedef enum {
    kCreationModeUndefined,
    kCreationModeBall,
    kCreationModeBrick
    
} CreationMode;

@interface BrickScene() {
    CGPoint latestLocation;
    CGPoint locationWhenBrickModeBegan;
    
    CreationMode creationMode;
    
    NSTimer *creationModeTimer;
    
    SKNode *gameLayer;
    
    SKNode *debugLayer;
    
    SKShapeNode *currentBrickNode;
}

-(SKShapeNode *)createBallShapeNodeWithRadius:(CGFloat)radius;
-(SKShapeNode *)createBrickAlongLineWithStart:(CGPoint)start andEnd:(CGPoint)end;
-(SKShapeNode *)createBrickWithMiddleOfLeftSideAtPoint:(CGPoint)middleOfLeft andLength:(CGFloat)length;

-(void)beginBallMode;
-(void)beginBrickMode;
-(void)stopBrickModeCountDown;
-(void)startBrickModeCountDown;
-(CGPoint)relativeLocationSinceBrickModeBegan:(CGPoint)currentLocation;
-(void)drawBallAtLocation:(CGPoint)location;

-(void)addNodeToGameLayer:(SKNode *)node;
-(void)addNodeToDebugLayer:(SKNode *)node;
-(void)initAndAddDebugLayer;
-(void)initAndAddGameLayer;

-(void)printDebugMessage:(NSString *)message;
@end

@implementation BrickScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self initAndAddGameLayer];
        [self initAndAddDebugLayer];
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        creationMode = kCreationModeUndefined;
        [self beginBallMode];
    }
    return self;
}

#pragma mark debugging

-(void)printDebugMessage:(NSString *)message {
    SKLabelNode *debugTextNode = (SKLabelNode *) [debugLayer childNodeWithName:DEBUG_TEXT_NODE_NAME];
    debugTextNode.text = message;
}

#pragma mark layer handling

-(void)initAndAddDebugLayer {
    debugLayer = [[SKNode alloc] init];
    debugLayer.zPosition = DEBUG_LAYER_Z_POSITION;
    
    SKLabelNode *debugTextNode = [[SKLabelNode alloc] init];
    debugTextNode.fontSize = 5;
    debugTextNode.fontColor = [SKColor blackColor];
    debugTextNode.position = CGPointMake(100, 10);
    debugTextNode.name = DEBUG_TEXT_NODE_NAME;
    [debugLayer addChild:debugTextNode];

    [self addChild:debugLayer];
}

-(void)initAndAddGameLayer {
    gameLayer = [[SKNode alloc] init];
    [self addChild:gameLayer];
}

-(void)addNodeToGameLayer:(SKNode *)node {
    [gameLayer addChild:node];
}

-(void)addNodeToDebugLayer:(SKNode *)node {
    [debugLayer addChild:node];
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
        locationWhenBrickModeBegan = latestLocation;
        creationMode = kCreationModeBrick;
        self.backgroundColor = [SKColor colorWithRed:BRICKDRAW_BACKGROUND_RED green:BRICKDRAW_BACKGROUND_GREEN blue:BRICKDRAW_BACKGROUND_BLUE alpha:BRICKDRAW_BACKGROUND_ALPHA];
        
        currentBrickNode = [[SKShapeNode alloc] init];
        currentBrickNode.lineWidth = 1.0;
        currentBrickNode.strokeColor = [SKColor grayColor];
        currentBrickNode.position = locationWhenBrickModeBegan;
        [gameLayer addChild:currentBrickNode];
    }
}

-(void)stopBrickModeCountDown {
    [creationModeTimer invalidate];
    creationModeTimer = nil;
}

-(CGPoint)relativeLocationSinceBrickModeBegan:(CGPoint)currentLocation {
    return CGPointMake(currentLocation.x-locationWhenBrickModeBegan.x, currentLocation.y-locationWhenBrickModeBegan.y);
}

-(void)startBrickModeCountDown {
    creationModeTimer = [NSTimer scheduledTimerWithTimeInterval:MIN_TIME_TO_START_BRICK_DRAWING_IN_SECONDS target:self selector:@selector(beginBrickMode) userInfo:NULL repeats:NO];
}

#pragma mark draw bricks and balls

-(void)drawBallAtLocation:(CGPoint)location {
    SKShapeNode *ball = [self createBallShapeNodeWithRadius:BALL_RADIUS];
    ball.position = location;
    [self addNodeToGameLayer:ball];
}

-(SKShapeNode *)createBallShapeNodeWithRadius:(CGFloat)radius
{
    SKShapeNode *ball = [[SKShapeNode alloc] init];
    ball.name = BALL_NAME;
    
    CGMutablePathRef ballPath = CGPathCreateMutable();
    CGPathAddArc(ballPath, NULL, 0,0, radius, 0, M_PI*2, YES);
    ball.path = ballPath;
    
    ball.lineWidth = BALL_LINE_WIDTH;
    ball.fillColor = [SKColor blackColor];
    
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    ball.physicsBody.restitution = BALL_RESTITUTION;
    ball.physicsBody.dynamic = YES;
    
    return ball;
}

-(SKShapeNode *)createBrickAlongLineWithStart:(CGPoint)start andEnd:(CGPoint)end {
    SKShapeNode *brick = [[SKShapeNode alloc] init];
    return brick;
}

#pragma mark touch handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    latestLocation = [firstTouch locationInNode:self];
    [self startBrickModeCountDown];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self stopBrickModeCountDown];
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
        CGMutablePathRef brickPath = CGPathCreateMutable();
        CGPathMoveToPoint(brickPath, NULL, 0.0, 0.0);

        UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
        CGPoint locationOfFirstTouch = [firstTouch locationInNode:self];
        CGPoint relativeLocationSinceBrickModeBegan = [self relativeLocationSinceBrickModeBegan:locationOfFirstTouch];
        CGPathAddLineToPoint(brickPath, NULL, relativeLocationSinceBrickModeBegan.x, relativeLocationSinceBrickModeBegan.y);
        
        currentBrickNode.path = brickPath;
    }
}

#pragma mark SKScene

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
