//
//  AppDelegate.h
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 25.12.12.
//  Copyright (c) 2012 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>
#import "iTunes.h"
#import "Spotify.h"
#import "AppleRemote.h"

@class IntroWindowController;
@class StatusBarItem;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    CALayer *mainLayer;
    CALayer *volumeImageLayer;
    CALayer *iconLayer;
    CALayer *volumeBar[16];
    
    NSImage *imgVolOn,*imgVolOff;
    NSImage *iTunesIcon,*spotifyIcon;
    
    NSUserDefaults *preferences;
    
    CABasicAnimation *fadeOutAnimation;
    CABasicAnimation *fadeInAnimation;
    
    CFMachPortRef eventTap;
    CFRunLoopSourceRef runLoopSource;

    AppleRemote* remote;
    
    NSInteger oldVolumeSetting;
    
    NSInteger osxVersion;
    
@public
    iTunesApplication *iTunes;
    SpotifyApplication *spotify;
    id musicProgramPnt;
    
    IntroWindowController *introWindowController;
    NSTimer* timer;
    NSTimer* timerImgSpeaker;
    NSTimeInterval waitOverlayPanel;
    bool fadeInAnimationReady;
}

@property (nonatomic, assign) IBOutlet NSWindow* volumeWindow;
@property (nonatomic, assign) IBOutlet NSMenu* statusMenu;
@property (nonatomic, assign) IBOutlet NSSliderCell* volumeIncrementsSlider;

@property (nonatomic, readonly, strong) NSStatusItem* statusBar;

@property (assign, nonatomic) NSInteger volumeInc;
@property (assign, nonatomic) bool AppleRemoteConnected;
@property (assign, nonatomic) bool StartAtLogin;
@property (assign, nonatomic) bool Tapping;
@property (assign, nonatomic) bool UseAppleCMDModifier;
@property (assign, nonatomic) bool AutomaticUpdates;
@property (assign, nonatomic) bool hideFromStatusBar;
@property (assign, nonatomic) bool loadIntroAtStart;

- (IBAction)increaseVol:(id)sender;


- (IBAction)toggleUseAppleCMDModifier:(id)sender;
- (IBAction)toggleAutomaticUpdates:(id)sender;
- (IBAction)toggleHideFromStatusBar:(id)sender;
- (IBAction)toggleStartAtLogin:(id)sender;
- (IBAction)toggleTapping:(id)sender;
- (IBAction)toggleAppleRemote:(id)sender;
- (IBAction)aboutPanel:(id)sender;
- (IBAction)sliderValueChanged:(NSSliderCell*)slider;
- (IBAction)showIntroWindow:(id)sender;

- (void)appleRemoteButton: (AppleRemoteEventIdentifier)buttonIdentifier pressedDown: (BOOL) pressedDown clickCount: (unsigned int) count;

- (void)resetEventTap;

- (void)stopTimer;

@end

