//
//  ActionFactory.m
//  yapg
//
//  Created by Oliver Widder on 9/8/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "ActionFactory.h"
#import "EmitterNodeFactory.h"

@implementation ActionFactory

+(void)runFadeOutDestroyActionOnNode:(SKNode *)node {
    SKAction *fadeOutAction = [SKAction fadeOutWithDuration:10.0];
    SKAction *removeAction = [SKAction removeFromParent];
    SKAction *seqAction = [SKAction sequence:@[fadeOutAction, removeAction]];
    [node runAction:seqAction];
}

+(void)runSmokeDestroyActionOnNode:(SKNode *)node {
//    SKAction *fadeOutAction = [SKAction fadeOutWithDuration:0.1];
    SKEmitterNode *smokeEmitter = [EmitterNodeFactory newSmokeEmitter];
    SKAction *addSmokeAction = [SKAction runBlock:^(void){[node addChild:smokeEmitter];}];
    SKAction *waitAction = [SKAction waitForDuration:3.0];
    SKAction *removeAction = [SKAction removeFromParent];
    SKAction *seqAction = [SKAction sequence:@[addSmokeAction, waitAction, removeAction]];
    [node runAction:seqAction];
}

@end
