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
#define TARGET_NAME @"target"

#define DEBUG_TEXT_NODE_NAME @"debugText"
#define POINTS_TEXT_NODE_NAME @"pointsText"
#define TOTAL_POINTS_TEXT_NODE_NAME @"totalPointsText"
#define TIME_TEXT_NODE_NAME @"time"

#define DEBUG_LAYER_Z_POSITION 1000
#define GAME_LAYER_Z_POSITION 0
#define POINTS_LAYER_Z_POSITION 50
#define TIME_LAYER_Z_POSITION 60

#define TARGET_WIDTH 100.0

#define COLOR_CHANGE_TIME 3.0

@interface Field() {
    SKNode *pointsLayer;
    SKNode *gameLayer;
    SKNode *debugLayer;
    SKNode *timeLayer;
}

-(void)createGameLayer;
-(void)createEdges;
-(void)createBallStartArea;

-(void)createDebugLayer;
-(SKLabelNode *)createDebugTextNode;

-(void)createPointsLayer;
-(SKLabelNode *)createPointsTextNode;
-(SKLabelNode *)createTotalPointsTextNode;

-(void)createTimeLayer;
-(SKLabelNode *)createTimeTextNode;

@end

@implementation Field

#pragma mark properties

-(int)points {
    int points = 0;
    
    SKLabelNode *pointsTextNode = (SKLabelNode *)[pointsLayer childNodeWithName:POINTS_TEXT_NODE_NAME];
    if(pointsTextNode != nil) {
        points = [pointsTextNode.text intValue];
    }
    return points;
}

#pragma mark size

+(CGRect)ballStartAreaRect {
    float height = MainScreenSize().size.height/20;
    float originY = MainScreenSize().origin.y + MainScreenSize().size.height - height;
    CGRect area = CGRectMake(MainScreenSize().origin.x, originY, MainScreenSize().size.width, height);
    
    return area;
}

+(CGRect)mainAreaRect {
    CGRect screenSize = MainScreenSize();
    float subtractFromHeight = [Field ballStartAreaRect].size.height;
    CGRect fieldSize = CGRectMake(screenSize.origin.x, screenSize.origin.y, screenSize.size.width, screenSize.size.height-subtractFromHeight);
    return fieldSize;
}

#pragma mark node names

+(NSString *)bottomName {
    return BOTTOM_NAME;
}

+(NSString *)targetName {
    return TARGET_NAME;
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
        [self createBallStartArea];
    }
    
    return self;
}

-(void)reset {
    [gameLayer removeAllChildren];
    [self createEdges];
    [debugLayer removeAllChildren];
    [pointsLayer removeAllChildren];
    [timeLayer removeAllChildren];
}

#pragma mark game layer

-(void)createGameLayer {
    gameLayer = [SKNode node];
    gameLayer.name = @"gameLayer";
    gameLayer.zPosition = GAME_LAYER_Z_POSITION;
    
    [self addChild:gameLayer];
}

-(void)createBallStartArea {
    CGRect ballStartAreaRect = [Field ballStartAreaRect];

    SKShapeNode *ballStartAreaStroke = [SKShapeNode node];
    ballStartAreaStroke.position = ballStartAreaRect.origin;
    ballStartAreaStroke.path = CreateRectanglePath(ballStartAreaRect.size.width, ballStartAreaRect.size.height);
    ballStartAreaStroke.lineWidth = 0.1;
    ballStartAreaStroke.strokeColor = [SKColor whiteColor];
    ballStartAreaStroke.alpha = 0.3;
    
    [self addChild:ballStartAreaStroke];
    
    SKShapeNode *ballStartArea = [SKShapeNode node];
    ballStartArea.path = CreateRectanglePath(ballStartAreaRect.size.width, ballStartAreaRect.size.height);
    ballStartArea.position = ballStartAreaRect.origin;
    ballStartArea.fillColor = [SKColor grayColor];
    ballStartArea.alpha = 0.3;
    
    SKAction *red = [SKAction runBlock:^(void){ballStartArea.fillColor = [SKColor redColor];}];
    SKAction *green = [SKAction runBlock:^(void){ballStartArea.fillColor = [SKColor greenColor];}];
    SKAction *blue = [SKAction runBlock:^(void){ballStartArea.fillColor = [SKColor blueColor];}];
    SKAction *yellow = [SKAction runBlock:^(void){ballStartArea.fillColor = [SKColor yellowColor];}];
    SKAction *fadeIn = [SKAction fadeAlphaTo:0.2 duration:COLOR_CHANGE_TIME];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.05 duration:COLOR_CHANGE_TIME];
    SKAction *seqColors = [SKAction sequence:@[fadeOut, red, fadeIn, fadeOut, green, fadeIn, fadeOut, blue, fadeIn, fadeOut, yellow]];
    SKAction *repeatColors = [SKAction repeatActionForever:seqColors];
    [ballStartArea runAction:repeatColors];
    
    [self addChild:ballStartArea];
}

