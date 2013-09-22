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
+(void)addToGameLayer:(SKNode *)node;
+(void)addToDebugLayer:(SKNode *)node;
+(NSString *)bottomName;

-(id)initWithFrame:(CGRect)frame;

-(void)printDebugMessage:(NSString *)message;

@property(readonly) SKNode *gameLayer;
@property(readonly) SKNode *debugLayer;

@end
