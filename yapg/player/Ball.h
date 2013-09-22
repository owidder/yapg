//
//  Ball.h
//  yapg
//
//  Created by Oliver Widder on 9/21/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Ball : SKNode

-(id)initWithPosition:(CGPoint)position;

-(void)die;

+(NSString *)name;

+(void)addBallAtPosition:(CGPoint)position;

@end