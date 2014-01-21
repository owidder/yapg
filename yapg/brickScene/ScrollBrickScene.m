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

@interface ScrollBrickScene()

@property BrickDrawer *brickDrawer;
@property SceneHandler *sceneHandler;

@end

@implementation ScrollBrickScene

-(id)initWithSize:(CGSize)size {
    if(self = [super initWithSize:size]) {
        self.brickDrawer = [[BrickDrawer alloc] initWithScene:self];
        self.sceneHandler = [[SceneHandler alloc] initWithScene:self];
    }
    
    return self;
}

#pragma mark touch handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(![self.sceneHandler touchesBegan:touches withEvent:event]) {
        [self.brickDrawer touchesBegan:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.brickDrawer touchesEnded:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.brickDrawer touchesMoved:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.brickDrawer touchesCancelled:touches withEvent:event];
}



@end
