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

#define NAME @"stuff"

#define LINE_WIDTH 1.0
#define RADIUS 10.0
#define ALPHA 0.5
#define RESTITUTION 0.8
#define MASS 0.01

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

        [Field addToGameLayer:self];
    }
    
    return self;
}

+(void)addStuffAtPosition:(CGPoint)position {
    Stuff *stuff = [[Stuff alloc] initWithPosition:position];
    NSLog(@"Stuff created: %@", stuff.description);
}

-(void)collidedWith:(SKNode *)collisionPartner {
    SKAction *switchDynamicOnAction = [SKAction runBlock:^(void){self.physicsBody.dynamic = YES;}];
    [self runAction:switchDynamicOnAction];
}

+(NSString *)name {
    return NAME;
}

@end
