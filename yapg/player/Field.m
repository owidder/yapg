//
//  Field.m
//  yapg
//
//  Created by Oliver Widder on 9/21/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "Field.h"
#import "Categories.h"

#define BOTTOM_NAME @"bottom"
#define DEBUG_TEXT_NODE_NAME @"debugText"

#define DEBUG_LAYER_Z_POSITION 1000
#define GAME_LAYER_Z_POSITION 0

@interface Field()

-(void)createEdgesWithFrame:(CGRect)frame;
-(void)createDebugLayer;
-(void)createGameLayer;

@end

@implementation Field

@synthesize gameLayer = _gameLayer;
@synthesize debugLayer = _debugLayer;

#pragma mark initialization

-(id)initWithFrame:(CGRect)frame {
    if(self = [super init]) {
        [self createGameLayer];
        [self createDebugLayer];
        
        [self createEdgesWithFrame:frame];
    }
    
    return self;
}

-(void)createGameLayer {
    _gameLayer = [SKNode node];
    _gameLayer.zPosition = GAME_LAYER_Z_POSITION;
    
    [self addChild:_gameLayer];
}

-(void)createDebugLayer {
    _debugLayer = [SKNode node];
    _debugLayer.zPosition = DEBUG_LAYER_Z_POSITION;
    
    SKLabelNode *debugTextNode = [SKLabelNode node];
    debugTextNode.fontSize = 5;
    debugTextNode.fontColor = [SKColor blackColor];
    debugTextNode.position = CGPointMake(self.frame.origin.x + 200, self.frame.origin.y + 50);
    debugTextNode.name = DEBUG_TEXT_NODE_NAME;
    [_debugLayer addChild:debugTextNode];
    
    [self addChild:_debugLayer];
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

-(void)createEdgesWithFrame:(CGRect)frame {
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

#pragma mark debug

-(void)printDebugMessage:(NSString *)message {
    NSLog(@"DebugMessage: %@", message);
#ifdef DEBUG_ON_SCREEN
    SKLabelNode *debugTextNode = (SKLabelNode *) [_debugLayer childNodeWithName:DEBUG_TEXT_NODE_NAME];
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
