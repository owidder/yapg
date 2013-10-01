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
#define ALPHA 0.5
#define RESTITUTION 0.8
#define MASS 0.01

@interface Stuff() {
    float size;
}

-(void)addSparks;

-(void)createRandomShapeAndPhysicsBody;
-(void)createCircleShapeAndPhysicsBodyWithRadius:(float)radius;
-(void)createTriangleShapeAndPhysicsBodyWithSideLength:(float)length;
-(void)createSquareShapeAndPhysicsBodyWithSideLength:(float)length;

@end

@implementation Stuff

-(id)initWithPosition:(CGPoint)position {
    if(self = [super init]) {
        size = MainScreenSize().size.width / 30;

        [self createRandomShapeAndPhysicsBody];
        
        self.position = position;
        self.name = NAME;
        
        self.lineWidth = LINE_WIDTH;
        self.alpha = ALPHA;
        
        self.physicsBody.restitution = RESTITUTION;
        self.physicsBody.mass = MASS;
        self.physicsBody.dynamic = NO;
        self.physicsBody.categoryBitMask = [Categories stuffCategory];
        self.physicsBody.contactTestBitMask = [Categories stuffCategory];
    }
    
    return self;
}

-(void)createCircleShapeAndPhysicsBodyWithRadius:(float)radius {
    self.path = CreateCirclePath(size/2);
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:size/2];
    self.fillColor = [SKColor redColor];
}

-(void)createTriangleShapeAndPhysicsBodyWithSideLength:(float)length {
    self.path = CreateTrianglePath(length);
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:self.path];
    self.fillColor = [SKColor blueColor];
}

-(void)createSquareShapeAndPhysicsBodyWithSideLength:(float)length {
    self.path = CreateSquarePath(length);
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:self.path];
    self.fillColor = [SKColor greenColor];
}

+(void)addStuffAtPosition:(CGPoint)position {
    Stuff *stuff = [[Stuff alloc] initWithPosition:position];
    [Field addToGameLayer:stuff];
    NSLog(@"Stuff created: %@", stuff.description);
}

-(void)createRandomShapeAndPhysicsBody {
    float random = RandomFloatBetween(0, 3);
    
    if(random < 1.0) {
        [self createCircleShapeAndPhysicsBodyWithRadius:size];
    }
    else if(random < 2.0) {
        [self createTriangleShapeAndPhysicsBodyWithSideLength:size];
    }
    else {
        [self createSquareShapeAndPhysicsBodyWithSideLength:size];
    }
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
