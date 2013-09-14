//
//  EmitterNodeFactory.m
//  yapg
//
//  Created by Oliver Widder on 9/12/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "EmitterNodeFactory.h"

@implementation EmitterNodeFactory

+(SKEmitterNode *)newSmokeEmitter {
    NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"smoke" ofType:@"sks"];
    SKEmitterNode *smoke = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
    return smoke;
}

+(SKEmitterNode *)newSparkEmitter {
    NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"spark" ofType:@"sks"];
    SKEmitterNode *smoke = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
    return smoke;
}

@end
