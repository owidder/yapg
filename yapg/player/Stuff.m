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

-(void)createCircleShapeAndPhysicsBodyWithRadius:(float)radius andPoints:(int)points;
-(void)createTriangleShapeAndPhysicsBodyWithSideLength:(float)length andPoints:(int)points;
-(void)createSquareShapeAndPhysicsBodyWithSideLength:(float)length andPoints:(int)points;

@end

@implementation Stuff

#pragma mark properties

@synthesize points = _points;

#pragma mark init

-(id)initWithType:(StuffType)type andPosition:(CGPoint)position andPoints:(int)points {
    if(self = [super init]) {
        _points = points;
        
        size = MainScreenSize().size.width / 30;

        switch (type) {
            case kCircle:
                [self createCircleShapeAndPhysicsBodyWithRadius:size andPoints:points];
                break;
                
            case kTriangle:
                [self createTriangleShapeAndPhysicsBodyWithSideLength:size andPoints:points];
                break;
                
            default:
                [self createSquareShapeAndPhysicsBodyWithSideLength:size andPoints:points];
        }
        
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
}

-(void)createTriangleShapeAndPhysicsBodyWithSideLength:(float)length andPoints:(int)points{
    self.path = CreateTrianglePath(length);
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:self.path];
    self.fillColor = [SKColor blueColor];
}

-(void)createSquareShapeAndPhysicsBodyWithSideLength:(float)length andPoints:(int)points{
    self.path = CreateSquarePath(length);
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:self.path];
    self.fillColor = [SKColor greenColor];
}

+(void)addStuffWithType:(StuffType)type andPosition:(CGPoint)position andPoints:(int)points {
    Stuff *stuff = [[Stuff alloc] initWithType:type andPosition:position andPoints:points];
    [[Field instance] addToGameLayer:stuff];
    NSLog(@"Stuff created: %@", stuff.description);
}

-(void)addSparks {
    SKEmitterNode *spark = [EmitterNodeFactory newSparkEmitter];
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
    Field *field = [Field instance];
    [field printDebugMessage:[NSString stringWithFormat:@"collided(%f)", [NSDate timeIntervalSinceReferenceDate]]];
    
    SKLabelNode *pointsLabel = [SKLabelNode node];
    pointsLabel.name = POINTS_LABEL_NAME;
    pointsLabel.position = self.position;
    pointsLabel.fontSize = size/2;
    pointsLabel.fontColor = self.fillColor;
    pointsLabel.text = [NSString stringWithFormat:@"%d", self.points];
    [[Field instance] addToGameLayer:pointsLabel];
    [pointsLabel runAction:[SKAction fadeOutWithDuration:1.0] completion:^(void){[pointsLabel removeFromParent];}];
    
    SKAction *switchDynamicOnAction = [SKAction runBlock:^(void){self.physicsBody.dynamic = YES;}];
    SKAction *fadeOutAction = [SKAction fadeOutWithDuration:0.2];
    SKAction *removeAction = [SKAction removeFromParent];
    SKAction *addSparkAction = [SKAction performSelector:@selector(addSparks) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[switchDynamicOnAction, fadeOutAction, addSparkAction, removeAction]];
    [self runAction:sequence];
}

+(NSString *)name {
    return NAME;
}

@end
