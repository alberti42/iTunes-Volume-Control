//
//  AppDelegate.h
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 25.12.12.
//  Copyright (c) 2012 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>
#import <ScreenSaver/ScreenSaver.h>
#import "iTunes.h"
#import "AppleRemote.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    CALayer *mainLayer;
    CALayer *volumeImageLayer;
    CALayer *volumeBar[16];
    
    NSTimeInterval waitOverlayPanel;
    
    NSImage *imgVolOn,*imgVolOff;
    
    CABasicAnimation *fadeOutAnimation;
    CABasicAnimation *fadeInAnimation;
    bool fadeInAnimationReady;
    
    NSUserDefaults *preferences;
    
    NSStatusItem *statusBar;
    
    CFMachPortRef eventTap;
    CFRunLoopSourceRef runLoopSource;
    
    NSImage *statusImageOn;
    NSImage *statusImageOff;
    
    AppleRemote* remote;
    
    NSInteger oldVolumeSetting;
    
    bool _AppleRemoteConnected;
    bool _Tapping;
    bool _UseAppleCMDModifier;
    
@public
    iTunesApplication *iTunes;
    bool previousKeyIsRepeat;
    bool keyIsRepeat;
    NSTimer* timer;
    NSTimer* timerImgSpeaker;
}

@property (assign, nonatomic) IBOutlet NSWindow* window;
@property (assign, nonatomic) IBOutlet NSMenu* statusMenu;

@property (assign, nonatomic) bool AppleRemoteConnected;
@property (assign, nonatomic) bool StartAtLogin;
@property (assign, nonatomic) bool Tapping;
@property (assign, nonatomic) bool UseAppleCMDModifier;

- (void)showSpeakerImg:(NSTimer*)theTimer;
- (void)hideSpeakerImg:(NSTimer*)theTimer;

- (void)refreshVolumeBar:(NSInteger)volume;
- (void) createVolumeBar;
- (void) displayVolumeBar;

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
- (void)muteITunesVolume:(NSNotification *)aNotification;
- (void)nextTrackITunes:(NSNotification *)aNotification;
- (void)previousTrackITunes:(NSNotification *)aNotification;

- (void)rampVolumeUp:(NSTimer*)theTimer;
- (void)rampVolumeDown:(NSTimer*)theTimer;

- (void)stopTimer;

- (void)changeVol:(bool)increase;

- (void)initializePreferences;

@end


