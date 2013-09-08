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
    SKAction *fallDownAction = [SKAction runBlock:^(void){lineNode.physicsBody.dynamic = YES;}];
    SKAction *waitAction = [SKAction waitForDuration:5.0];
    SKAction *destroyActions = [SKAction sequence:@[waitAction, fallDownAction]];
    [lineNode runAction:destroyActions];
}

@end
