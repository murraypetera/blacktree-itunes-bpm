//
//  BPMButtonCell.m
//  iTunes-BPM
//
//  Created by Nicholas Jitkoff on Mon May 12 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "BPMButtonCell.h"


@implementation BPMButtonCell
- (int)sendActionOn:(int)mask{
    return NSLeftMouseDown;
}
@end
