//
//  Stuff2.m
//  yapg
//
//  Created by Oliver Widder on 10/5/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "Stuff2.h"

#include "drawutil.h"

@interface Stuff2() {
    float size;
}

//-(void)createCircleShapeAndPhysicsBodyWithRadius:(float)radius andPoints:(int)points;
//-(void)createTriangleShapeAndPhysicsBodyWithSideLength:(float)length andPoints:(int)points;
//-(void)createSquareShapeAndPhysicsBodyWithSideLength:(float)length andPoints:(int)points;

@end

@implementation Stuff2

-(id)initWithType:(StuffType2)type andPosition:(CGPoint)position andPoints:(int)points {
    size = 5;
    
    if(self = [super init]) {
        self.position = position;
        switch (type) {
            case k2Circle:
                self.path = CreateCirclePath(size/2);
                self.fillColor = [SKColor whiteColor];
//                [self createCircleShapeAndPhysicsBodyWithRadius:size andPoints:points];
                break;
                
            case k2Triangle:
                [self createTriangleShapeAndPhysicsBodyWithSideLength:size andPoints:points];
                break;
                
            default:
                [self createSquareShapeAndPhysicsBodyWithSideLength:size andPoints:points];
        }

        self.physicsBody.dynamic = YES;
    }
    
    return self;
}

-(void)createCircleShapeAndPhysicsBodyWithRadius:(float)radius andPoints:(int)points{
    self.path = CreateCirclePath(size/2);
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:size/2];
    self.fillColor = [SKColor whiteColor];
}

-(void)createTriangleShapeAndPhysicsBodyWithSideLength:(float)length andPoints:(int)points{
    self.path = CreateTrianglePath(length);
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:self.path];
    self.fillColor = [SKColor whiteColor];
}

-(void)createSquareShapeAndPhysicsBodyWithSideLength:(float)length andPoints:(int)points{
    self.path = CreateSquarePath(length);
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:self.path];
    self.fillColor = [SKColor whiteColor];
}

@end
