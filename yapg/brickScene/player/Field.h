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
+(NSString *)targetName;
+(CGRect)mainAreaRect;
+(CGRect)ballStartAreaRect;

-(id)init;

#pragma mark debug layer
-(void)printDebugMessage:(NSString *)message;

#pragma mark game layer
+(void)setEdgesFlag:(BOOL)edgesFlag;
-(void)addToGameLayer:(SKNode *)node;
-(void)scrollGameLayer:(float)offset;
-(CGPoint)positionOfTouchInGameLayer:(UITouch *)touch;
-(CGPoint)convertPointToGameLayerCoordinates:(CGPoint)point;

#pragma mark points layer
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
