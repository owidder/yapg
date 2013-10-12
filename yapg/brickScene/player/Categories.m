//
//  Categories.m
//  yapg
//
//  Created by Oliver Widder on 9/21/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#import "Categories.h"

@implementation Categories

+(uint32_t)bottomCategory {
    return 0x1 << 0;
}

+(uint32_t)ballCategory {
    return 0x1 << 1;
}

+(uint32_t)stuffCategory {
    return 0x1 << 2;
}

@end
