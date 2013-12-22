//
//  BrickDrawer.m
//  yapg
//
//  Created by Oliver Widder on 22/12/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "BrickDrawer.h"
#import "Brick.h"

@interface BrickDrawer () {
    CGPoint _positionWhenTouchBegan;
    SKScene *_scene;
    Brick *_currentBrick;
    
    BOOL _brickDrawBegan;
}

@end

@implementation BrickDrawer

-(id)initWithScene:(SKScene *)scene {
    if(self = [super init]) {
        _scene = scene;
        _brickDrawBegan = NO;
    }
    
    return self;
}

#pragma mark touch handling

-(BOOL)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL processed = NO;
    
    if([touches count] == 1) {
        // no multitouch:
        UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
        CGPoint positionOfFirstTouch = [firstTouch locationInNode:_scene];
        _positionWhenTouchBegan = positionOfFirstTouch;
        _brickDrawBegan = YES;
        
        processed = YES;
    }
    
    return processed;
}

-(BOOL)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL processed = NO;
    
    if(_brickDrawBegan) {
        _brickDrawBegan = NO;
        _currentBrick = NULL;
        processed = YES;
    }
    
    return processed;
}

-(BOOL)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL processed = NO;
    
    if(_brickDrawBegan) {
        UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
        CGPoint positionOfFirstTouch = [firstTouch locationInNode:_scene];
        if(_currentBrick == NULL) {
            _currentBrick = [[Brick alloc] initWithAbsolutePositionOfBrick:_positionWhenTouchBegan];
        }
        
        [_currentBrick updateWithAbsolutePositionOfBrickSegment:positionOfFirstTouch];
        
        processed = YES;
    }
    
    return processed;
}

-(BOOL)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    return [self touchesEnded:touches withEvent:event];
}

@end