-(void)createEdges {
    CGRect frame = MainScreenSize();
    
    CGPoint bottomLeft = frame.origin;
    CGPoint topLeft = CGPointMake(frame.origin.x, frame.origin.y+frame.size.height);
    CGPoint topRight = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height);
    CGPoint bottomRight = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y);
    
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
    
    float targetStartX = RandomFloatBetween(10.0, bottomRight.x - TARGET_WIDTH);
    CGPoint targetStart = CGPointMake(targetStartX, bottomRight.y);
    CGPoint targetEnd = CGPointMake(targetStartX + TARGET_WIDTH, bottomRight.y);
    
    SKNode *bottom1 = [SKNode node];
    bottom1.name = BOTTOM_NAME;
    bottom1.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:bottomLeft toPoint:targetStart];
    bottom1.physicsBody.categoryBitMask = [Categories bottomCategory];
    [gameLayer addChild:bottom1];

    SKNode *bottom2 = [SKNode node];
    bottom2.name = BOTTOM_NAME;
    bottom2.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:targetEnd toPoint:bottomRight];
    bottom2.physicsBody.categoryBitMask = [Categories bottomCategory];
    [gameLayer addChild:bottom2];
    
    SKShapeNode *target = [SKShapeNode node];
    target.name = TARGET_NAME;
    target.strokeColor = [SKColor redColor];
    target.path = CreateLinePath(TARGET_WIDTH);
    target.position = targetStart;
    target.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:target.path];
    target.physicsBody.categoryBitMask = [Categories bottomCategory];
    [gameLayer addChild:target];
}

-(void)addToGameLayer:(SKNode *)node {
    [gameLayer addChild:node];
}

-(BOOL)doesNodeExistInGameLayer:(NSString *)nodeName {
    BOOL exist = NO;
    
    SKNode *foundNode = [gameLayer childNodeWithName:nodeName];
    
    if(foundNode != nil) {
        exist = YES;
    }
    
    return exist;
}

-(CGPoint)positionOfNodeInGameLayerWithName:(NSString *)name {
    SKNode *node = [gameLayer childNodeWithName:name];
    return node.position;
}

-(void)removeAllNodesInGameLayerWithName:(NSString *)name andPosition:(CGPoint)position {
    NSArray *nodesAtPosition = [gameLayer nodesAtPoint:position];
    for(SKNode *node in nodesAtPosition) {
        if([name isEqualToString:node.name]) {
            [node removeAllActions];
            SKAction *fadeOut = [SKAction fadeOutWithDuration:1.0];
            SKAction *remove = [SKAction removeFromParent];
            SKAction *seq = [SKAction sequence:@[fadeOut, remove]];
            [node runAction:seq];
        }
    }
}

-(SKNode *)findNodeInGameLayerWithName:(NSString *)nodeName {
    return [gameLayer childNodeWithName:nodeName];
}

-(NSArray *)findAllNodesInGameLayerWithName:(NSString *)nodeName {
    NSMutableArray *allNodesWithName = [NSMutableArray array];
    NSArray *children = [gameLayer children];
    for(SKNode *node in children) {
        if([nodeName isEqualToString:node.name]) {
            [allNodesWithName addObject:node];
        }
    }
    
    return allNodesWithName;
}

#pragma mark time layer

