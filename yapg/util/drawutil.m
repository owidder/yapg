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

CGMutablePathRef createBezierPathFromArrayOfPositions(NSMutableArray *positions) {
    CGMutablePathRef path = CGPathCreateMutable();
    
    NSUInteger numberOfPositions = [positions count];
    if(numberOfPositions > 1) {
        CGPoint *start = [[positions objectAtIndex:0] pointerValue];
        CGPathMoveToPoint(path, NULL, start->x, start->y);
        
        if(numberOfPositions == 2) {
            CGPoint end = [[positions objectAtIndex:1] CGPointValue];
            CGPathAddLineToPoint(path, NULL, end.x, end.y);
        }
        else {
            int i;
            for (i = 1; i < [positions count] - 1; i+=2) {
                CGPoint controlPoint = [[positions objectAtIndex:i] CGPointValue];
                CGPoint endPoint = [[positions objectAtIndex:i+1] CGPointValue];
                CGPathAddQuadCurveToPoint(path, NULL, controlPoint.x, controlPoint.y, endPoint.x, endPoint.y);
            }
            
            if(i < [positions count] - 1) {
                CGPoint *finalPoint = [[positions objectAtIndex:i+1] pointerValue];
                CGPathAddLineToPoint(path, NULL, finalPoint->x, finalPoint->y);
            }
        }
    }
    
    return path;
}
