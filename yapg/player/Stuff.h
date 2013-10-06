//
//  Stuff.h
//  yapg
//
//  Created by Oliver Widder on 9/23/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
    kCircle = 1,
    kTriangle = 2,
    kSquare = 3
    } StuffType;

@interface Stuff : SKShapeNode

-(id)initWithType:(StuffType)type andPosition:(CGPoint)position;

-(void)collided;

+(NSString *)name;

+(void)addStuffWithType:(StuffType)type andPosition:(CGPoint)position;

@property(readonly) int points;

@end
