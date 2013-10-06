//
//  Stuff2.h
//  yapg
//
//  Created by Oliver Widder on 10/5/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
    k2Circle = 1,
    k2Triangle = 2,
    k2Square = 3
} StuffType2;

@interface Stuff2 : SKShapeNode

-(id)initWithType:(StuffType2)type andPosition:(CGPoint)position andPoints:(int)points;

@end
