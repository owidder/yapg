//
//  Field.m
//  yapg
//
//  Created by Oliver Widder on 9/21/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "drawutil.h"

#import "Field.h"
#import "Categories.h"

#define BOTTOM_NAME @"bottom"
#define DEBUG_TEXT_NODE_NAME @"debugText"
#define POINTS_TEXT_NODE_NAME @"pointsText"
#define TIME_TEXT_NODE_NAME @"time"

#define DEBUG_LAYER_Z_POSITION 1000
#define GAME_LAYER_Z_POSITION 0
#define POINTS_LAYER_Z_POSITION 50
#define TIME_LAYER_Z_POSITION 60

@interface Field() {
    SKNode *pointsLayer;
    SKNode *gameLayer;
    SKNode *debugLayer;
    SKNode *timeLayer;
}

-(void)createGameLayer;
-(void)createEdges;

-(void)createDebugLayer;
-(SKLabelNode *)createDebugTextNode;

-(void)createPointsLayer;
-(SKLabelNode *)createPointsTextNode;

-(void)createTimeLayer;
-(void)startTimer;
-(void)incrementTimeByOneSecond;


@end

@implementation Field

#pragma mark node names

+(NSString *)bottomName {
    return BOTTOM_NAME;
}

#pragma mark singleton

+(Field*)instance {
    static Field *instance = NULL;
    
    @synchronized(self) {
        if(instance == NULL) {
            instance = [[Field alloc] init];
        }
    }
    
    return instance;
}

#pragma mark initialization

-(id)init {
    if(self = [super init]) {
        [self createGameLayer];
        [self createDebugLayer];
        [self createPointsLayer];
        [self createTimeLayer];
        
        [self createEdges];
        [self startTimer];
    }
    
    return self;
}

-(void)reset {
    [gameLayer removeAllChildren];
    [self createEdges];
    [debugLayer removeAllChildren];
    [pointsLayer removeAllChildren];
    [timeLayer removeAllChildren];
    [self startTimer];
}

#pragma mark game layer

-(void)createGameLayer {
    gameLayer = [SKNode node];
    gameLayer.zPosition = GAME_LAYER_Z_POSITION;
    
    [self addChild:gameLayer];
}

-(void)createEdges {
    CGRect frame = MainScreenSize();
    
    CGPoint bottomLeft = frame.origin;
    CGPoint topLeft = CGPointMake(bottomLeft.x, bottomLeft.x+frame.size.height);
    CGPoint topRight = CGPointMake(topLeft.x+frame.size.width, topLeft.y);
    CGPoint bottomRight = CGPointMake(topRight.x, bottomLeft.y);
    
    SKNode *right = [SKNode node];
    right.name = @"right";
    right.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:topRight toPoint:bottomRight];
    [gameLayer addChild:right];
    
    SKNode *top = [SKNode node];
    top.name = @"top";
    top.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:topLeft toPoint:topRight];
    [gameLayer addChild:top];
    
    SKNode *left = [SKNode node];
    left.name = @"left";
    left.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:bottomLeft toPoint:topLeft];
    [gameLayer addChild:left];
    
    SKNode *bottom = [SKNode node];
    bottom.name = BOTTOM_NAME;
    bottom.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:bottomLeft toPoint:bottomRight];
    bottom.physicsBody.categoryBitMask = [Categories bottomCategory];
    [gameLayer addChild:bottom];
}

#pragma mark time layer

-(void)createTimeLayer {
    timeLayer = [SKNode node];
    timeLayer.zPosition = TIME_LAYER_Z_POSITION;
    
    [self addChild:timeLayer];
}

-(void)incrementTimeByOneSecond {
    SKLabelNode *timeTextNode = (SKLabelNode *) [timeLayer childNodeWithName:TIME_TEXT_NODE_NAME];
    if(timeTextNode != nil) {
        NSString *timeString = timeTextNode.text;
        NSArray *components = [timeString componentsSeparatedByString:@":"];
        NSInteger mins = [components[0] integerValue];
        NSInteger secs = [components[1] integerValue];
        
        if(secs == 59) {
            secs = 0;
            mins++;
        }
        else {
            secs++;
        }
        
        NSString *newTime = [NSString stringWithFormat:@"%d:%02d", mins, secs];
        
        NSLog(@"Time: %@", newTime);
        timeTextNode.text = newTime;
    }
}

