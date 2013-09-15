//
//  math.c
//  yapg
//
//  Created by Oliver Widder on 9/7/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#include <stdio.h>
#include <float.h>
#include "drawutil.h"

CGFloat distance(CGPoint a, CGPoint b) {
    CGFloat xdist = a.x - b.x;
    CGFloat ydist = a.y - b.y;
    
    return sqrtf((xdist*xdist) + (ydist*ydist));
}

CGFloat length(CGPoint p) {
    return sqrtf((p.x * p.x) + (p.y * p.y));
}

CGFloat phi(CGPoint a, CGPoint b) {
    CGFloat xdist = a.x - b.x;
    CGFloat ydist = a.y - b.y;
    
    CGFloat phi = atan2f(ydist, xdist);
    
    return phi;
}

BOOL isPositionValid(CGPoint position) {
    if(position.x == FLT_MAX && position.y == FLT_MAX) {
        return NO;
    }
    return YES;
}

void invalidatePosition(CGPoint *position) {
    position->x = FLT_MAX;
    position->y = FLT_MAX;
}

CGPoint middlePositionBetweenTwoPositions(CGPoint a, CGPoint b) {
    CGFloat newX = (a.x + b.x)/2;
    CGFloat newY = (a.y + b.y)/2;
    
    CGPoint middle = CGPointMake(newX, newY);
    
    return middle;
}

CGPoint positionRelativeToBase(CGPoint base, CGPoint p) {
    CGPoint relativePosition = CGPointMake(p.x - base.x, p.y - base.y);
    
    return relativePosition;
}
