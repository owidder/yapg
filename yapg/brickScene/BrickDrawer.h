//
//  BrickDrawer.h
//  yapg
//
//  Created by Oliver Widder on 22/12/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "TouchHandler.h"

@interface BrickDrawer : NSObject<TouchHandler>

-(id)initWithScene:(SKScene *)scene;

@end
