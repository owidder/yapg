//
//  ActionFactory.m
//  yapg
//
//  Created by Oliver Widder on 9/8/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "ActionFactory.h"

@implementation ActionFactory

+(void)destroyNodeWithFadeOut:(SKNode *)node {
    SKAction *fadeOutAction = [SKAction fadeOutWithDuration:10.0];
    SKAction *removeAction = [SKAction removeFromParent];
    SKAction *seqAction = [SKAction sequence:@[fadeOutAction, removeAction]];
    [node runAction:seqAction];
}

+(void)destroyNode:(SKNode *)node withEmitter:(SKEmitterNode *)emitter{
    emitter.position = node.position;
    [node.parent addChild:emitter];
    
    SKAction *fadeOutNode = [SKAction fadeOutWithDuration:0.1];
    SKAction *removeNode = [SKAction removeFromParent];
    SKAction *removeNodeSeq = [SKAction sequence:@[fadeOutNode, removeNode]];
    [node runAction:removeNodeSeq];
    
    SKAction *waitBeforeRemoveEmitter = [SKAction waitForDuration:1.0];
    SKAction *scaleOutEmitter = [SKAction scaleTo:0 duration:1.0];
    SKAction *removeEmitter = [SKAction removeFromParent];
    SKAction *removeEmitterSeq = [SKAction sequence:@[waitBeforeRemoveEmitter, scaleOutEmitter, removeEmitter]];
    [emitter runAction:removeEmitterSeq];
}

@end
