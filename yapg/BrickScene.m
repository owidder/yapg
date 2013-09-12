//
//  BrickScene.m
//  yapg
//
//  Created by Oliver Widder on 8/18/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "BrickScene.h"
#import "util/math.h"
#import "ActionFactory.h"

#define DEBUG_LAYER_Z_POSITION 1000
#define GAME_LAYER_Z_POSITION 0

#define DEBUG_TEXT_NODE_NAME @"debugText"

#define SCENE_NAME @"scene"

#define BRICK_SKETCH_LINE_WIDTH 0.3
#define BRICK_MINIMUM_BEZIER_NODE_DISTANCE 20

#define BRICK_WIDTH 30
#define BRICK_HEIGHT 30
#define BRICK_NAME @"brick"

#define BALL_RADIUS 3
#define BALL_LINE_WIDTH 0.0
#define BALL_RESTITUTION 0.1
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

static const uint32_t sceneCategory = 0x1 << 0;
static const uint32_t ballCategory = 0x1 << 1;

typedef enum {
    kCreationModeUndefined,
    kCreationModeBall,
    kCreationModeBrick
    
} CreationMode;

@interface BrickScene() {
    CGPoint currentTouchPosition;
    CGPoint touchPositionWhenBrickModeBegan;
    CGPoint positionOfLastBrickNode;
    
    // control points for quad curve path
    
    CreationMode creationMode;
    
    NSTimer *creationModeTimer;
    
    SKNode *gameLayer;
    
    SKNode *debugLayer;
    
    SKShapeNode *currentBrickSketchNode;
    CGMutablePathRef currentBrickSketchPath;
}

-(SKShapeNode *)makeCircleWithRadius:(CGFloat)radius;
-(CGMutablePathRef)makePathFromZeroToPoint:(CGPoint)point;

-(void)createBrickNode;
-(void)initCurrentBrickSketchNode;
-(void)initCurrentBrickSketchPathWithTouch:(UITouch *)touch;
-(void)updateCurrentBrickSketchPathWithTouch:(UITouch *)touch;
-(void)createBallNodeAtPosition:(CGPoint)position;

-(void)beginBallMode;
-(void)beginBrickMode;
-(void)stopBrickModeCountDown;
-(void)startBrickModeCountDown;
-(CGPoint)relativePositionSinceBrickModeBegan:(CGPoint)currentPosition;

-(void)addNodeToGameLayer:(SKNode *)node;
-(void)addNodeToDebugLayer:(SKNode *)node;
-(void)initAndAddDebugLayer;
-(void)initAndAddGameLayer;

-(void)printDebugMessage:(NSString *)message;
@end

@implementation BrickScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        self.name = SCENE_NAME;
        
        self.physicsWorld.contactDelegate = self;
        
        [self initAndAddGameLayer];
        [self initAndAddDebugLayer];
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask = sceneCategory;
        
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

#pragma mark contact handling

-(void)didBeginContact:(SKPhysicsContact *)contact {
    if([contact.bodyA.node.name isEqualToString:SCENE_NAME] || [contact.bodyA.node.name isEqualToString:SCENE_NAME]) {
        SKNode *ball;
        
        if([contact.bodyA.node.name isEqualToString:BALL_NAME]) {
            ball = contact.bodyA.node;
        }
        else if([contact.bodyB.node.name isEqualToString:BALL_NAME]) {
            ball = contact.bodyB.node;
        }
        
        [ActionFactory runSmokeDestroyActionOnNode:ball];
    }
    
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
        creationMode = kCreationModeBrick;
        self.backgroundColor = [SKColor colorWithRed:BRICKDRAW_BACKGROUND_RED green:BRICKDRAW_BACKGROUND_GREEN blue:BRICKDRAW_BACKGROUND_BLUE alpha:BRICKDRAW_BACKGROUND_ALPHA];
        [self initCurrentBrickSketchNode];
        touchPositionWhenBrickModeBegan = currentTouchPosition;
        positionOfLastBrickNode = CGPointZero;
        CGPathMoveToPoint(currentBrickSketchPath, NULL, positionOfLastBrickNode.x, positionOfLastBrickNode.y);
    }
}

