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

#define STUFF_NAME @"stuff"

static const uint32_t bottomCategory = 0x1 << 0;
static const uint32_t ballCategory = 0x1 << 1;
static const uint32_t stuffCategory = 0x1 << 2;

static const int MIN_BRICK_DISTANCE = 5;
static const float BRICK_LINE_WIDTH = 0.1;

static const float NORMAL_BACKGROUND_RED = 1.0;
static const float NORMAL_BACKGROUND_BLUE = 1.0;
static const float NORMAL_BACKGROUND_GREEN = 1.0;
static const float NORMAL_BACKGROUND_ALPHA = 1.0;

static const float MAX_TIME_BETWEEN_TOUCHES_TO_DRAW_BALL = 0.3;

@interface BrickScene() {
    CGPoint currentTouchPosition;
    
    NSMutableArray *brickPositions;
    
    CGPoint positionWhenTouchBegan;
    NSTimeInterval timeWhenTouchBegan;
    
    SKNode *gameLayer;
    
    SKNode *debugLayer;
    
    SKShapeNode *currentBrickSketchNode;
    CGMutablePathRef currentBrickSketchPath;
}

-(SKShapeNode *)makeCircleWithRadius:(CGFloat)radius;
-(CGMutablePathRef)makePathFromZeroToPoint:(CGPoint)point;

-(SKShapeNode *)makeStuff;

-(void)initCurrentBrickSketchNodeWithPosition:(CGPoint)position;
-(void)updateCurrentBrickSketchPathWithPosition:(CGPoint)position;
-(void)createBallNodeAtPosition:(CGPoint)position;
-(CGMutablePathRef)createBezierPathFromArrayOfPositions:(NSMutableArray *)positions;
-(CGPoint)lastBrickPosition;

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
    
    if([contact.bodyA.node.name isEqualToString:STUFF_NAME] || [contact.bodyA.node.name isEqualToString:STUFF_NAME]) {
        SKNode *stuff = nil;
        
        if([contact.bodyA.node.name isEqualToString:STUFF_NAME]) {
            stuff = contact.bodyA.node;
        }
        else if([contact.bodyB.node.name isEqualToString:STUFF_NAME]) {
            stuff = contact.bodyB.node;
        }
        
        if(stuff != nil) {
            stuff.physicsBody.dynamic = YES;
        }
    }
    
}

#pragma mark layer handling

-(void)initField {
    timeWhenTouchBegan = 0;
    
    [self initAndAddGameLayer];
    [self initAndAddDebugLayer];
    [self initEdges];
    
    SKShapeNode *stuff = [self makeStuff];
    [self addNodeToGameLayer:stuff];
}

