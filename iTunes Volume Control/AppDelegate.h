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
    IBOutlet NSMenu *statusMenu;
    NSUserDefaults *preferences;
    
    NSStatusItem *statusItem;
    iTunesApplication *iTunes;
    
    CFMachPortRef eventTap;
    CFRunLoopSourceRef runLoopSource;
    
    NSImage *statusImageOn;
    NSImage *statusImageOff;
    
    AppleRemote* remote;
    
    bool _AppleRemoteConnected;
    bool _Tapping;
    bool _UseAppleCMDModifier;
    
@public
    bool previousKeyIsRepeat;
    bool keyIsRepeat;
    NSTimer* timer;
}

@property (readwrite, nonatomic) bool AppleRemoteConnected;
@property (readwrite, nonatomic) bool StartAtLogin;
@property (readwrite, nonatomic) bool Tapping;
@property (readwrite, nonatomic) bool UseAppleCMDModifier;

- (IBAction)toggleUseAppleCMDModifier:(id)sender;
- (void) setUseAppleCMDModifier:(bool)enabled;

- (IBAction)toggleStartAtLogin:(id)sender;
- (bool) StartAtLogin;
- (void) setStartAtLogin:(bool)enabled savePreferences:(bool)savePreferences;

- (IBAction)toggleTapping:(id)sender;
- (void) setTapping:(bool)enabled;

- (IBAction)toggleAppleRemote:(id)sender;
- (void)setAppleRemoteConnected:(bool)enabled;

- (IBAction)aboutPanel:(id)sender;

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

- (void)stopTimer;

- (void)changeVol:(int)vol;

- (void)initializePreferences;

//@property (assign) IBOutlet NSWindow *window;

@end


