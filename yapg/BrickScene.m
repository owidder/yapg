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
#import "Categories.h"
#import "Ball.h"
#import "Field.h"


#define BRICK_NAME @"brick"

#define STUFF_NAME @"stuff"

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
    
    SKShapeNode *currentBrickSketchNode;
    CGMutablePathRef currentBrickSketchPath;
    
    Field *field;
}

-(CGMutablePathRef)makePathFromZeroToPoint:(CGPoint)point;

-(SKShapeNode *)makeStuffAtPosition:(CGPoint)position;

-(void)initCurrentBrickSketchNodeWithPosition:(CGPoint)position;
-(void)updateCurrentBrickSketchPathWithPosition:(CGPoint)position;
-(CGMutablePathRef)createBezierPathFromArrayOfPositions:(NSMutableArray *)positions;
-(CGPoint)lastBrickPosition;

-(void)initField;
@end

@implementation BrickScene

#pragma mark initialization

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        self.physicsWorld.contactDelegate = self;
        self.backgroundColor = [SKColor colorWithRed:NORMAL_BACKGROUND_RED green:NORMAL_BACKGROUND_GREEN blue:NORMAL_BACKGROUND_BLUE alpha:NORMAL_BACKGROUND_ALPHA];
        
        [self initField];
        [self addChild:field];
    }
    return self;
}

#pragma mark contact handling

-(void)didBeginContact:(SKPhysicsContact *)contact {
    if([contact.bodyA.node.name isEqualToString:[Field bottomName]] || [contact.bodyA.node.name isEqualToString:[Field bottomName]]) {
        if([contact.bodyA.node.name isEqualToString:[Ball name]]) {
            [field printDebugMessage:@"Die A!!!"];
            [((Ball *)contact.bodyA.node) die];
        }
        else if([contact.bodyB.node.name isEqualToString:[Ball name]]) {
            [field printDebugMessage:@"Die B!!!"];
            [((Ball *)contact.bodyB.node) die];
        }
    }
    
    if([contact.bodyA.node.name isEqualToString:STUFF_NAME] || [contact.bodyA.node.name isEqualToString:STUFF_NAME]) {
        if([contact.bodyA.node.name isEqualToString:STUFF_NAME]) {
            contact.bodyA.dynamic = YES;
        }
        if([contact.bodyB.node.name isEqualToString:STUFF_NAME]) {
            contact.bodyB.dynamic = YES;
        }
    }
    
}

#pragma mark layer handling

-(void)initField {
    timeWhenTouchBegan = 0;
    
    field = [[Field alloc] initWithFrame:self.frame];
    
//    for(int x = 20; x < 300; x+= 100) {
//        for(int y = 20; y < 500; y+= 100) {
//            SKShapeNode *stuff = [self makeStuffAtPosition:CGPointMake(x, y)];
//            [Field addToGameLayer:stuff];
//        }
//    }
    
}

#pragma mark stuff

-(SKShapeNode *)makeStuffAtPosition:(CGPoint)position {
    SKShapeNode *stuff = [[SKShapeNode alloc] init];
    stuff.position = position;
    stuff.name = STUFF_NAME;
    
    CGMutablePathRef ballPath = CGPathCreateMutable();
    CGPathAddArc(ballPath, NULL, 0,0, 10, 0, M_PI*2, YES);
    stuff.path = ballPath;
    
    stuff.lineWidth = 1.0;
    stuff.fillColor = [SKColor redColor];
    stuff.alpha = 0.5;
    
    stuff.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
    stuff.physicsBody.restitution = 0.8;
    stuff.physicsBody.mass = 0.01;
    stuff.physicsBody.dynamic = NO;
    stuff.physicsBody.categoryBitMask = [Categories stuffCategory];
    stuff.physicsBody.contactTestBitMask = [Categories stuffCategory];
    
    return stuff;
}

#pragma mark draw bricks and balls

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
    
    [Field addToGameLayer:currentBrickSketchNode];
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
    [field printDebugMessage:[NSString stringWithFormat:@"(%f, %f)/(%f,%f) - %d",
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
            [Ball addBallAtPosition:positionOfFirstTouch];
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
