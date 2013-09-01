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
    UITouch *lastTouch;
    
    CreationMode creationMode;
    
    NSTimer *creationModeTimer;
}

-(SKShapeNode *)createBallShapeNodeWithRadius:(CGFloat)radius;
-(SKShapeNode *)createBrickShapeNodeWithWidth:(CGFloat)width andHeight:(CGFloat)height;
-(void)beginBallMode;
-(void)beginBrickMode;
-(void)stopCreationModeTimer;
-(void)startCreationModeTimer;
-(void)drawBallAtLocationOfTouch:(UITouch *)touch;
-(void)drawBrickAtLocationOfTouch:(UITouch *)touch;
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
        [self drawBrickAtLocationOfTouch:lastTouch];
    }
}

-(void)stopCreationModeTimer {
    [creationModeTimer invalidate];
    creationModeTimer = nil;
}

-(void)startCreationModeTimer {
    creationModeTimer = [NSTimer scheduledTimerWithTimeInterval:MIN_TIME_TO_START_BRICK_DRAWING_IN_SECONDS target:self selector:@selector(startCreationModeBrick) userInfo:NULL repeats:NO];
}

#pragma mark draw bricks and balls

-(void)drawBallAtLocationOfTouch:(UITouch *)touch {
    SKShapeNode *ball = [self createBallShapeNodeWithRadius:BALL_RADIUS];
    ball.position = [touch locationInNode:self];
    [self addChild:ball];
}

-(void)drawBrickAtLocationOfTouch:(UITouch *)touch {
    SKShapeNode *brick = [self createBrickShapeNodeWithWidth:BRICK_WIDTH andHeight:BRICK_HEIGHT];
    brick.position = [touch locationInNode:self];
    [self addChild:brick];
}

-(SKShapeNode *)createBallShapeNodeWithRadius:(CGFloat)radius
{
    SKShapeNode *ball = [[SKShapeNode alloc] init];
    
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
    [self startCreationModeTimer];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self stopCreationModeTimer];
    if(creationMode == kCreationModeBall) {
        UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
        [self drawBallAtLocationOfTouch:firstTouch];
    }
    else {
        [self beginBallMode];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    if([self durationOfTouch:firstTouch] > MIN_TIME_TO_START_BRICK_DRAWING_IN_SECONDS) {
        CGPoint location = [firstTouch locationInNode:self];
        if(ABS(location.x - lastBrickLocation.x) > BRICK_WIDTH ||
           ABS(location.y - lastBrickLocation.y) > BRICK_HEIGHT) {
            
        }
    }
}

#pragma mark SKScene

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
