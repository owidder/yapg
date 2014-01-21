//
//  TouchHandler.h
//  yapg
//
//  Created by Oliver Widder on 22/12/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol TouchHandler <NSObject>

-(id)initWithScene:(SKScene *)scene;

@optional
-(BOOL)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(BOOL)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(BOOL)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(BOOL)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end