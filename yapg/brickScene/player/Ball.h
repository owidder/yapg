//
//  Ball.h
//  yapg
//
//  Created by Oliver Widder on 9/21/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Ball : SKShapeNode

-(id)initWithPosition:(CGPoint)position andDuration:(float)duration;

-(void)die;

+(NSString *)name;

+(void)addBallAtPosition:(CGPoint)position withDuration:(float)duration;

@end
