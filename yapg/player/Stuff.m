//
//  Stuff.m
//  yapg
//
//  Created by Oliver Widder on 9/23/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "drawutil.h"

#import "Stuff.h"
#import "Categories.h"
#import "Field.h"
#import "EmitterNodeFactory.h"

#define NAME @"stuff"

#define LINE_WIDTH 1.0
#define RADIUS 10.0
#define ALPHA 0.5
#define RESTITUTION 0.8
#define MASS 0.01

@interface Stuff()

-(void)addSparks;

@end

@implementation Stuff

-(id)initWithPosition:(CGPoint)position {
    if(self = [super init]) {
        self.position = position;
        self.name = NAME;
        self.path = CreateCirclePath(RADIUS);
        
        self.lineWidth = LINE_WIDTH;
        self.fillColor = [SKColor redColor];
        self.alpha = ALPHA;
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:RADIUS];
        self.physicsBody.restitution = RESTITUTION;
        self.physicsBody.mass = MASS;
        self.physicsBody.dynamic = NO;
        self.physicsBody.categoryBitMask = [Categories stuffCategory];
        self.physicsBody.contactTestBitMask = [Categories stuffCategory];
    }
    
    return self;
}

+(void)addStuffAtPosition:(CGPoint)position {
    Stuff *stuff = [[Stuff alloc] initWithPosition:position];
    [Field addToGameLayer:stuff];
    NSLog(@"Stuff created: %@", stuff.description);
}

-(void)addSparks {
    SKEmitterNode *spark1 = [EmitterNodeFactory newSparkEmitter];
    [self addChild:spark1];
}

-(void)collided {
    SKAction *switchDynamicOnAction = [SKAction runBlock:^(void){self.physicsBody.dynamic = YES;}];
    SKAction *addSparkAction = [SKAction performSelector:@selector(addSparks) onTarget:self];
    SKAction *scaleAction = [SKAction scaleTo:0.0 duration:30.0];
    SKAction *removeAction = [SKAction removeFromParent];
    SKAction *sequence = [SKAction sequence:@[switchDynamicOnAction, addSparkAction, scaleAction, removeAction]];
    [self runAction:sequence];
}

+(NSString *)name {
    return NAME;
}

@end
