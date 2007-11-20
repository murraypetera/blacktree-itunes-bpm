//
//  BPMButton.m
//  iTunes-BPM
//
//  Created by Nicholas Jitkoff on Mon May 12 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "BPMButton.h"
#import "BPMButtonCell.h"


@implementation BPMButton

- (void)mouseDown:(NSEvent *)theEvent{

    [[self target] performSelector:[self action]];
}

- (void)mouseUp:(NSEvent *)theEvent{
}



@end
