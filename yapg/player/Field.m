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

#define DEBUG_LAYER_Z_POSITION 1000
#define GAME_LAYER_Z_POSITION 0
#define POINTS_LAYER_Z_POSITION 50

@interface Field() {
    SKNode *pointsLayer;
}

-(void)createEdges;
-(void)createDebugLayer;
-(SKLabelNode *)createDebugTextNode;
-(void)createGameLayer;
-(void)createPointsLayer;
-(SKLabelNode *)createPointsTextNode;

@end

@implementation Field

@synthesize gameLayer = _gameLayer;
@synthesize debugLayer = _debugLayer;

#pragma mark initialization

-(id)init {
    if(self = [super init]) {
        [self createGameLayer];
        [self createDebugLayer];
        [self createPointsLayer];
        
        [self createEdges];
    }
    
    return self;
}

-(void)reset {
    [_gameLayer removeAllChildren];
    [self createEdges];
    [_debugLayer removeAllChildren];
    [pointsLayer removeAllChildren];
}

-(void)createGameLayer {
    _gameLayer = [SKNode node];
    _gameLayer.zPosition = GAME_LAYER_Z_POSITION;
    
    [self addChild:_gameLayer];
}

-(void)createDebugLayer {
    _debugLayer = [SKNode node];
    _debugLayer.zPosition = DEBUG_LAYER_Z_POSITION;

    [self addChild:_debugLayer];
}

-(void)createPointsLayer {
    pointsLayer = [SKNode node];
    pointsLayer.zPosition = POINTS_LAYER_Z_POSITION;
    
    [self addChild:pointsLayer];
}

+(Field*)instance {
    static Field *instance = NULL;
 
    @synchronized(self) {
        if(instance == NULL) {
            instance = [[Field alloc] init];
        }
    }
    
    return instance;
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
    [_gameLayer addChild:right];
    
    SKNode *top = [SKNode node];
    top.name = @"top";
    top.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:topLeft toPoint:topRight];
    [_gameLayer addChild:top];
    
    SKNode *left = [SKNode node];
    left.name = @"left";
    left.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:bottomLeft toPoint:topLeft];
    [_gameLayer addChild:left];
    
    SKNode *bottom = [SKNode node];
    bottom.name = BOTTOM_NAME;
    bottom.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:bottomLeft toPoint:bottomRight];
    bottom.physicsBody.categoryBitMask = [Categories bottomCategory];
    [_gameLayer addChild:bottom];
}

#pragma mark points handling

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

-(void)addPoints:(int)points {
    SKLabelNode *pointsTextNode = (SKLabelNode *)[pointsLayer childNodeWithName:POINTS_TEXT_NODE_NAME];
    if(pointsTextNode == nil) {
        pointsTextNode = [self createPointsTextNode];
    }
    int currenPoints = [pointsTextNode.text intValue];
    int newPoints = currenPoints + points;
    pointsTextNode.text = [NSString stringWithFormat:@"%d", newPoints];
}

#pragma mark debug

-(SKLabelNode *)createDebugTextNode {
    SKLabelNode *debugTextNode = [SKLabelNode node];
    debugTextNode.fontSize = 5;
    debugTextNode.fontColor = [SKColor blackColor];
    debugTextNode.position = CGPointMake(self.frame.origin.x + 200, self.frame.origin.y + 50);
    debugTextNode.name = DEBUG_TEXT_NODE_NAME;
    [_debugLayer addChild:debugTextNode];
    
    return debugTextNode;
}

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


#pragma mark class methods

+(NSString *)bottomName {
    return BOTTOM_NAME;
}

+(void)addToGameLayer:(SKNode *)node {
    Field *field = [Field instance];
    [field.gameLayer addChild:node];
}

+(void)addToDebugLayer:(SKNode *)node {
    [[Field instance].debugLayer addChild:node];
}

@end
