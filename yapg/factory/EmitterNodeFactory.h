//
//  EmitterNodeFactory.h
//  yapg
//
//  Created by Oliver Widder on 9/12/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>

@interface EmitterNodeFactory : NSObject

+(SKEmitterNode *)newSmokeEmitter;
+(SKEmitterNode *)newSparkEmitter;

@end
