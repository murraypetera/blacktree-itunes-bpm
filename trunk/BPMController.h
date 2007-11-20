/* BPMController */

#import <Cocoa/Cocoa.h>
#define BEATCOUNT 32

@interface BPMController : NSObject
{

    IBOutlet NSButton *beatButton;
    IBOutlet NSButton *beatButtonL;
    IBOutlet NSButton *beatButtonR;
    

    IBOutlet NSTextField *beatField;

    IBOutlet NSWindow *BPMFloater;
    float BPM;

    //NSMutableArray *beatArray;
    NSTimer *beatTimer;
    NSTimeInterval beatArray[BEATCOUNT];
    NSTimeInterval currentBeat;
    NSTimeInterval avgBeat;

    bool stable;
    bool active;
    bool delayBeat;
    bool manualBPM;
}

- (IBAction)increaseBPM:(id)sender;
- (IBAction)decreaseBPM:(id)sender;

- (void)setBPM:(float)bpm;

- (IBAction)beat:(id)sender;
- (void)setBeatTimerWithInterval:(NSTimeInterval)interval lastBeat:(NSTimeInterval)lastBeat;
- (IBAction)setCurrentTrackBPM:(id)sender;
    
@end
