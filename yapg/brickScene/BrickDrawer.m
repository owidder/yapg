//
//  BrickDrawer.m
//  yapg
//
//  Created by Oliver Widder on 22/12/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "BrickDrawer.h"
#import "Brick.h"
#import "Field.h"

@interface BrickDrawer ()

@property SKScene *scene;
@property CGPoint positionWhenTouchBegan;
@property BOOL brickDrawBegan;
@property Brick *currentBrick;

@end

@implementation BrickDrawer

-(id)initWithScene:(SKScene *)scene {
    if(self = [super init]) {
        self.scene = scene;
        self.brickDrawBegan = NO;
    }
    
    return self;
}

#pragma mark touch handling

-(BOOL)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL processed = NO;
    
    if([touches count] == 1) {
        // no multitouch:
        UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
        CGPoint positionOfFirstTouch = [[Field instance] positionOfTouchInGameLayer:firstTouch];
        self.positionWhenTouchBegan = positionOfFirstTouch;
        self.brickDrawBegan = YES;
        
        processed = YES;
    }
    
    return processed;
}

-(BOOL)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL processed = NO;
    
    if(self.brickDrawBegan) {
        self.brickDrawBegan = NO;
        self.currentBrick = NULL;
        processed = YES;
    }
    
    return processed;
}

-(BOOL)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL processed = NO;
    
    if(self.brickDrawBegan) {
        UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
        CGPoint positionOfFirstTouch = [[Field instance] positionOfTouchInGameLayer:firstTouch];
        if(self.currentBrick == NULL) {
            self.currentBrick = [[Brick alloc] initWithAbsolutePositionOfBrick:self.positionWhenTouchBegan];
        }
        
        [self.currentBrick updateWithAbsolutePositionOfBrickSegment:positionOfFirstTouch];
        
        processed = YES;
    }
    
    return processed;
}

-(BOOL)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    return [self touchesEnded:touches withEvent:event];
}

@end
