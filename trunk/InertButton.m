//
//  InertButton.m
//  Daedalus
//
//  Created by Nicholas Jitkoff on Tue Apr 01 2003.
//  Copyright (c) 2003 Blacktree, Inc. All rights reserved.
//

#import "InertButton.h"


@implementation InertButton

- (BOOL)mouseDownCanMoveWindow{
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent{
}

-(void)setFrameTopLeftPoint:(NSPoint)point{
    NSLog(@"argh");
}

@end
