//
//  MenuScene.m
//  yapg
//
//  Created by Oliver Widder on 10/12/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "MenuScene.h"

#import "drawutil.h"
#import "EmitterNodeFactory.h"

#define BALL_CATEGORY 0x1
#define BALL_NAME @"ball"
#define START_GAME_NAME @"startGame"
#define DEMO_NAME @"demo"

@interface MenuScene ()

-(void)addMenuPointWithText:(NSString *)text andName:(NSString *)name;
-(void)createEdges;
-(void)scheduleBallDropAfterRandomTime;
-(void)dropRandomBall;
-(void)killBall:(SKShapeNode *)ball;

@end

@implementation MenuScene

-(id)initWithSize:(CGSize)size {
    if(self = [super initWithSize:size]) {
        self.physicsWorld.contactDelegate = self;
        
        self.backgroundColor = [SKColor blackColor];
        
        [self createEdges];
        
        SKAction *addStartGameMenuPoint = [SKAction runBlock:^(void){[self addMenuPointWithText:@"Start Game" andName:START_GAME_NAME];}];
        SKAction *addDemoMenuPoint = [SKAction runBlock:^(void){[self addMenuPointWithText:@"Demo" andName:DEMO_NAME];}];
        SKAction *wait = [SKAction waitForDuration:1.0];
        
        [self runAction:[SKAction sequence:@[wait, addStartGameMenuPoint, wait, addDemoMenuPoint]]];
    }
    
    return self;
}

-(void)addMenuPointWithText:(NSString *)text andName:(NSString *)name {
    CGSize rectangleSize = CGSizeMake(150, 70);
    
    SKLabelNode *textNode = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Light"];
    textNode.name = name;
    textNode.text = text;
    textNode.fontColor = [SKColor whiteColor];
    textNode.fontSize = 30;
    textNode.position = CGPointMake(self.size.width / 2, self.size.height);
    textNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rectangleSize];
    textNode.physicsBody.mass = RandomFloatBetween(0.1, 5.0);
    textNode.physicsBody.friction = RandomFloatBetween(1.0, 10.0);
    textNode.physicsBody.restitution = RandomFloatBetween(0.1, 0.5);
    
    [self addChild:textNode];
}

-(void)createEdges {
    CGRect frame = self.frame;
    
    CGPoint bottomLeft = CGPointMake(frame.origin.x, frame.origin.y);
    CGPoint topLeft = CGPointMake(frame.origin.x, frame.origin.y+frame.size.height);
    CGPoint topRight = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height);
    CGPoint bottomRight = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y);
    CGPoint middleLeft = CGPointMake(frame.origin.x, frame.origin.y+frame.size.height/2);
    CGPoint middleRight = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height/3);
    
    SKNode *right = [SKNode node];
    right.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:topRight toPoint:bottomRight];
    [self addChild:right];
    
    SKNode *left = [SKNode node];
    left.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:bottomLeft toPoint:topLeft];
    [self addChild:left];
    
    SKNode *bottom = [SKNode node];
    bottom.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:bottomLeft toPoint:bottomRight];
    [self addChild:bottom];
    
    SKNode *middle = [SKNode node];
    middle.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:middleLeft toPoint:middleRight];
    SKAction *removeMiddle = [SKAction removeFromParent];
    SKAction *waitForRemove = [SKAction waitForDuration:10.0];
    [middle runAction:[SKAction sequence:@[waitForRemove, removeMiddle]] completion:^(void){[self scheduleBallDropAfterRandomTime];}];
    [self addChild:middle];
}

-(void)scheduleBallDropAfterRandomTime {
    float randomTime = RandomFloatBetween(0.1, 3.0);
    [NSTimer scheduledTimerWithTimeInterval:randomTime target:self selector:@selector(dropRandomBall) userInfo:NULL repeats:NO];
}

-(void)dropRandomBall {
    SKShapeNode *ball = [SKShapeNode node];
    ball.name = BALL_NAME;
    ball.path = CreateCirclePath(3);
    ball.lineWidth = 0.1;
    ball.strokeColor = [SKColor whiteColor];
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:3];
    ball.physicsBody.friction = 1.0;
    ball.physicsBody.restitution = 0.6;
    
    ball.physicsBody.categoryBitMask = BALL_CATEGORY;
    ball.physicsBody.contactTestBitMask = BALL_CATEGORY;
    
//    float randomWait = RandomFloatBetween(1.0, 20.0);
//    SKAction *wait = [SKAction waitForDuration:randomWait];
//    SKAction *remove = [SKAction runBlock:^(void){[self killBall:ball];}];
//    [ball runAction:[SKAction sequence:@[wait, remove]]];
    
    float x = RandomFloatBetween(5.0, self.frame.size.width-5);
    float y = self.frame.size.height + 10;
    ball.position = CGPointMake(x, y);
    
    [self addChild:ball];
    
    [self scheduleBallDropAfterRandomTime];
}

-(void)killBall:(SKShapeNode *)ball {
    float random = RandomFloatBetween(0.0, 3.0);
    SKEmitterNode *emitter;
    if(random < 1.0) {
        emitter = [EmitterNodeFactory newEmitterWithName:@"fire-red"];
    }
    else if(random < 2.0) {
        emitter = [EmitterNodeFactory newEmitterWithName:@"fire-green"];
    }
    else {
        emitter = [EmitterNodeFactory newEmitterWithName:@"fire-blue"];
    }
    
    CGPoint position = ball.position;
    
    [ball runAction:[SKAction sequence:@[[SKAction scaleTo:0.0 duration:0.5], [SKAction removeFromParent]]]];
    
    emitter.position = position;
    
    SKAction *wait = [SKAction waitForDuration:0.5];
    SKAction *scale = [SKAction scaleTo:0.0 duration:0.3];
    SKAction *remove = [SKAction removeFromParent];
    [emitter runAction:[SKAction sequence:@[wait, scale, remove]]];
    
    [self addChild:emitter];
}

#pragma mark contact handling

-(void)didBeginContact:(SKPhysicsContact *)contact {
    if([contact.bodyA.node.name isEqualToString:BALL_NAME] && [contact.bodyB.node.name isEqualToString:BALL_NAME]) {
        [self killBall:(SKShapeNode *) contact.bodyA.node];
        [self killBall:(SKShapeNode *) contact.bodyB.node];
    }
}

@end
