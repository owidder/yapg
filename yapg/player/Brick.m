//
//  Brick.m
//  yapg
//
//  Created by Oliver Widder on 9/23/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "drawutil.h"

#import "Brick.h"
#import "Field.h"

#define NAME @"brick"

#define MIN_SEGMENT_LENGTH 10
#define LINE_WIDTH 0.1
#define GLOW_WIDTH 1.0

@interface Brick () {
    Field *field;
    NSMutableArray *positions;
    CGMutablePathRef path;
}

-(void)runFadeOutAction:(SKNode *)node;

@end

@implementation Brick

+(NSString *)name {
    return NAME;
}

-(id)initWithAbsolutePositionOfBrick:(CGPoint)position {
    if(self = [super init]) {
        self.name = NAME;
        self.position = position;
        self.lineWidth = LINE_WIDTH;
        self.glowWidth = GLOW_WIDTH;
        self.strokeColor = [SKColor lightGrayColor];

        positions = [NSMutableArray array];
        [positions addObject:[NSValue valueWithPointer:&CGPointZero]];
        
        [Field addToGameLayer:self];
        [self runFadeOutAction:self];
        
        field = [Field instance];
    }
    
    return self;
}

-(void)updateWithAbsolutePositionOfBrickSegment:(CGPoint)position {
    CGPoint relativePosition = PositionRelativeToBase(self.position, position);
    
    NSUInteger indexOfLastElement = [positions count] - 1;
    NSValue *lastElement = [positions objectAtIndex:indexOfLastElement];
    CGPoint lastBrickPosition = [lastElement CGPointValue];
    CGFloat distanceToLastBrickPosition = Distance(lastBrickPosition, relativePosition);
    
    [field printDebugMessage:[NSString stringWithFormat:@"(%f, %f)/(%f,%f) - %d",
                              lastBrickPosition.x, lastBrickPosition.y,
                              relativePosition.x, relativePosition.y,
                              [positions count]]];
    
    if(distanceToLastBrickPosition > MIN_SEGMENT_LENGTH) {
        [positions addObject:[NSValue valueWithCGPoint:relativePosition]];
        path = CreateBezierPathFromArrayOfPositions(positions);
        
        self.path = path;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:path];
    }
}

-(void)runFadeOutAction:(SKNode *)node {
    SKAction *fadeOutAction = [SKAction fadeOutWithDuration:30.0];
    SKAction *removeAction = [SKAction removeFromParent];
    SKAction *seqAction = [SKAction sequence:@[fadeOutAction, removeAction]];
    [node runAction:seqAction];
}

@end
