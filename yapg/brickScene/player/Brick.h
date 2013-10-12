//
//  Brick.h
//  yapg
//
//  Created by Oliver Widder on 9/23/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Brick : SKShapeNode

+(NSString *)name;

-(id)initWithAbsolutePositionOfBrick:(CGPoint)position;

-(void)updateWithAbsolutePositionOfBrickSegment:(CGPoint)position;

@end
