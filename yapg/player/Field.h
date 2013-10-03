//
//  Field.h
//  yapg
//
//  Created by Oliver Widder on 9/21/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Field : SKNode

+(Field*)instance;
+(NSString *)bottomName;

-(id)init;

-(void)printDebugMessage:(NSString *)message;
-(void)addToGameLayer:(SKNode *)node;
-(void)addPoints:(int)points;
-(void)showNumberOfSecondsAsMinSec:(int)numberOfSeconds;

-(BOOL)doesNodeExistInGameLayer:(NSString *)nodeName;
-(SKNode *)findNodeInGameLayerWithName:(NSString *)nodeName;

-(void)reset;

@end
