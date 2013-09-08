//
//  ActionFactory.h
//  yapg
//
//  Created by Oliver Widder on 9/8/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface ActionFactory : NSObject

+(void)applyDestroyActionOnLineNode:(SKShapeNode *)lineNode;

@end
