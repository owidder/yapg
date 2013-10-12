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
+(CGRect)mainAreaRect;
+(CGRect)ballStartAreaRect;

-(id)init;

-(void)printDebugMessage:(NSString *)message;
-(void)addToGameLayer:(SKNode *)node;
-(void)addPoints:(int)points;
-(void)setLevel:(int)level;
-(void)addTotalPoints:(int)points;
-(void)showNumberOfSecondsAsMinSec:(int)numberOfSeconds;

-(BOOL)doesNodeExistInGameLayer:(NSString *)nodeName;
-(SKNode *)findNodeInGameLayerWithName:(NSString *)nodeName;
-(NSArray *)findAllNodesInGameLayerWithName:(NSString *)nodeName;
-(void)removeAllNodesInGameLayerWithName:(NSString *)name andPosition:(CGPoint)position;
-(CGPoint)positionOfNodeInGameLayerWithName:(NSString *)name;

-(void)reset;

@property(readonly) int points;

@end
