//
//  debugutil.m
//  yapg
//
//  Created by Oliver Widder on 10/5/13.
//  Copyright (c) 2013 GeekAndPoke. All rights reserved.
//

#include <stdio.h>

#include "debugutil.h"

void _logAllChildNodesRecursive(SKNode *rootNode, int level) {
    for(id node in [rootNode children]) {
        NSLog(@"node at level %d: %@", level, [node description]);
        _logAllChildNodesRecursive(node, level+1);
    }
}

void LogAllChildNodesDeep(SKNode *rootNode) {
    _logAllChildNodesRecursive(rootNode, 0);
}