-(void)stopBrickModeCountDown {
    [creationModeTimer invalidate];
    creationModeTimer = nil;
}

-(CGPoint)relativePositionSinceBrickModeBegan:(CGPoint)currentPosition {
    return CGPointMake(currentPosition.x-touchPositionWhenBrickModeBegan.x, currentPosition.y-touchPositionWhenBrickModeBegan.y);
}

-(void)startBrickModeCountDown {
    creationModeTimer = [NSTimer scheduledTimerWithTimeInterval:MIN_TIME_TO_START_BRICK_DRAWING_IN_SECONDS target:self selector:@selector(beginBrickMode) userInfo:NULL repeats:NO];
}

#pragma mark draw bricks and balls

-(void)createBallNodeAtPosition:(CGPoint)position {
    SKShapeNode *ball = [self makeCircleWithRadius:BALL_RADIUS];
    ball.position = position;
    ball.physicsBody.categoryBitMask = ballCategory;
    ball.physicsBody.contactTestBitMask = sceneCategory;
    [self addNodeToGameLayer:ball];
}

-(SKShapeNode *)makeCircleWithRadius:(CGFloat)radius
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

-(CGMutablePathRef)makePathFromZeroToPoint:(CGPoint)point {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0.0, 0.0);
    CGPathAddLineToPoint(path, NULL, point.x, point.y);
    return path;
}

-(void)createBrickNode {
    currentBrickSketchNode.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:currentBrickSketchPath];
    currentBrickSketchNode.physicsBody.dynamic = NO;
//    [ActionFactory applyDestroyActionOnLineNode:currentBrickSketchNode];
}

-(void)initCurrentBrickSketchNode {
    currentBrickSketchNode = [[SKShapeNode alloc] init];
    currentBrickSketchNode.lineWidth = BRICK_SKETCH_LINE_WIDTH;
    currentBrickSketchNode.strokeColor = [SKColor lightGrayColor];
    currentBrickSketchNode.position = currentTouchPosition;
    
    currentBrickSketchPath = CGPathCreateMutable();
    currentBrickSketchNode.path = currentBrickSketchPath;
    
    [self addNodeToGameLayer:currentBrickSketchNode];
    [ActionFactory runFadeOutDestroyActionOnNode:currentBrickSketchNode];
}

-(void)initCurrentBrickSketchPathWithTouch:(UITouch *)touch {
    CGPoint positionOfTouch = [touch locationInNode:self];
    CGPoint relativePositionSinceBrickModeBegan = [self relativePositionSinceBrickModeBegan:positionOfTouch];
    currentBrickSketchPath = [self makePathFromZeroToPoint:relativePositionSinceBrickModeBegan];
    currentBrickSketchNode.path = currentBrickSketchPath;
}

-(void)updateCurrentBrickSketchPathWithTouch:(UITouch *)touch {
    CGPoint positionOfTouch = [touch locationInNode:self];
    CGPoint relativePositionSinceBrickModeBegan = [self relativePositionSinceBrickModeBegan:positionOfTouch];
    if(distance(positionOfLastBrickNode, relativePositionSinceBrickModeBegan) > BRICK_MINIMUM_BEZIER_NODE_DISTANCE) {
        CGPathAddQuadCurveToPoint(currentBrickSketchPath, NULL, positionOfLastBrickNode.x, positionOfLastBrickNode.y, relativePositionSinceBrickModeBegan.x, relativePositionSinceBrickModeBegan.y);
        positionOfLastBrickNode = relativePositionSinceBrickModeBegan;
        currentBrickSketchNode.path = currentBrickSketchPath;
    }
}

#pragma mark touch handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    currentTouchPosition = [firstTouch locationInNode:self];
    [self startBrickModeCountDown];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self stopBrickModeCountDown];
    if(creationMode == kCreationModeBall) {
        UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
        [self createBallNodeAtPosition:[firstTouch locationInNode:self]];
    }
    else {
        [self createBrickNode];
        [self beginBallMode];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(creationMode == kCreationModeBrick) {
        UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
        [self updateCurrentBrickSketchPathWithTouch:firstTouch];
    }
}

#pragma mark SKScene

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
