//
//  MenuScene.m
//  yapg
//
//  Created by Oliver Widder on 10/12/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "MenuScene.h"

#import "drawutil.h"

@interface MenuScene ()

-(void)addMenuPointWithText:(NSString *)text;
-(void)createEdges;

@end

@implementation MenuScene

-(id)initWithSize:(CGSize)size {
    if(self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        [self createEdges];
        
        SKAction *addStartGameMenuPoint = [SKAction runBlock:^(void){[self addMenuPointWithText:@"Start Game"];}];
        SKAction *addDemoMenuPoint = [SKAction runBlock:^(void){[self addMenuPointWithText:@"Demo"];}];
        SKAction *wait = [SKAction waitForDuration:1.0];
        
        [self runAction:[SKAction sequence:@[wait, addStartGameMenuPoint, wait, addDemoMenuPoint]]];
    }
    
    return self;
}

-(void)addMenuPointWithText:(NSString *)text {
    CGSize rectangleSize = CGSizeMake(150, 70);
    
    SKLabelNode *textNode = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Light"];
    textNode.text = text;
    textNode.fontColor = [SKColor blackColor];
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
    [middle runAction:[SKAction sequence:@[waitForRemove, removeMiddle]]];
    [self addChild:middle];
}


@end
