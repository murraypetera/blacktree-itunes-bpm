#import "BPMController.h"
#import <math.h>
#import "Carbon/Carbon.h"
#import "NSWorkspace_BLTRExtensions.h"
#import "HotKeyCenter.h"
@implementation BPMController


- (void)awakeFromNib{
    currentBeat=0;
    beatTimer=nil;
    [self setBeatTimerWithInterval:1.0 lastBeat:[NSDate timeIntervalSinceReferenceDate]] ;
    [BPMFloater setHidesOnDeactivate:NO];
    [BPMFloater setFrameUsingName:@"BPMFloater"];

    avgBeat=1;
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(appTerminated:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(appChanged:) name:@"com.apple.HIToolbox.menuBarShownNotification" object:nil];
	active=YES;
   // HotKeyCenter *center=[HotKeyCenter sharedCenter];
    //[center addHotKey:@"ActivateTab" combo:[KeyCombo keyComboWithKeyCode:48 andModifiers:(cmdKey)] target:self action:@selector(switch:)];
    //[center addHotKey:@"ActivateShiftTab" combo:[KeyCombo keyComboWithKeyCode:48 andModifiers:(cmdKey|shiftKey)] target:self action:@selector(switch:)];
    
}





- (void)appChanged:(NSNotification *)aNotification{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    //NSLog(@"appchanged");
    NSString *currentApp=[[[NSWorkspace sharedWorkspace] activeApplication] objectForKey:@"NSApplicationName"];
    NSLog(@"switch to %@",currentApp);
    if (active=[currentApp isEqualToString:@"iTunes"]){
        //[[HotKeyCenter sharedCenter] addHotKey:@"beatKey" combo:[KeyCombo keyComboWithKeyCode:48 andModifiers:optionKey] target:self action:@selector(beat:)];
        [BPMFloater orderFront:nil]; //If window is active, show it
    }else if (![defaults boolForKey:@"universalInspector"]){
        //[[HotKeyCenter sharedCenter] removeHotKey:@"beatKey"];
        [BPMFloater orderOut:nil];
        [beatTimer invalidate];
        [beatButtonL setState:0];
        [beatButtonR setState:0];
    }
    //[mainWindow saveFrameUsingName:@"mainWindow"];
    
    //lastApp=[currentApp copy];
}

