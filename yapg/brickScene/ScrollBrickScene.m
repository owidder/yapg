//
//  ScrollBrickScene.m
//  yapg
//
//  Created by Oliver Widder on 26/11/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "ScrollBrickScene.h"
#import "SceneManager.h"

@interface ScrollBrickScene() {

    CGPoint positionWhenTouchBegan;

}

@end

@implementation ScrollBrickScene

#pragma mark touch handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if([touches count] > 1) {
        // multitouch --> pause game
        [[SceneManager instance] gosubIntoSceneWithType:kPauseScene fromCurrentScene:self];
    }
    else {
        // no multitouch:
        UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
        CGPoint positionOfFirstTouch = [firstTouch locationInNode:self];        
        positionWhenTouchBegan = positionOfFirstTouch;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    currentBrick = NULL;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    CGPoint positionOfFirstTouch = [firstTouch locationInNode:self];
    if(!gameStarted) {
        if(currentBrick == NULL) {
            currentBrick = [[Brick alloc] initWithAbsolutePositionOfBrick:positionWhenTouchBegan];
        }
        
        [currentBrick updateWithAbsolutePositionOfBrickSegment:positionOfFirstTouch];
    }
    else {
        [[Field instance] removeAllNodesInGameLayerWithName:[Brick name] andPosition:positionOfFirstTouch];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    currentBrick = NULL;
}



@end
