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
#import "ActionFactory.h"
#import "EmitterNodeFactory.h"

#define DEBUG_LAYER_Z_POSITION 1000
#define GAME_LAYER_Z_POSITION 0

#define DEBUG_TEXT_NODE_NAME @"debugText"

#define BOTTOM_NAME @"bottom"

#define BRICK_NAME @"brick"

#define BALL_RADIUS 3
#define BALL_LINE_WIDTH 0.0
#define BALL_RESTITUTION 0.1
#define BALL_NAME @"ball"

static const uint32_t bottomCategory = 0x1 << 0;
static const uint32_t ballCategory = 0x1 << 1;

static const int MIN_BRICK_DISTANCE = 20;
static const float BRICK_LINE_WIDTH = 0.1;

static const float NORMAL_BACKGROUND_RED = 1.0;
static const float NORMAL_BACKGROUND_BLUE = 1.0;
static const float NORMAL_BACKGROUND_GREEN = 1.0;
static const float NORMAL_BACKGROUND_ALPHA = 1.0;

static const float MAX_TIME_BETWEEN_TOUCHES_TO_DRAW_BALL = 0.3;

@interface BrickScene() {
    CGPoint currentTouchPosition;
    CGPoint positionAtTouchBegan;
    CGPoint relativePositionOfLastBrickPathSegment;
    
    NSTimeInterval timeOfLastTouchBegan;
    
    SKNode *gameLayer;
    
    SKNode *debugLayer;
    
    SKShapeNode *currentBrickSketchNode;
    CGMutablePathRef currentBrickSketchPath;
}

-(SKShapeNode *)makeCircleWithRadius:(CGFloat)radius;
-(CGMutablePathRef)makePathFromZeroToPoint:(CGPoint)point;

-(void)initCurrentBrickSketchNodeWithPosition:(CGPoint)position;
-(void)updateCurrentBrickSketchPathWithTouch:(UITouch *)touch;
-(void)createBallNodeAtPosition:(CGPoint)position;

-(CGPoint)relativePositionSinceTouchBegan:(CGPoint)currentPosition;

-(void)addNodeToGameLayer:(SKNode *)node;
-(void)addNodeToDebugLayer:(SKNode *)node;
-(void)initAndAddDebugLayer;
-(void)initAndAddGameLayer;
-(void)initField;
-(void)initEdges;

-(void)printDebugMessage:(NSString *)message;
@end

@implementation BrickScene

#pragma mark initialization

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        self.physicsWorld.contactDelegate = self;
        self.backgroundColor = [SKColor colorWithRed:NORMAL_BACKGROUND_RED green:NORMAL_BACKGROUND_GREEN blue:NORMAL_BACKGROUND_BLUE alpha:NORMAL_BACKGROUND_ALPHA];
        
        [self initField];
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
    if([contact.bodyA.node.name isEqualToString:BOTTOM_NAME] || [contact.bodyA.node.name isEqualToString:BOTTOM_NAME]) {
        SKNode *ball = nil;
        
        if([contact.bodyA.node.name isEqualToString:BALL_NAME]) {
            ball = contact.bodyA.node;
        }
        else if([contact.bodyB.node.name isEqualToString:BALL_NAME]) {
            ball = contact.bodyB.node;
        }
        
        if(ball != nil) {
            [ActionFactory destroyNode:ball withEmitter:[EmitterNodeFactory newSmokeEmitter]];
        }
    }
    
}

#pragma mark layer handling

-(void)initField {
    timeOfLastTouchBegan = 0;
    invalidatePosition(&relativePositionOfLastBrickPathSegment);
    
    [self initAndAddGameLayer];
    [self initAndAddDebugLayer];
    [self initEdges];
}

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

-(void)initEdges {
    CGPoint bottomLeft = self.frame.origin;
    CGPoint topLeft = CGPointMake(bottomLeft.x, bottomLeft.x+self.frame.size.height);
    CGPoint topRight = CGPointMake(topLeft.x+self.frame.size.width, topLeft.y);
    CGPoint bottomRight = CGPointMake(topRight.x, bottomLeft.y);
    
    SKNode *right = [[SKNode alloc] init];
    right.name = @"right";
    right.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:topRight toPoint:bottomRight];
    [self addNodeToGameLayer:right];
    
    SKNode *top = [[SKNode alloc] init];
    top.name = @"top";
    top.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:topLeft toPoint:topRight];
    [self addNodeToGameLayer:top];
    
    SKNode *left = [[SKNode alloc] init];
    left.name = @"left";
    left.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:bottomLeft toPoint:topLeft];
    [self addNodeToGameLayer:left];
    
    SKNode *bottom = [[SKNode alloc] init];
    bottom.name = BOTTOM_NAME;
    bottom.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:bottomLeft toPoint:bottomRight];
    bottom.physicsBody.categoryBitMask = bottomCategory;
    [self addNodeToGameLayer:bottom];
}

