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
#import <UIKit/UIKit.h>

// length between the points a and b
CGFloat Distance(CGPoint a, CGPoint b);

// length of the line from (0,0) to p
CGFloat Length(CGPoint p);

// angle of the line between a and b in radian
CGFloat Phi(CGPoint a, CGPoint b);

BOOL IsPositionValid(CGPoint position);
void InvalidatePosition(CGPoint *position);

float RandomFloatBetween(float smallNumber, float bigNumber);

CGPoint MiddlePositionBetweenTwoPositions(CGPoint a, CGPoint b);

CGPoint PositionRelativeToBase(CGPoint base, CGPoint p);

CGMutablePathRef CreateBezierPathFromArrayOfPositions(NSMutableArray *positions);

CGMutablePathRef CreateCirclePath(float radius);

CGMutablePathRef CreateTrianglePath(float sideLength);

CGMutablePathRef CreateSquarePath(float sideLength);

CGMutablePathRef CreateRectanglePath(float a, float b);

CGMutablePathRef CreateLinePath(float length);

CGRect MainScreenSize();

CGRect DefaultSceneSize();

NSString *AddIntToString(NSString *string, int number);

#endif
