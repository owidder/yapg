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

@interface Stuff() {
}

-(void)addSparks;
-(CGMutablePathRef)createRandomShape;

@end

@implementation Stuff

-(id)initWithPosition:(CGPoint)position {
    if(self = [super init]) {
        self.position = position;
        self.name = NAME;
        self.path = [self createRandomShape];
        
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

-(CGMutablePathRef)createRandomShape {
    CGMutablePathRef path;
    
    float random = RandomFloatBetween(0, 1);
    
    if(random < 0.5) {
        path = CreateTrianglePath(RADIUS);
    }
    else {
        path = CreateCirclePath(RADIUS/2);
    }
    
    return path;
}

-(void)addSparks {
    SKEmitterNode *spark = [EmitterNodeFactory newSparkEmitter];
    CGPoint currentPosition = self.position;
    spark.position = currentPosition;
    [Field addToGameLayer:spark];

    SKAction *waitForRemoveAction = [SKAction waitForDuration:0.5];
    SKAction *scaleAction = [SKAction scaleTo:0.0 duration:0.3];
    SKAction *removeAction = [SKAction removeFromParent];
    SKAction *sequence = [SKAction sequence:@[waitForRemoveAction, scaleAction, removeAction]];
    [spark runAction:sequence];
}

-(void)collided {
    Field *field = [Field instance];
    [field printDebugMessage:[NSString stringWithFormat:@"collided(%f)", [NSDate timeIntervalSinceReferenceDate]]];

    SKAction *switchDynamicOnAction = [SKAction runBlock:^(void){self.physicsBody.dynamic = YES;}];
    SKAction *fadeOutAction = [SKAction fadeOutWithDuration:1.0];
    SKAction *removeAction = [SKAction removeFromParent];
    SKAction *addSparkAction = [SKAction performSelector:@selector(addSparks) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[switchDynamicOnAction, fadeOutAction, addSparkAction, removeAction]];
    [self runAction:sequence];
}

+(NSString *)name {
    return NAME;
}

@end
