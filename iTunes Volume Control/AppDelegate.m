//
//  AppDelegate.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 25.12.12.
//  Copyright (c) 2012 Andrea Alberti. All rights reserved.
//

#import "AppDelegate.h"
#import <IOKit/hidsystem/ev_keymap.h>

static CGEventRef event_tap_callback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    NSEvent * sysEvent;
    
    // No event we care for? return ASAP
    if (type != NX_SYSDEFINED) return event;
    
    sysEvent = [NSEvent eventWithCGEvent:event];
    // No need to test event type, we know it is NSSystemDefined, becuase that is the same as NX_SYSDEFINED
    if ([sysEvent subtype] != 8) return event;
    
    int keyFlags = ([sysEvent data1] & 0x0000FFFF);
    int keyCode = (([sysEvent data1] & 0xFFFF0000) >> 16);
    int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
    BOOL keyIsRepeat = (keyFlags & 0x1);
    // We probably won't care for repeating events
    // if (keyIsRepeat) return event;
    
    switch( keyCode )
	{
		case NX_KEYTYPE_SOUND_UP:
        case NX_KEYTYPE_SOUND_DOWN:
            NSLog(@"%d",keyIsRepeat);
            if( (([sysEvent modifierFlags]&NX_COMMANDMASK)==NX_COMMANDMASK) && ([sysEvent modifierFlags]&NX_SHIFTMASK)!=NX_SHIFTMASK)
            {
                if( keyState == 1 )
                {
                    if( keyCode == NX_KEYTYPE_SOUND_UP )
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"IncreaseITunesVolume" object:NULL];
                    else
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DecreaseITunesVolume" object:NULL];
                }
                return NULL;
            }
            break;
    }
    
    
    return event;
}

@implementation AppDelegate

- (void)rampVolumeUp:(NSTimer*)theTimer
{
    [self changeVol:2];
}

- (void)rampVolumeDown:(NSTimer*)theTimer
{
    [self changeVol:-2];
}

- (void)createEventTap
{
    CGEventMask eventMask = (/*(1 << kCGEventKeyDown) | (1 << kCGEventKeyUp) |*/CGEventMaskBit(NX_SYSDEFINED));
    eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault,
                                eventMask, event_tap_callback, NULL); // Create an event tap. We are interested in SYS key presses.
    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0); // Create a run loop source.
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes); // Add to the current run loop.
    CGEventTapEnable(eventTap, true); // Enable the event tap.
}

- (void) appleRemoteInit
{
    remote = [[AppleRemote alloc] init];
    [remote setDelegate:self];
    [remote startListening:self];
}

- (void)playPauseITunes:(NSNotification *)aNotification
{
    // check if iTunes is running (Q1)
    if ([iTunes isRunning])
    {
        [iTunes playpause];
    }
}

- (void)nextTrackITunes:(NSNotification *)aNotification
{
    if ([iTunes isRunning])
    {
        [iTunes nextTrack];
    }
}

- (void)previousTrackITunes:(NSNotification *)aNotification
{
    if ([iTunes isRunning])
    {
        [iTunes previousTrack];
    }
}

- (void) appleRemoteButton: (AppleRemoteEventIdentifier)buttonIdentifier pressedDown: (BOOL) pressedDown clickCount: (unsigned int) count {
    switch (buttonIdentifier)
    {
        case kRemoteButtonVolume_Plus_Hold:
            if(timer==nil)
                timer=[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(rampVolumeUp:) userInfo:nil repeats:YES];
            else
            {
                [timer invalidate];
                timer=nil;
            }
            break;
        case kRemoteButtonVolume_Plus:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"IncreaseITunesVolume" object:NULL];
            break;
            
        case kRemoteButtonVolume_Minus_Hold:
            if(timer==nil)
                timer=[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(rampVolumeDown:) userInfo:nil repeats:YES];
            else
            {
                [timer invalidate];
                timer=nil;
            }
            break;
        case kRemoteButtonVolume_Minus:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DecreaseITunesVolume" object:NULL];
            break;
            
        case k2009RemoteButtonFullscreen:
            break;
            
        case k2009RemoteButtonPlay:
        case kRemoteButtonPlay:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayPauseITunes" object:NULL];
            break;
            
        case kRemoteButtonLeft_Hold:
        case kRemoteButtonLeft:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PreviousTrackITunes" object:NULL];
            break;
            
        case kRemoteButtonRight_Hold:
        case kRemoteButtonRight:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NextTrackITunes" object:NULL];
            break;
            
        case kRemoteButtonMenu_Hold:
        case kRemoteButtonMenu:
            break;
            
        case kRemoteButtonPlay_Sleep:
            break;
            
        default:
            break;
    }
}

- (void)increaseITunesVolume:(NSNotification *)aNotification
{
    //NSLog(@"Increase");
    [self changeVol:+2];
}

- (void)decreaseITunesVolume:(NSNotification *)aNotification
{
    // NSLog(@"Decrease");
    [self changeVol:-2];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    // [statusItem setTitle:@"iTunes Volume Control"];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    
    statusImageOn = [NSImage imageNamed:@"statusbar-item-on.png"];
    statusImageOff = [NSImage imageNamed:@"statusbar-item-off.png"];
    
    [statusItem setImage:statusImageOn];
    
    iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseITunesVolume:) name:@"IncreaseITunesVolume" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decreaseITunesVolume:) name:@"DecreaseITunesVolume" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playPauseITunes:) name:@"PlayPauseITunes" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextTrackITunes:) name:@"NextTrackITunes" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(previousTrackITunes:) name:@"PreviousTrackITunes" object:nil];
    
    [self createEventTap];
    
    [self appleRemoteInit];
}

- (IBAction)reduceVolMenuAction:(id)sender
{
    [self changeVol:-2];
}

- (IBAction)increaseVolMenuAction:(id)sender
{
    [self changeVol:+2];
}

- (IBAction)toggleTapStatus:(id)sender
{
    NSMenuItem* changeStatusItem=[statusMenu itemWithTag:1];
    if(CGEventTapIsEnabled(eventTap))
    {
        CGEventTapEnable(eventTap, false);
        [changeStatusItem setState:0];
        [statusItem setImage:statusImageOff];
        [remote stopListening:self];
    }
    else
    {
        CGEventTapEnable(eventTap, true);
        [changeStatusItem setState:1];
        [statusItem setImage:statusImageOn];
        [remote startListening:self];
    }
}

- (IBAction)aboutPanel:(id)sender
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:sender];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CGEventTapEnable(eventTap, false);
}

- (void)changeVol:(int)vol
{
    // check if iTunes is running (Q1)
    if ([iTunes isRunning])
    {
        NSInteger volume = [iTunes soundVolume]+vol;
        if (volume<0) volume=0;
        if (volume>100) volume=100;
        
        [iTunes setSoundVolume:volume];
        
        // NSLog(@"The new volume is: %ld",[iTunes soundVolume]);
    }
}

@end
