//
//  SBiTunesInspector.m
//  Sublimation
//
//  Created by Nicholas Jitkoff on Mon Jan 13 2003.
//  Copyright (c) 2003 Blacktree, Inc. All rights reserved.
//

#import "SBiTunesInspector.h"


@implementation SBiTunesInspector

- (NSTimeInterval)animationResizeTime:(NSRect)newFrame{
    return 0.25;

}

- (BOOL)canBecomeKeyWindow{
    //NSLog(@"%i",([[NSApp currentEvent]modifierFlags]&NSAlternateKeyMask));
    if ([[NSApp currentEvent]modifierFlags]&NSAlternateKeyMask)
        keyMode=YES;

    return keyMode;
    
}
- (BOOL)canBecomeMainWindow{return NO;}

@end
