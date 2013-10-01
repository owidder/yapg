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

#define POINTS_LABEL_NAME @"points"

@interface Stuff() {
    float size;
}

-(void)addSparks;

-(void)createRandomShapeAndPhysicsBodyWithPoints:(int)points;
-(void)createCircleShapeAndPhysicsBodyWithRadius:(float)radius andPoints:(int)points;
-(void)createTriangleShapeAndPhysicsBodyWithSideLength:(float)length andPoints:(int)points;
-(void)createSquareShapeAndPhysicsBodyWithSideLength:(float)length andPoints:(int)points;

@end

@implementation Stuff

#pragma mark properties

@synthesize points = _points;

#pragma mark init

-(id)initWithPosition:(CGPoint)position andPoints:(int)points {
    if(self = [super init]) {
        _points = points;
        
        size = MainScreenSize().size.width / 30;

        [self createRandomShapeAndPhysicsBodyWithPoints:points];
        
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

-(void)createCircleShapeAndPhysicsBodyWithRadius:(float)radius andPoints:(int)points{
    self.path = CreateCirclePath(size/2);
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:size/2];
    self.fillColor = [SKColor redColor];

    SKLabelNode *pointsLabel = [SKLabelNode node];
    pointsLabel.name = POINTS_LABEL_NAME;
    pointsLabel.position = CGPointMake(0, -size/2);
    pointsLabel.fontSize = size/2;
    pointsLabel.fontColor = [SKColor blackColor];
    pointsLabel.text = [NSString stringWithFormat:@"%d", points];
    [self addChild:pointsLabel];
}

-(void)createTriangleShapeAndPhysicsBodyWithSideLength:(float)length andPoints:(int)points{
    self.path = CreateTrianglePath(length);
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:self.path];
    self.fillColor = [SKColor blueColor];
    
    SKLabelNode *pointsLabel = [SKLabelNode node];
    pointsLabel.name = POINTS_LABEL_NAME;
    pointsLabel.position = CGPointMake(size/2, 0);
    pointsLabel.fontSize = size/2;
    pointsLabel.fontColor = [SKColor blackColor];
    pointsLabel.text = [NSString stringWithFormat:@"%d", points];
    [self addChild:pointsLabel];
}

-(void)createSquareShapeAndPhysicsBodyWithSideLength:(float)length andPoints:(int)points{
    self.path = CreateSquarePath(length);
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:self.path];
    self.fillColor = [SKColor greenColor];
    
    SKLabelNode *pointsLabel = [SKLabelNode node];
    pointsLabel.name = POINTS_LABEL_NAME;
    pointsLabel.position = CGPointMake(size/2, 0);
    pointsLabel.fontSize = size/2;
    pointsLabel.fontColor = [SKColor blackColor];
    pointsLabel.text = [NSString stringWithFormat:@"%d", points];
    [self addChild:pointsLabel];
}

+(void)addStuffAtPosition:(CGPoint)position andPoints:(int)points{
    Stuff *stuff = [[Stuff alloc] initWithPosition:position andPoints:points];
    [Field addToGameLayer:stuff];
    NSLog(@"Stuff created: %@", stuff.description);
}

-(void)createRandomShapeAndPhysicsBodyWithPoints:(int)points {
    float random = RandomFloatBetween(0, 3);
    
    if(random < 1.0) {
        [self createCircleShapeAndPhysicsBodyWithRadius:size andPoints:points];
    }
    else if(random < 2.0) {
        [self createTriangleShapeAndPhysicsBodyWithSideLength:size andPoints:points];
    }
    else {
        [self createSquareShapeAndPhysicsBodyWithSideLength:size andPoints:points];
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
    
    SKLabelNode *pointsLabel = (SKLabelNode *) [self childNodeWithName:POINTS_LABEL_NAME];
    if(pointsLabel != nil) {
        [pointsLabel removeFromParent];
        CGPoint positionOnField = CGPointMake(self.position.x + pointsLabel.position.x, self.position.y + pointsLabel.position.y);
        pointsLabel.position = positionOnField;
        [Field addToGameLayer:pointsLabel];
        [pointsLabel runAction:[SKAction fadeOutWithDuration:1.0]];
    }

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