- (void)appTerminated:(NSNotification*)notif{
    NSString *terminatedApp=[[notif userInfo] objectForKey:@"NSApplicationName"];
    if ([terminatedApp isEqualToString:@"iTunes"]){
        [NSApp terminate:self];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification{

    [BPMFloater saveFrameUsingName:@"BPMFloater"];
}

- (BOOL)windowShouldClose:(id)sender{
    [BPMFloater saveFrameUsingName:@"BPMFloater"];
    [NSApp terminate:self];
    return YES;
}
- (void)windowDidBecomeKey:(NSNotification *)aNotification{
    [BPMFloater makeFirstResponder:beatButton];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    [BPMFloater orderFront:nil];
     [[NSWorkspace sharedWorkspace] openFile:@"/Applications/iTunes.app"];
 //   NSLog(@"active:%@",[[[NSWorkspace sharedWorkspace]activeApplication]objectForKey:@"NSApplicationName"]);
}




- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag{
    //[BPMFloater orderFront:nil];
    [[NSWorkspace sharedWorkspace] activateApplication:@"/Applications/iTunes.app"];
    return YES;
}

-(BOOL)iTunesIsRunning{
    //NSLog(@"launch:\r%@",[[NSWorkspace sharedWorkspace]launchedApplications]);
    NSString *appName;
    NSEnumerator *appEnumerator=[[[NSWorkspace sharedWorkspace]launchedApplications]objectEnumerator];
    while (appName=[[appEnumerator nextObject]objectForKey:@"NSApplicationName"])
        if ([appName isEqualToString:@"iTunes"])return YES;
    return NO;
}

- (void)simuBeat:(NSTimer *)timer{
    [beatButtonL setState:![beatButtonL state]];
    [beatButtonR setState:![beatButtonL state]];

    [beatButtonL display];
    [beatButtonR display];

    if (delayBeat)
        delayBeat=NO;
    else{
        [beatButton setState:![beatButton state]];
        [beatButton display];
    }
    //[beatField setEnabled:![beatField enabled]];
    
}


- (IBAction)setCurrentTrackBPM:(id)sender{

    NSTimeInterval tick=[NSDate timeIntervalSinceReferenceDate];
    
    if (0){
        NSDictionary *errorDict=nil;
        [[[[NSAppleScript alloc]autorelease]initWithSource:
            [NSString stringWithFormat:@"tell application \"iTunes\" to if not player state = stopped then set bpm of current track to %d", [beatField intValue]]]executeAndReturnError:&errorDict];
        if (errorDict){
            NSLog(@"AppleScript Error: %@",[errorDict objectForKey:@"NSAppleScriptErrorMessage"]);
            NSBeep();
        }

    }else{
        long bpm=[beatField intValue];
        OSType adrITunes = 'hook';

        AppleEvent event={typeNull,0};
        AEBuildError error;
        NSString* sendString=[NSString stringWithFormat:@"data: %d,'----':'obj '{form:'prop', want:type('prop'), seld:type('pBPM'), from:'obj '{form:'prop',want:type('prop'),seld:type('pTrk'),from:'null'()}}",bpm];

        OSStatus err = AEBuildAppleEvent ('core', 'setd', typeApplSignature, &adrITunes,
                                          sizeof(adrITunes), kAutoGenerateReturnID, kAnyTransactionID, &event,
                                          &error, [sendString lossyCString]);

        if (err) // print the error and where it occurs
            {
            NSLog(@"%d:%d at \"%@\"",error.fError,error.fErrorPos,
                  [sendString substringToIndex:error.fErrorPos]);
            }
        else
            {

            Handle xx;
            AEPrintDescToHandle(&event, &xx);
            //NSLog(@"Event %s", *xx);
            DisposeHandle(xx);

            AppleEvent reply;
            err=AESend(&event,&reply,kAEWaitReply,kAENormalPriority,kAEDefaultTimeout,NULL,NULL);
            AEDisposeDesc(&event); // we must dispose of this and the reply.
            if (!err)
                {
                Handle xx;
                AEPrintDescToHandle(&reply, &xx);
                //NSLog(@"reply %s", *xx);
                DisposeHandle(xx);


                AEDesc replyDesc;

                OSErr ec;
                AEDesc desc;

                ec = AEGetParamDesc (&reply, (AEKeyword) 'errn', 'shor', &desc);

                if (ec != noErr); /*the reply isn't an error*/
                    //NSLog(@"Yay!");
                else
                    NSBeep();

                AEDisposeDesc (&desc);


                err = AEGetParamDesc(&reply, keyDirectObject, typeWildCard, &replyDesc);
                if (!err)
                    {
                    Handle xx;
                    AEPrintDescToHandle(&replyDesc, &xx);
                    //NSLog(@"replydesc %s", *xx);
                    DisposeHandle(xx);
                    }


               // NSLog(@"succeeded");
                // do something to get reply.
                NSAppleEventDescriptor* descriptor = [[NSAppleEventDescriptor alloc]
 initWithAEDescNoCopy:&replyDesc];
                NSString* string = [descriptor stringValue];
                //NSLog(@"succeeded %@, %d",string,(int)[descriptor int32Value]);
                }
            else
                NSLog(@"Error");
            }    }


 //   NSLog(@"SetDelay:%f",[NSDate timeIntervalSinceReferenceDate]-tick);
}



- (IBAction)beat:(id)sender{
    if (!active) return;
   // NSLog(@"diff: %f",[NSDate timeIntervalSinceReferenceDate]-[[NSApp currentEvent]timestamp]);
    NSTimeInterval currentTime=[NSDate timeIntervalSinceReferenceDate];
    currentBeat=[[NSApp currentEvent]timestamp];
    [beatButtonL setState:1];
    [beatButtonR setState:1];

    [beatButton setState:![beatButton state]];
    [[beatButtonL window]display];
    
  //  float avgBeat=60;
    int i=0;
    
    for (i=(BEATCOUNT-1);i>0;i--){
        beatArray[i]=beatArray[i-1];
        // NSLog(@"%2d: %f",i,beatArray[i-1]);
    }
    beatArray[0]=currentBeat;
    
    float beatDifference=1;

    stable=YES;

    avgBeat=60/[beatField floatValue];
    int validBeats;


    for (i=0;i<(BEATCOUNT-1);i++){
        beatDifference=beatArray[i] - beatArray[i+1];

        stable=(fabs((beatDifference-avgBeat)/avgBeat)<0.3);
        
        if (beatDifference>2.5 || (i>2 && !stable) || !beatArray[i]) break;
        //NSLog(@"%2d: %f, %f",i,fabs(beatDifference-avgBeat),fabs((beatDifference-avgBeat)/avgBeat));
        
        stable = stable & (beatDifference-avgBeat<.1);      
        //NSLog(@"%2d: %f",i,beatDifference);
        avgBeat=(avgBeat*i + beatDifference)/(i+1);
    }
    validBeats=i;

    float deviation=0;

    if (validBeats>0){
       // avgBeat=(beatArray[0]-beatArray[validBeats])/validBeats;

        for (i=0;i<validBeats;i++){
            deviation+= pow((beatArray[i] - beatArray[i+1])-avgBeat,2);
        }

        deviation/=validBeats;
        deviation=sqrt(deviation);
    }
    

    deviation=((deviation/avgBeat)-0.05)*20;


  //  NSLog(@"%2d Beats - %f,%f",validBeats, round(60/avgBeat), deviation);

    if (i<6) deviation=(deviation*i+(6-i)*1)/6;


    
    [beatField setIntValue:round(60/avgBeat)];

    NSColor *readoutColor=[[NSColor blackColor]blendedColorWithFraction:((float)validBeats/(float)(BEATCOUNT-1)) ofColor:[NSColor blueColor]];
    readoutColor=[readoutColor blendedColorWithFraction:deviation ofColor:[NSColor grayColor]];

        
    if (validBeats) [beatField setTextColor:readoutColor];

    [beatButtonL setState:0];
    [beatButtonR setState:0];
    
    //[self simuBeat:nil];

        delayBeat=validBeats;
    [self setBeatTimerWithInterval:avgBeat lastBeat:currentTime];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"autoSet"] && deviation<0) [self setCurrentTrackBPM:self];
}

