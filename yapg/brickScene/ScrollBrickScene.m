//
//  ScrollBrickScene.m
//  yapg
//
//  Created by Oliver Widder on 26/11/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "ScrollBrickScene.h"
#import "SceneManager.h"
#import "BrickDrawer.h"
#import "SceneHandler.h"
#import "Field.h"
#import "Ball.h"

#import "drawutil.h"

@interface ScrollBrickScene()

@property BrickDrawer *brickDrawer;
@property SceneHandler *sceneHandler;
@property CGPoint positionWhereTouchBegan;

@end

@implementation ScrollBrickScene

-(id)initWithSize:(CGSize)size {
    if(self = [super initWithSize:size]) {
        [Field setEdgesFlag:NO];
        
        self.brickDrawer = [[BrickDrawer alloc] initWithScene:self];
        self.sceneHandler = [[SceneHandler alloc] initWithScene:self];
        
        [self addChild:[Field instance]];
    }
    
    return self;
}

#pragma mark touch handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    self.positionWhereTouchBegan = [[Field instance] positionOfTouchInGameLayer:firstTouch];
    
    if(![self.sceneHandler touchesBegan:touches withEvent:event]) {
        [self.brickDrawer touchesBegan:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    CGPoint currentPosition = [[Field instance] positionOfTouchInGameLayer:firstTouch];
    
    if(Distance(currentPosition, self.positionWhereTouchBegan) < 1)  {
        [Ball addBallAtPosition:currentPosition];
    }
    
    [self.brickDrawer touchesEnded:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.brickDrawer touchesMoved:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.brickDrawer touchesCancelled:touches withEvent:event];
}

#pragma mark SKScene

-(void)didSimulatePhysics {
    [[Field instance] scrollGameLayer:.1];
}


@end