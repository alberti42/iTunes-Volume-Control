//
//  AppDelegate.h
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 25.12.12.
//  Copyright (c) 2012 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"
#import "AppleRemote.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    bool StartAtLogin;

    IBOutlet NSMenu *statusMenu;
    
    NSStatusItem *statusItem;
    iTunesApplication *iTunes;
    
    CFMachPortRef eventTap;
    CFRunLoopSourceRef runLoopSource;
    
    NSImage *statusImageOn;
    NSImage *statusImageOff;
    
    AppleRemote* remote;
    bool AppleRemoteConnected;
}

- (IBAction)toggleModifierUse:(id)sender;
- (IBAction)toggleStartAtLogin:(id)sender;
- (IBAction)toggleTapStatus:(id)sender;
- (IBAction)aboutPanel:(id)sender;
- (IBAction)toggleAppleRemote:(id)sender;

- (void) appleRemoteButton: (AppleRemoteEventIdentifier)buttonIdentifier pressedDown: (BOOL) pressedDown clickCount: (unsigned int) count;
- (void) appleRemoteInit;

- (void)createEventTap;

- (void)playPauseITunes:(NSNotification *)aNotification;
- (void)decreaseITunesVolume:(NSNotification *)aNotification;
- (void)increaseITunesVolume:(NSNotification *)aNotification;
- (void)nextTrackITunes:(NSNotification *)aNotification;
- (void)previousTrackITunes:(NSNotification *)aNotification;

- (void)rampVolumeUp:(NSTimer*)theTimer;
- (void)rampVolumeDown:(NSTimer*)theTimer;

- (void) setStartAtLogin:(BOOL)enabled;
- (bool) willStartAtLogin;

- (void)stopTimer;

- (void)changeVol:(int)vol;

//@property (assign) IBOutlet NSWindow *window;

@end


