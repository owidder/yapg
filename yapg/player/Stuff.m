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

#define LINE_WIDTH 0.1
#define ALPHA 0.5
#define RESTITUTION 0.8
#define MASS 0.01

#define POINTS_LABEL_NAME @"points"

@interface Stuff() {
    float size;
    SKColor *color;
    float timeToLiveAfterCollision;
    BOOL collided;
    NSString *particleName;
}

-(void)addSparks;

-(void)createCircleShapeAndPhysicsBodyWithRadius:(float)radius;
-(void)createTriangleShapeAndPhysicsBodyWithSideLength:(float)length;
-(void)createSquareShapeAndPhysicsBodyWithSideLength:(float)length;

@end

@implementation Stuff

#pragma mark properties

@synthesize points = _points;

#pragma mark init

-(id)initWithType:(StuffType)type andPosition:(CGPoint)position {
    if(self = [super init]) {
        self.position = position;
        
        size = MainScreenSize().size.width / 30;

        switch (type) {
            case kCircle:
                [self createCircleShapeAndPhysicsBodyWithRadius:size];
                break;
                
            case kTriangle:
                [self createTriangleShapeAndPhysicsBodyWithSideLength:size];
                break;
                
            default:
                [self createSquareShapeAndPhysicsBodyWithSideLength:size];
        }
        
        self.name = NAME;
        
        self.lineWidth = LINE_WIDTH;
        self.alpha = ALPHA;
        
        self.physicsBody.restitution = RESTITUTION;
        self.physicsBody.mass = MASS;
        self.physicsBody.dynamic = NO;
        self.physicsBody.categoryBitMask = [Categories stuffCategory];
        self.physicsBody.contactTestBitMask = [Categories stuffCategory];
        
        collided = NO;
    }
    
    return self;
}

-(void)createCircleShapeAndPhysicsBodyWithRadius:(float)radius{
    self.path = CreateCirclePath(size/2);
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:size/2];
    color = [SKColor redColor];
    particleName = @"fire-red";
    timeToLiveAfterCollision = 0.2;
    _points = 5;
}

-(void)createTriangleShapeAndPhysicsBodyWithSideLength:(float)length{
    self.path = CreateTrianglePath(length);
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:self.path];
    color = [SKColor blueColor];
    particleName = @"fire-blue";
    timeToLiveAfterCollision = 0.5;
    _points = 10;
}

-(void)createSquareShapeAndPhysicsBodyWithSideLength:(float)length{
    self.path = CreateSquarePath(length);
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:self.path];
    color = [SKColor greenColor];
    particleName = @"fire-green";
    timeToLiveAfterCollision = 1.0;
    _points = 20;
}

+(void)addStuffWithType:(StuffType)type andPosition:(CGPoint)position {
    Stuff *stuff = [[Stuff node] initWithType:type andPosition:position];
    [[Field instance] addToGameLayer:stuff];
}

-(void)addSparks {
    SKEmitterNode *spark = [EmitterNodeFactory newEmitterWithName:particleName];
    CGPoint currentPosition = self.position;
    spark.position = currentPosition;
    [[Field instance] addToGameLayer:spark];

    SKAction *waitForRemoveAction = [SKAction waitForDuration:0.5];
    SKAction *scaleAction = [SKAction scaleTo:0.0 duration:0.3];
    SKAction *removeAction = [SKAction removeFromParent];
    SKAction *sequence = [SKAction sequence:@[waitForRemoveAction, scaleAction, removeAction]];
    [spark runAction:sequence];
}

-(void)collided {
    if(!collided) {
        collided = YES;
        _points = 0;
        Field *field = [Field instance];
        [field printDebugMessage:[NSString stringWithFormat:@"collided(%f)", [NSDate timeIntervalSinceReferenceDate]]];
        
        SKLabelNode *pointsLabel = [SKLabelNode node];
        pointsLabel.name = POINTS_LABEL_NAME;
        pointsLabel.position = self.position;
        pointsLabel.fontSize = size/2;
        pointsLabel.fontColor = color;
        pointsLabel.text = [NSString stringWithFormat:@"%d", self.points];
        [[Field instance] addToGameLayer:pointsLabel];
        [pointsLabel runAction:[SKAction fadeOutWithDuration:timeToLiveAfterCollision] completion:^(void){[pointsLabel removeFromParent];}];
        
        SKAction *switchDynamicOnAction = [SKAction runBlock:^(void){self.physicsBody.dynamic = YES;}];
        SKAction *fadeOutAction = [SKAction fadeOutWithDuration:0.5];
        SKAction *removeAction = [SKAction removeFromParent];
        SKAction *addSparkAction = [SKAction performSelector:@selector(addSparks) onTarget:self];
        SKAction *sequence = [SKAction sequence:@[switchDynamicOnAction, fadeOutAction, addSparkAction, removeAction]];
        [self runAction:sequence];
    }
}

+(NSString *)name {
    return NAME;
}

@end
