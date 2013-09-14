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

// angle of the line between a and b in radian
CGFloat phi(CGPoint a, CGPoint b);

BOOL isPositionValid(CGPoint position);
void invalidatePosition(CGPoint *position);

#endif