- (IBAction)increaseBPM:(id)sender{
    [self setBPM:[beatField floatValue]+1];
}

- (IBAction)decreaseBPM:(id)sender{
    [self setBPM:[beatField floatValue]-1];
}

- (void)setBPM:(float)bpm{
    if (bpm>1000 || bpm<1) return;
    NSTimeInterval lastBeat;

    if ([beatTimer isValid])
        lastBeat=[[beatTimer fireDate]timeIntervalSinceReferenceDate];
    else
        lastBeat=[NSDate timeIntervalSinceReferenceDate];

    delayBeat=NO;
    [self setBeatTimerWithInterval:60/bpm lastBeat:lastBeat-60/bpm];
    [beatField setIntValue:bpm];
    [beatField setTextColor:[NSColor blackColor]];
    manualBPM=YES;
}

- (void)setBeatTimerWithInterval:(NSTimeInterval)interval lastBeat:(NSTimeInterval)lastBeat{
    //NSLog(@"TIMER %f, %f",interval, lastBeat);
    if ([beatTimer isValid]){
        [beatTimer invalidate];
        [beatTimer release];
    }


    NSTimeInterval nextBeat=lastBeat+interval;
    beatTimer=[[NSTimer alloc]initWithFireDate:[NSDate dateWithTimeIntervalSinceReferenceDate:nextBeat] interval:interval target:self selector:@selector(simuBeat:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:beatTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:beatTimer forMode:NSModalPanelRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:beatTimer forMode:NSEventTrackingRunLoopMode];
}






@end
