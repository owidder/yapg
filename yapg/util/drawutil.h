//
//  math.h
//  yapg
//
//  Created by Oliver Widder on 9/7/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#ifndef yapg_math_h
#define yapg_math_h

#include <CoreGraphics/CGBase.h>

// length between the points a and b
CGFloat distance(CGPoint a, CGPoint b);

// length of the line from (0,0) to p
CGFloat length(CGPoint p);

// angle of the line between a and b in radian
CGFloat phi(CGPoint a, CGPoint b);

BOOL isPositionValid(CGPoint position);
void invalidatePosition(CGPoint *position);

CGPoint middlePositionBetweenTwoPositions(CGPoint a, CGPoint b);

CGPoint positionRelativeToBase(CGPoint base, CGPoint p);

CGMutablePathRef createBezierPathFromArrayOfPositions(NSMutableArray *positions);

#endif
