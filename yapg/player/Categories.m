//
//  Categories.m
//  yapg
//
//  Created by Oliver Widder on 9/21/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "Categories.h"

static const uint32_t bottomCategory = 0x1 << 0;
static const uint32_t ballCategory = 0x1 << 1;
static const uint32_t stuffCategory = 0x1 << 2;

@implementation Categories

+(uint32_t)bottomCategory {
    return bottomCategory;
}

+(uint32_t)ballCategory {
    return ballCategory;
}

+(uint32_t)stuffCategory {
    return stuffCategory;
}

@end