-(void)initAndAddDebugLayer {
    debugLayer = [[SKNode alloc] init];
    debugLayer.zPosition = DEBUG_LAYER_Z_POSITION;
    
    SKLabelNode *debugTextNode = [[SKLabelNode alloc] init];
    debugTextNode.fontSize = 5;
    debugTextNode.fontColor = [SKColor blackColor];
    debugTextNode.position = CGPointMake(self.frame.origin.x + 200, self.frame.origin.y + 50);
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

#pragma mark stuff

-(SKShapeNode *)makeStuff {
    SKShapeNode *stuff = [[SKShapeNode alloc] init];
    stuff.position = CGPointMake(200, 500);
    stuff.name = STUFF_NAME;
    
    CGMutablePathRef ballPath = CGPathCreateMutable();
    CGPathAddArc(ballPath, NULL, 0,0, 10, 0, M_PI*2, YES);
    stuff.path = ballPath;
    
    stuff.lineWidth = 0;
    stuff.fillColor = [SKColor redColor];
    stuff.alpha = 0.5;
    
    stuff.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
    stuff.physicsBody.restitution = 0.8;
    stuff.physicsBody.mass = 0.01;
    stuff.physicsBody.dynamic = NO;
    stuff.physicsBody.categoryBitMask = stuffCategory;
    
    return stuff;
}

#pragma mark draw bricks and balls

-(void)createBallNodeAtPosition:(CGPoint)position {
    SKShapeNode *ball = [self makeCircleWithRadius:BALL_RADIUS];
    ball.position = position;
    ball.physicsBody.categoryBitMask = ballCategory;
    ball.physicsBody.contactTestBitMask = bottomCategory | stuffCategory;
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
    currentBrickSketchNode.glowWidth = 1.0;
    currentBrickSketchNode.strokeColor = [SKColor lightGrayColor];
    currentBrickSketchNode.position = position;
    
    [self addNodeToGameLayer:currentBrickSketchNode];
    [ActionFactory destroyNodeWithFadeOut:currentBrickSketchNode];
}

-(CGMutablePathRef)createBezierPathFromArrayOfPositions:(NSMutableArray *)positions {
    CGMutablePathRef path = CGPathCreateMutable();
    
    NSUInteger numberOfPositions = [positions count];
    if(numberOfPositions > 1) {
        CGPoint *start = [[positions objectAtIndex:0] pointerValue];
        CGPathMoveToPoint(path, NULL, start->x, start->y);
        
        if(numberOfPositions == 2) {
            CGPoint end = [[positions objectAtIndex:1] CGPointValue];
            CGPathAddLineToPoint(path, NULL, end.x, end.y);
        }
        else {
            int i;
            for (i = 1; i < [positions count] - 1; i+=2) {
                CGPoint controlPoint = [[positions objectAtIndex:i] CGPointValue];
                CGPoint endPoint = [[positions objectAtIndex:i+1] CGPointValue];
                CGPathAddQuadCurveToPoint(path, NULL, controlPoint.x, controlPoint.y, endPoint.x, endPoint.y);
            }
            
            if(i < [positions count] - 1) {
                CGPoint *finalPoint = [[positions objectAtIndex:i+1] pointerValue];
                CGPathAddLineToPoint(path, NULL, finalPoint->x, finalPoint->y);
            }
        }
    }
    
    return path;
}

-(CGPoint)lastBrickPosition {
    CGPoint lastBrickPosition = CGPointZero;
    
    int count = [brickPositions count];
    if(count > 0) {
        lastBrickPosition = [[brickPositions objectAtIndex:count-1] CGPointValue];
    }
    
    return lastBrickPosition;
}

-(void)updateCurrentBrickSketchPathWithPosition:(CGPoint)position {
    CGPoint relativePositionSinceTouchBegan = positionRelativeToBase(positionWhenTouchBegan, position);
    CGPoint lastBrickPosition = [self lastBrickPosition];
    CGFloat distanceToLastBrickPosition = distance(lastBrickPosition, relativePositionSinceTouchBegan);
    [self printDebugMessage:[NSString stringWithFormat:@"(%f, %f)/(%f,%f) - %d",
                             lastBrickPosition.x, lastBrickPosition.y,
                             relativePositionSinceTouchBegan.x, relativePositionSinceTouchBegan.y,
                             [brickPositions count]]];
    if(distanceToLastBrickPosition > MIN_BRICK_DISTANCE) {
        [brickPositions addObject:[NSValue valueWithCGPoint:relativePositionSinceTouchBegan]];
        currentBrickSketchPath = [self createBezierPathFromArrayOfPositions:brickPositions];
        
        if(currentBrickSketchNode == NULL) {
            [self initCurrentBrickSketchNodeWithPosition:position];
        }
        
        currentBrickSketchNode.path = currentBrickSketchPath;
        currentBrickSketchNode.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:currentBrickSketchPath];
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
            [self createBallNodeAtPosition:positionOfFirstTouch];
        }
    }
    
    timeWhenTouchBegan = [event timestamp];
    positionWhenTouchBegan = positionOfFirstTouch;
    
    brickPositions = [[NSMutableArray alloc] init];
    [brickPositions addObject:[NSValue valueWithPointer:&CGPointZero]];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    currentBrickSketchNode = NULL;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    CGPoint positionOfFirstTouch = [firstTouch locationInNode:self];
    [self updateCurrentBrickSketchPathWithPosition:positionOfFirstTouch];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    currentBrickSketchNode = NULL;
}

#pragma mark SKScene

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
