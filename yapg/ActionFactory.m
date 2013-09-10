//
//  ActionFactory.m
//  yapg
//
//  Created by Oliver Widder on 9/8/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "ActionFactory.h"

@implementation ActionFactory

+(void)applyDestroyActionOnLineNode:(SKShapeNode *)lineNode {
    SKAction *fadeOutAction = [SKAction fadeOutWithDuration:10.0];
    SKAction *removeAction = [SKAction removeFromParent];
    SKAction *seqAction = [SKAction sequence:@[fadeOutAction, removeAction]];
    [lineNode runAction:seqAction];
}

@end