-(void)startTimer {
    SKLabelNode *timeTextNode = [SKLabelNode node];
    timeTextNode.name = TIME_TEXT_NODE_NAME;
    timeTextNode.fontSize = 20;
    timeTextNode.fontColor = [SKColor grayColor];
    timeTextNode.alpha = 0.2;
    
    float xPos = self.frame.origin.x + MainScreenSize().size.width - 30;
    float yPos = self.frame.origin.y + 30;
    timeTextNode.position = CGPointMake(xPos, yPos);
    timeTextNode.text = @"0:00";
    [timeLayer addChild:timeTextNode];
    
    SKAction *waitOneSecond = [SKAction waitForDuration:1.0];
    SKAction *incrementTime = [SKAction performSelector:@selector(incrementTimeByOneSecond) onTarget:self];
    SKAction *waitAndIncrement = [SKAction sequence:@[waitOneSecond, incrementTime]];
    SKAction *repeatTimeForever = [SKAction repeatActionForever:waitAndIncrement];
    [timeTextNode runAction:repeatTimeForever];
}

#pragma mark points layer

-(void)createPointsLayer {
    pointsLayer = [SKNode node];
    pointsLayer.zPosition = POINTS_LAYER_Z_POSITION;
    
    [self addChild:pointsLayer];
}

-(SKLabelNode *)createPointsTextNode {
    SKLabelNode *pointsTextNode = [SKLabelNode node];
    pointsTextNode.fontSize = 50;
    pointsTextNode.fontColor = [SKColor grayColor];
    pointsTextNode.alpha = 0.2;
    pointsTextNode.position = CGPointMake(self.frame.origin.x + 50, self.frame.origin.y + 10);
    pointsTextNode.name = POINTS_TEXT_NODE_NAME;
    pointsTextNode.text = @"0";
    [pointsLayer addChild:pointsTextNode];
    
    return pointsTextNode;
}

#pragma mark debug layer

-(void)createDebugLayer {
    debugLayer = [SKNode node];
    debugLayer.zPosition = DEBUG_LAYER_Z_POSITION;
    
    [self addChild:debugLayer];
}

-(SKLabelNode *)createDebugTextNode {
    SKLabelNode *debugTextNode = [SKLabelNode node];
    debugTextNode.fontSize = 5;
    debugTextNode.fontColor = [SKColor blackColor];
    debugTextNode.position = CGPointMake(self.frame.origin.x + 200, self.frame.origin.y + 50);
    debugTextNode.name = DEBUG_TEXT_NODE_NAME;
    [debugLayer addChild:debugTextNode];
    
    return debugTextNode;
}

#pragma mark public layer access

-(void)printDebugMessage:(NSString *)message {
    NSLog(@"DebugMessage: %@", message);
#ifdef DEBUG_ON_SCREEN
    SKLabelNode *debugTextNode = (SKLabelNode *) [_debugLayer childNodeWithName:DEBUG_TEXT_NODE_NAME];
    if(debugTextNode == nil) {
        debugTextNode = [self createDebugTextNode];
    }
    debugTextNode.text = message;
#endif
}

-(void)addToGameLayer:(SKNode *)node {
    [gameLayer addChild:node];
}

-(void)addToDebugLayer:(SKNode *)node {
    [debugLayer addChild:node];
}

-(void)addPoints:(int)points {
    SKLabelNode *pointsTextNode = (SKLabelNode *)[pointsLayer childNodeWithName:POINTS_TEXT_NODE_NAME];
    if(pointsTextNode == nil) {
        pointsTextNode = [self createPointsTextNode];
    }
    int currenPoints = [pointsTextNode.text intValue];
    int newPoints = currenPoints + points;
    pointsTextNode.text = [NSString stringWithFormat:@"%d", newPoints];
}

-(BOOL)doesNodeExistInGameLayer:(NSString *)nodeName {
    BOOL exist = NO;
    
    SKNode *foundNode = [gameLayer childNodeWithName:nodeName];
    
    if(foundNode != nil) {
        exist = YES;
    }
    
    return exist;
}

@end