#pragma mark mode handling

-(CGPoint)relativePositionSinceTouchBegan:(CGPoint)currentPosition {
    return CGPointMake(currentPosition.x-positionAtTouchBegan.x, currentPosition.y-positionAtTouchBegan.y);
}

#pragma mark draw bricks and balls

-(void)createBallNodeAtPosition:(CGPoint)position {
    SKShapeNode *ball = [self makeCircleWithRadius:BALL_RADIUS];
    ball.position = position;
    ball.physicsBody.categoryBitMask = ballCategory;
    ball.physicsBody.contactTestBitMask = bottomCategory;
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

-(void)initCurrentBrickSketchNodeWithPosition:(CGPoint)position {
    currentBrickSketchNode = [[SKShapeNode alloc] init];
    currentBrickSketchNode.lineWidth = BRICK_LINE_WIDTH;
    currentBrickSketchNode.strokeColor = [SKColor lightGrayColor];
    currentBrickSketchNode.position = position;
    
    currentBrickSketchPath = CGPathCreateMutable();
    CGPathMoveToPoint(currentBrickSketchPath, NULL, 0, 0);
    currentBrickSketchNode.path = currentBrickSketchPath;
    relativePositionOfLastBrickPathSegment = CGPointZero;
    
    [self addNodeToGameLayer:currentBrickSketchNode];
    [ActionFactory destroyNodeWithFadeOut:currentBrickSketchNode];
}

-(void)updateCurrentBrickSketchPathWithTouch:(UITouch *)touch {
    CGPoint positionOfTouch = [touch locationInNode:self];
    CGPoint relativePositionSinceTouchBegan = [self relativePositionSinceTouchBegan:positionOfTouch];
    if(distance(relativePositionOfLastBrickPathSegment, relativePositionSinceTouchBegan) > MIN_BRICK_DISTANCE) {
        CGPathAddQuadCurveToPoint(currentBrickSketchPath, NULL, relativePositionOfLastBrickPathSegment.x, relativePositionOfLastBrickPathSegment.y, relativePositionSinceTouchBegan.x, relativePositionSinceTouchBegan.y);
        relativePositionOfLastBrickPathSegment = relativePositionSinceTouchBegan;
        currentBrickSketchNode.path = currentBrickSketchPath;
        currentBrickSketchNode.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:currentBrickSketchPath];
    }
}

#pragma mark touch handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    invalidatePosition(&relativePositionOfLastBrickPathSegment);
    
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    CGPoint positionOfFirstTouch = [firstTouch locationInNode:self];
    
    if(timeOfLastTouchBegan > 0) {
        NSTimeInterval now = [event timestamp];
        NSTimeInterval timeSinceLastTouchBegan = now - timeOfLastTouchBegan;
        if(timeSinceLastTouchBegan < MAX_TIME_BETWEEN_TOUCHES_TO_DRAW_BALL) {
            [self createBallNodeAtPosition:positionOfFirstTouch];
        }
    }
    
    timeOfLastTouchBegan = [event timestamp];
    positionAtTouchBegan = positionOfFirstTouch;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    CGPoint positionOfFirstTouch = [firstTouch locationInNode:self];
    if(!isPositionValid(relativePositionOfLastBrickPathSegment)) {
        CGFloat distanceSinceTouchBegan = distance(positionAtTouchBegan, positionOfFirstTouch);
        if(distanceSinceTouchBegan > MIN_BRICK_DISTANCE) {
            [self initCurrentBrickSketchNodeWithPosition:positionOfFirstTouch];
        }
    }

    if(isPositionValid(relativePositionOfLastBrickPathSegment)) {
        [self updateCurrentBrickSketchPathWithTouch:firstTouch];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}

#pragma mark SKScene

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