-(void)createTimeLayer {
    timeLayer = [SKNode node];
    timeLayer.name = @"timeLayer";
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
        
        timeTextNode.text = newTime;
    }
}

-(SKLabelNode *)createTimeTextNode {
    SKLabelNode *timeTextNode = [SKLabelNode node];
    timeTextNode.name = TIME_TEXT_NODE_NAME;
    timeTextNode.fontSize = 20;
    timeTextNode.fontColor = [SKColor grayColor];
    timeTextNode.alpha = 0.5;
    
    float xPos = self.frame.origin.x + MainScreenSize().size.width - 30;
    float yPos = self.frame.origin.y + 30;
    timeTextNode.position = CGPointMake(xPos, yPos);
    timeTextNode.text = @"0:00";
    [timeLayer addChild:timeTextNode];
    
    return timeTextNode;
}

-(void)showNumberOfSecondsAsMinSec:(int)numberOfSeconds {
    int minutesPart = numberOfSeconds / 60;
    int secondsPart = numberOfSeconds % 60;
    NSString *minSecString = [NSString stringWithFormat:@"%d:%02d", minutesPart, secondsPart];
    
    SKLabelNode *timeTextNode = (SKLabelNode *) [timeLayer childNodeWithName:TIME_TEXT_NODE_NAME];
    if(timeTextNode == nil) {
        timeTextNode = [self createTimeTextNode];
    }
    timeTextNode.text = minSecString;
}

#pragma mark points layer

-(void)createPointsLayer {
    pointsLayer = [SKNode node];
    pointsLayer.name = @"pointsLayer";
    pointsLayer.zPosition = POINTS_LAYER_Z_POSITION;
    
    [self addChild:pointsLayer];
}

-(SKLabelNode *)createPointsTextNode {
    SKLabelNode *pointsTextNode = [SKLabelNode node];
    pointsTextNode.fontSize = 50;
    pointsTextNode.fontColor = [SKColor grayColor];
    pointsTextNode.alpha = 0.5;
    pointsTextNode.position = CGPointMake(self.frame.origin.x + 80, self.frame.origin.y + 10);
    pointsTextNode.name = POINTS_TEXT_NODE_NAME;
    pointsTextNode.text = @"0";
    [pointsLayer addChild:pointsTextNode];
    
    return pointsTextNode;
}

-(SKLabelNode *)createTotalPointsTextNode {
    SKLabelNode *totalPointsTextNode = [SKLabelNode node];
    totalPointsTextNode.fontSize = 10;
    totalPointsTextNode.fontColor = [SKColor whiteColor];
    totalPointsTextNode.alpha = 0.5;
    totalPointsTextNode.text = @"0";
    totalPointsTextNode.name = TOTAL_POINTS_TEXT_NODE_NAME;
    
    CGRect ballStartAreaRect = [Field ballStartAreaRect];
    float totalPointsOriginX = ballStartAreaRect.origin.x + 10;
    float totalPointsOriginY = ballStartAreaRect.origin.y + ballStartAreaRect.size.height - 20;
    totalPointsTextNode.position = CGPointMake(totalPointsOriginX, totalPointsOriginY);
    
    return totalPointsTextNode;
}

-(void)addPoints:(int)points {
    SKLabelNode *pointsTextNode = (SKLabelNode *)[pointsLayer childNodeWithName:POINTS_TEXT_NODE_NAME];
    if(pointsTextNode == nil) {
        pointsTextNode = [self createPointsTextNode];
    }
    pointsTextNode.text = AddIntToString(pointsTextNode.text, points);
}

-(void)addTotalPoints:(int)points {
    SKLabelNode *totalPointsNode = (SKLabelNode *)[pointsLayer childNodeWithName:TOTAL_POINTS_TEXT_NODE_NAME];
    if(totalPointsNode == nil) {
        totalPointsNode = [self createTotalPointsTextNode];
    }
    totalPointsNode.text = AddIntToString(totalPointsNode.text, points);
}

-(void)setLevel:(int)level {
    
}

#pragma mark debug layer

-(void)createDebugLayer {
    debugLayer = [SKNode node];
    debugLayer.name = @"debugLayer";
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

@end
