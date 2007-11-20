//
//  DaedalApp.m
//  Daedalus
//
//  Created by Nicholas Jitkoff on Mon Mar 03 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "BPMApp.h"
#import "HotKeyCenter.h"

#import "BPMController.h"
@implementation BPMApp

- (void)sendEvent:(NSEvent *)theEvent{

  //  [[HotKeyCenter sharedCenter] sendEvent: theEvent];
    
   // NSLog(@"event %i",[theEvent type]);
    if ([theEvent type]==NSKeyDown){
        if (![theEvent isARepeat])
            [(BPMController *)[self delegate]beat:theEvent];
    }
    else [super sendEvent:theEvent];
}
@end
