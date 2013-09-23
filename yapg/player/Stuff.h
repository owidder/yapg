//
//  Stuff.h
//  yapg
//
//  Created by Oliver Widder on 9/23/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Stuff : SKShapeNode

-(id)initWithPosition:(CGPoint)position;

-(void)collidedWith:(SKNode *)collisionPartner;

+(NSString *)name;

+(void)addStuffAtPosition:(CGPoint)position;

@end
