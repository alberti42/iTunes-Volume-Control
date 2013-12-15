//
//  AppDelegate.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 25.12.12.
//  Copyright (c) 2012 Andrea Alberti. All rights reserved.
//

#import "AppDelegate.h"
#import <IOKit/hidsystem/ev_keymap.h>
#import <Sparkle/SUUpdater.h>
#import "StatusItemView.h"

#define STATUS_BAR_HIDE_DELAY 10

CGEventRef event_tap_callback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    static int previousKeyCode = 0;
    NSEvent * sysEvent;
    
    // No event we care for? return ASAP
    if (type != NX_SYSDEFINED) return event;
    
    sysEvent = [NSEvent eventWithCGEvent:event];
    // No need to test event type, we know it is NSSystemDefined, becuase that is the same as NX_SYSDEFINED
    if ([sysEvent subtype] != 8) return event;
    
    int keyFlags = ([sysEvent data1] & 0x0000FFFF);
    int keyCode = (([sysEvent data1] & 0xFFFF0000) >> 16);
    int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
    CGEventFlags keyModifier = [sysEvent modifierFlags]|0xFFFF;
    AppDelegate* app=(__bridge AppDelegate *)(refcon);
    bool keyIsRepeat = (keyFlags & 0x1);
    bool iTunesRunning=[app->iTunes isRunning];
    
    if(app->timer&&previousKeyCode!=keyCode)
    {
        [app stopTimer];
        
        if(!app->timerImgSpeaker&&!app->fadeInAnimationReady) app->timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:app->waitOverlayPanel target:app selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
    }
    previousKeyCode=keyCode;
    
    // check that whether the Apple CMD modifier has been pressed or not
    if(((keyModifier&NX_COMMANDMASK)==NX_COMMANDMASK)==[app UseAppleCMDModifier])
    {
        switch( keyCode )
        {
            case NX_KEYTYPE_MUTE:
                
                if (iTunesRunning)
                {
                    if( keyState == 1 )
                    {
                        if (!keyIsRepeat)
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"MuteITunesVolume" object:NULL];
                    }
                    else
                    {
                        [app checkEventTap];
                    }
                    return NULL;
                }
                break;
            case NX_KEYTYPE_SOUND_UP:
            case NX_KEYTYPE_SOUND_DOWN:
                if(iTunesRunning)
                {
                    if( keyState == 1 )
                    {
                        if( !app->timer )
                        {
                            if( keyCode == NX_KEYTYPE_SOUND_UP )
                            {
                                [[NSNotificationCenter defaultCenter]
                                 postNotificationName:(keyIsRepeat?@"IncreaseITunesVolumeRamp":@"IncreaseITunesVolume") object:NULL];
                            }
                            else
                            {
                                [[NSNotificationCenter defaultCenter]
                                 postNotificationName:(keyIsRepeat?@"DecreaseITunesVolumeRamp":@"DecreaseITunesVolume") object:NULL];
                            }
                        }
                    }
                    else
                    {
                        [app checkEventTap];
                        
                        if(app->timer)
                        {
                            [app stopTimer];
                            
                            if(!app->timerImgSpeaker&&!app->fadeInAnimationReady) app->timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:app->waitOverlayPanel target:app selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
                        }
                    }
                    return NULL;
                }
                break;
        }
    }
    
    return event;
}

@interface AppDelegate () <NSMenuDelegate>
{
    StatusItemView* _statusBarItemView;
    NSTimer* _statusBarHideTimer;
    NSPopover* _hideFromStatusBarHintPopover;
    NSTextField* _hideFromStatusBarHintLabel;
    NSTimer *_hideFromStatusBarHintPopoverUpdateTimer;
    BOOL _applicationDidBecomeActiveInitially;
}

@property (nonatomic, readwrite, strong) NSStatusItem* statusBar;
@property (nonatomic, readwrite, assign) BOOL menuIsVisible;

@end

@implementation AppDelegate

@synthesize AppleRemoteConnected=_AppleRemoteConnected;
@synthesize StartAtLogin=_StartAtLogin;
@synthesize Tapping=_Tapping;
@synthesize UseAppleCMDModifier=_UseAppleCMDModifier;
@synthesize AutomaticUpdates=_AutomaticUpdates;
@synthesize hideFromStatusBar = _hideFromStatusBar;

@synthesize window=_window;
@synthesize statusMenu=_statusMenu;

static CFTimeInterval fadeInDuration=0.2;
static CFTimeInterval fadeOutDuration=0.7;
static NSTimeInterval volumeRampTimeInterval=0.025;

- (bool) StartAtLogin
{
    NSURL *appURL=[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    bool found=false;
    
    if (loginItems) {
        UInt32 seedValue;
        //Retrieve the list of Login Items and cast them to a NSArray so that it will be easier to iterate.
        NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
        
        for(int i=0; i<[loginItemsArray count]; i++)
        {
            LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray objectAtIndex:i];
            //Resolve the item with URL
            CFURLRef URL = NULL;
            if (LSSharedFileListItemResolve(itemRef, 0, &URL, NULL) == noErr) {
                if ( CFEqual(URL, (__bridge CFTypeRef)(appURL)) ) // found it
                {
                    found=true;
                }
                CFRelease(URL);
            }
            
            if(found)break;
        }
        
        CFRelease((__bridge CFTypeRef)(loginItemsArray));
        CFRelease(loginItems);
    }
    
    return found;
}

- (void)setStartAtLogin:(bool)enabled savePreferences:(bool)savePreferences
{
    NSMenuItem* menuItem=[_statusMenu itemWithTag:4];
    [menuItem setState:enabled];
    
    if(savePreferences)
    {
        NSURL *appURL=[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        
        LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
        
        if (loginItems) {
            if(enabled)
            {
                // Insert the item at the bottom of Login Items list.
                LSSharedFileListItemRef loginItemRef = LSSharedFileListInsertItemURL(loginItems,
                                                                                     kLSSharedFileListItemLast,
                                                                                     NULL,
                                                                                     NULL,
                                                                                     (__bridge CFURLRef)appURL,
                                                                                     NULL,
                                                                                     NULL);
                if (loginItemRef) {
                    CFRelease(loginItemRef);
                }
            }
            else
            {
                UInt32 seedValue;
                //Retrieve the list of Login Items and cast them to a NSArray so that it will be easier to iterate.
                NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
                for(int i=0; i<[loginItemsArray count]; i++)
                {
                    LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray objectAtIndex:i];
                    //Resolve the item with URL
                    CFURLRef URL = NULL;
                    if (LSSharedFileListItemResolve(itemRef, 0, &URL, NULL) == noErr) {
                        if ( CFEqual(URL, (__bridge CFTypeRef)(appURL)) ) // found it
                        {
                            LSSharedFileListItemRemove(loginItems,itemRef);
                        }
                        CFRelease(URL);
                    }
                }
                CFRelease((__bridge CFTypeRef)(loginItemsArray));
            }
            CFRelease(loginItems);
        }
    }
}

- (void)stopTimer
{
    [timer invalidate];
    timer=nil;
}

- (void)rampVolumeUp:(NSTimer*)theTimer
{
    [self changeVol:true];
}

- (void)rampVolumeDown:(NSTimer*)theTimer
{
    [self changeVol:false];
}

- (void)createEventTap
{
    CGEventMask eventMask = (/*(1 << kCGEventKeyDown) | (1 << kCGEventKeyUp) |*/CGEventMaskBit(NX_SYSDEFINED));
    eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault,
                                eventMask, event_tap_callback, (__bridge void *)(self)); // Create an event tap. We are interested in SYS key presses.
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0); // Create a run loop source.
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes); // Add to the current run loop.
}

- (void) appleRemoteInit
{
    remote = [[AppleRemote alloc] init];
    [remote setDelegate:self];
}

- (void)playPauseITunes:(NSNotification *)aNotification
{
    // check if iTunes is running (Q1)
    [iTunes playpause];
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

- (void)muteITunesVolume:(NSNotification *)aNotification
{
    [self displayVolumeBar];
    if(oldVolumeSetting<0)
    {
        oldVolumeSetting=[iTunes soundVolume];
        [iTunes setSoundVolume:0];
        [self refreshVolumeBar:0];
    }
    else
    {
        [iTunes setSoundVolume:oldVolumeSetting];
        [volumeImageLayer setContents:imgVolOn];
        [self refreshVolumeBar:oldVolumeSetting];
        oldVolumeSetting=-1;
    }
}

- (void)increaseITunesVolume:(NSNotification *)aNotification
{
    if( [[aNotification name] isEqualToString:@"IncreaseITunesVolumeRamp"] )
    {
        timer=[NSTimer scheduledTimerWithTimeInterval:volumeRampTimeInterval target:self selector:@selector(rampVolumeUp:) userInfo:nil repeats:YES];
        if(timerImgSpeaker) {[timerImgSpeaker invalidate]; timerImgSpeaker=nil;}
    }
    else
    {
        [self displayVolumeBar];
        [self changeVol:true];
    }
}

- (void)decreaseITunesVolume:(NSNotification *)aNotification
{
    if( [[aNotification name] isEqualToString:@"DecreaseITunesVolumeRamp"] )
    {
        timer=[NSTimer scheduledTimerWithTimeInterval:volumeRampTimeInterval target:self selector:@selector(rampVolumeDown:) userInfo:nil repeats:YES];
        if(timerImgSpeaker) {[timerImgSpeaker invalidate]; timerImgSpeaker=nil;}
    }
    else
    {
        [self displayVolumeBar];
        [self changeVol:false];
    }
}

- (void) appleRemoteButton: (AppleRemoteEventIdentifier)buttonIdentifier pressedDown: (BOOL) pressedDown clickCount: (unsigned int) count {
    if ([iTunes isRunning])
    {
        switch (buttonIdentifier)
        {
            case kRemoteButtonVolume_Plus_Hold:
                if(timer)
                {
                    [self stopTimer];
                    
                    if(!timerImgSpeaker&&!fadeInAnimationReady) timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:waitOverlayPanel target:self selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"IncreaseITunesVolumeRamp" object:NULL];
                }
                break;
            case kRemoteButtonVolume_Plus:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"IncreaseITunesVolume" object:NULL];
                break;
                
            case kRemoteButtonVolume_Minus_Hold:
                if(timer)
                {
                    [self stopTimer];
                    
                    if(!timerImgSpeaker&&!fadeInAnimationReady) timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:waitOverlayPanel target:self selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DecreaseITunesVolumeRamp" object:NULL];
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
    else
    {
        if(buttonIdentifier==k2009RemoteButtonPlay||buttonIdentifier==kRemoteButtonPlay)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayPauseITunes" object:NULL];
        }
    }
}

- (id)init
{
    self = [super init];
    if(self)
    {
        oldVolumeSetting=-1;
        
        fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [fadeOutAnimation setDuration:fadeOutDuration];
        [fadeOutAnimation setRemovedOnCompletion:NO];
        [fadeOutAnimation setFillMode:kCAFillModeForwards];
        [fadeOutAnimation setFromValue:[NSNumber numberWithFloat:1.0f]];
        [fadeOutAnimation setToValue:[NSNumber numberWithFloat:0.0f]];
        // [fadeOutAnimation setDelegate:self];
        
        fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [fadeInAnimation setDuration:fadeInDuration];
        [fadeInAnimation setRemovedOnCompletion:NO];
        [fadeInAnimation setFillMode:kCAFillModeForwards];
        [fadeInAnimation setFromValue:[NSNumber numberWithFloat:0.0f]];
        [fadeInAnimation setToValue:[NSNumber numberWithFloat:1.0f]];
        // [fadeInAnimation setDelegate:self];
        fadeInAnimationReady=true;
        
    }
    return self;
}

-(void)awakeFromNib
{
    [[_window contentView] setWantsLayer:YES];
    [_window setFrame:[_window frame]/*[[NSScreen mainScreen] frame]*/ display:NO animate:NO];
    
    mainLayer = [[_window contentView] layer];
    CGColorRef backgroundColor=CGColorCreateGenericRGB(0.f, 0.f, 0.f, 0.16f);
    [mainLayer setBackgroundColor:backgroundColor];
    CFRelease(backgroundColor);
    [mainLayer setCornerRadius:22];
    [mainLayer setOpacity:0.0f];
    
    imgVolOn=[NSImage imageNamed:@"volume"];
    imgVolOff=[NSImage imageNamed:@"volume-off"];
    NSRect rect = NSZeroRect;
    rect.size = [imgVolOff size];
    
    volumeImageLayer = [CALayer layer];
    [volumeImageLayer setFrame:NSRectToCGRect(rect)];
    [volumeImageLayer setPosition:CGPointMake([[_window contentView] frame].size.width/2, [[_window contentView]frame].size.height/2+12)];
    [volumeImageLayer setContents:imgVolOn];
    
    [mainLayer addSublayer:volumeImageLayer];
    
    [self createVolumeBar];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];

    [[SUUpdater sharedUpdater] setFeedURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControlCast.xml.php?version=%@",version]]];
    
    [[SUUpdater sharedUpdater] setUpdateCheckInterval:60*60*24*7]; // look for new updates every 7 days
        
    [_window orderOut:self];
    [_window setLevel:NSFloatingWindowLevel];
    
    statusImageOn = [NSImage imageNamed:@"statusbar-item-on"];
    statusImageOff = [NSImage imageNamed:@"statusbar-item-off"];
    
    [self showInStatusBar];
    
    iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseITunesVolume:) name:@"IncreaseITunesVolume" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseITunesVolume:) name:@"IncreaseITunesVolumeRamp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decreaseITunesVolume:) name:@"DecreaseITunesVolume" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decreaseITunesVolume:) name:@"DecreaseITunesVolumeRamp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(muteITunesVolume:) name:@"MuteITunesVolume" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playPauseITunes:) name:@"PlayPauseITunes" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextTrackITunes:) name:@"NextTrackITunes" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(previousTrackITunes:) name:@"PreviousTrackITunes" object:nil];
    
    [self createEventTap];
    
    [self appleRemoteInit];
    
    [self initializePreferences];
    
    [self setStartAtLogin:[self StartAtLogin] savePreferences:false];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    [self setHideFromStatusBar:[self hideFromStatusBar]];
    [self showInStatusBar];
    
    return true;
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [_hideFromStatusBarHintPopover close];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (! _applicationDidBecomeActiveInitially)
    {
        _applicationDidBecomeActiveInitially = YES;
        return;
    }
    
    if ([self hideFromStatusBar])
        [self showHideFromStatusBarHintPopover];
}

- (void)showInStatusBar
{
    // the status bar item needs a custom view so that we can show a NSPopover for the hide-from-status-bar hint
    // the view now reacts to the mouseDown event to show the menu
    CGFloat thickness = [[NSStatusBar systemStatusBar] thickness];
    _statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:thickness];
    _statusBarItemView = [[StatusItemView alloc] initWithFrame:(NSRect){.size={thickness, thickness}}];
    [_statusBarItemView setImage:statusImageOn];
    [_statusBar setView:_statusBarItemView];
    [_statusBar setMenu:_statusMenu];
    [_statusMenu setDelegate:self];
    [_statusBar setHighlightMode:YES];
}

- (void)initializePreferences
{
    preferences = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithBool:true] , @"TappingEnabled",
                          [NSNumber numberWithBool:false], @"AppleRemoteConnected",
                          [NSNumber numberWithBool:false], @"UseAppleCMDModifier",
                          [NSNumber numberWithBool:true],  @"AutomaticUpdates",
                          [NSNumber numberWithBool:false], @"hideFromStatusBarPreference",
                          nil ]; // terminate the list
    [preferences registerDefaults:dict];
    
    [self setAppleRemoteConnected:[preferences boolForKey: @"AppleRemoteConnected"]];
    [self setTapping:[preferences boolForKey:              @"TappingEnabled"]];
    [self setUseAppleCMDModifier:[preferences boolForKey:  @"UseAppleCMDModifier"]];
    [self setAutomaticUpdates:[preferences boolForKey:     @"AutomaticUpdates"]];
    [self setHideFromStatusBar:[preferences boolForKey:    @"hideFromStatusBarPreference"]];
}

- (IBAction)toggleAutomaticUpdates:(id)sender
{
    [self setAutomaticUpdates:![self AutomaticUpdates]];
}

- (void) setAutomaticUpdates:(bool)enabled
{
    NSMenuItem* menuItem=[_statusMenu itemWithTag:6];
    [menuItem setState:enabled];
    
    [preferences setBool:enabled forKey:@"AutomaticUpdates"];
    [preferences synchronize];
    
    _AutomaticUpdates=enabled;
    
    [[SUUpdater sharedUpdater] setAutomaticallyChecksForUpdates:enabled];
}

- (IBAction)toggleStartAtLogin:(id)sender
{
    [self setStartAtLogin:![self StartAtLogin] savePreferences:true];
}

- (void)setAppleRemoteConnected:(bool)enabled
{
    NSMenuItem* menuItem=[_statusMenu itemWithTag:2];
    [menuItem setState:enabled];
    
    if(enabled && _Tapping)
    {
        [remote startListening:self];
        waitOverlayPanel=1.0;
    }
    else
    {
        [remote stopListening:self];
        waitOverlayPanel=1.2;
    }
    
    [preferences setBool:enabled forKey:@"AppleRemoteConnected"];
    [preferences synchronize];
    
    _AppleRemoteConnected=enabled;
}

- (IBAction)toggleAppleRemote:(id)sender
{
    [self setAppleRemoteConnected:![self AppleRemoteConnected]];
}

- (void) setUseAppleCMDModifier:(bool)enabled
{
    NSMenuItem* menuItem=[_statusMenu itemWithTag:3];
    [menuItem setState:enabled];
    
    [preferences setBool:enabled forKey:@"UseAppleCMDModifier"];
    [preferences synchronize];
    
    _UseAppleCMDModifier=enabled;
}

- (IBAction)toggleUseAppleCMDModifier:(id)sender
{
    [self setUseAppleCMDModifier:![self UseAppleCMDModifier]];
}

- (void) setTapping:(bool)enabled
{
    NSMenuItem* menuItem=[_statusMenu itemWithTag:1];
    [menuItem setState:enabled];
    
    CGEventTapEnable(eventTap, enabled);
    
    if(enabled)
    {
        _statusBarItemView.image = statusImageOn;
        if([self AppleRemoteConnected]) [remote startListening:self];
    }
    else
    {
        _statusBarItemView.image = statusImageOff;
        [remote stopListening:self];
    }
    
    [preferences setBool:enabled forKey:@"TappingEnabled"];
    [preferences synchronize];
    
    _Tapping=enabled;
}

- (IBAction)toggleTapping:(id)sender
{
    [self setTapping:![self Tapping]];
}

- (IBAction)aboutPanel:(id)sender
{    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleVersion"];
    NSRange range=[version rangeOfString:@"." options:NSBackwardsSearch];
    if(version>0) version=[version substringFromIndex:range.location+1];
    
    infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                version,@"Version",
                nil ]; // terminate the list
    
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:infoDict];
}

- (void) dealloc
{
    if(CFMachPortIsValid(eventTap)) {
        CFMachPortInvalidate(eventTap);
        CFRunLoopSourceInvalidate(runLoopSource);
        CFRelease(eventTap);
        CFRelease(runLoopSource);
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [remote stopListening:self];
    remote=nil;
    
    imgVolOn=nil;
    imgVolOff=nil;
    
    volumeImageLayer=nil;
    for(int i=0; i<16; i++)
    {
        volumeBar[i]=nil;
    }
    
    imgVolOn=nil;
    imgVolOff=nil;
    
    statusImageOn=nil;
    statusImageOff=nil;
    
    fadeOutAnimation=nil;
    fadeInAnimation=nil;
    
    _statusBar = nil;    
}

- (void) showSpeakerImg:(NSTimer*)theTimer
{
    // [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [_window orderFront:self];
    
    fadeInAnimationReady=false;
    [mainLayer addAnimation:fadeInAnimation forKey:@"increaseOpacity"];
}

- (void) hideSpeakerImg:(NSTimer*)theTimer
{
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            [_window orderOut:self];
            fadeInAnimationReady=true;
        }];
        [mainLayer addAnimation:fadeOutAnimation forKey:@"decreaseOpacity"];
    } [CATransaction commit];
}

- (bool)checkEventTap
{
    bool ret=true;
    
    if(CGEventTapIsEnabled(eventTap)!=_Tapping)
    {
        [self stopTimer];
        [self hideSpeakerImg:nil];
        [self setTapping:_Tapping];
        
        ret=false;
    }
    
    return ret;
}

- (void)changeVol:(bool)increase
{
    if([self checkEventTap])
    {
        NSInteger volume;
        if(oldVolumeSetting<0)
        {
            volume=[iTunes soundVolume]+(increase?3:-3);
        }
        else
        {
            [volumeImageLayer setContents:imgVolOn];
            volume=oldVolumeSetting;
            oldVolumeSetting=-1;
        }
        if (volume<0) volume=0;
        if (volume>100) volume=100;
        
        [iTunes setSoundVolume:volume];
        
        [self refreshVolumeBar:(int)volume];
    }
}

- (void) createVolumeBar
{
    
    CALayer* background;
    int i;
    for(i=0; i<16; i++)
    {
        background = [CALayer layer];
        [background setFrame:CGRectMake(9*i+32, 29.0, 7.0, 9.0)];
        [background setBackgroundColor:CGColorCreateGenericRGB(0.f, 0.f, 0.f, 0.5f)];
        
        [mainLayer addSublayer:background];
    }
    
    for(i=0; i<16; i++)
    {
        volumeBar[i] = [CALayer layer];
        [volumeBar[i] setFrame:CGRectMake(9*i+32, 29.0, 7.0, 9.0)];
        [volumeBar[i] setBackgroundColor:CGColorCreateGenericRGB(1.0f, 1.0f, 1.0f, 1.0f)];
        
        [volumeBar[i] setShadowOffset:CGSizeMake(-1, -1)];
        [volumeBar[i] setShadowRadius:1.0];
        [volumeBar[i] setShadowColor:CGColorCreateGenericRGB(0.f, 0.f, 0.f, 1.0f)];
        [volumeBar[i] setShadowOpacity:0.5];
        
        [volumeBar[i] setHidden:YES];
        
        [mainLayer addSublayer:volumeBar[i]];
    }
}

- (void) refreshVolumeBar:(NSInteger)volume
{
    NSInteger i;
    NSInteger doubleFullRectangles=(NSInteger)round(16.0f*volume/50.0f);
    NSInteger fullRectangles=doubleFullRectangles>>1;
    [CATransaction begin];
    [CATransaction setAnimationDuration: 0.0];
    [CATransaction setDisableActions: TRUE];
    
    if(volume==0) [volumeImageLayer setContents:imgVolOff];
    if(volume==3) [volumeImageLayer setContents:imgVolOn];
    
    for(i=0; i<fullRectangles; i++)
    {
        [volumeBar[i] setHidden:NO];
    }
    for(NSInteger i=fullRectangles; i<16; i++)
    {
        [volumeBar[i] setHidden:YES];
    }
    
    CGRect frame;
    
    if(fullRectangles!=0)
    {
        frame = [volumeBar[fullRectangles-1] frame];
        frame.size.width=7;
        [volumeBar[fullRectangles-1] setFrame:frame];
    }
    
    if(fullRectangles!=16&&doubleFullRectangles%2)
    {
        frame = [volumeBar[fullRectangles] frame];
        frame.size.width=4;
        
        [volumeBar[fullRectangles] setFrame:frame];
        [volumeBar[fullRectangles] setHidden:NO];
    }
    
    [CATransaction commit];
}

- (void) displayVolumeBar
{
    if(fadeInAnimationReady) [self showSpeakerImg:nil];
    if(timerImgSpeaker) {[timerImgSpeaker invalidate]; timerImgSpeaker=nil;}
    timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:waitOverlayPanel target:self selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
}

#pragma mark - Hide From Status Bar

- (IBAction)toggleHideFromStatusBar:(id)sender
{
    
    [self setHideFromStatusBar:![self hideFromStatusBar]];
    if (self.hideFromStatusBar)
        [self showHideFromStatusBarHintPopover];
}

- (void)setHideFromStatusBar:(bool)enabled
{
    _hideFromStatusBar=enabled;
    
    NSMenuItem* menuItem=[_statusMenu itemWithTag:5];
    [menuItem setState:[self hideFromStatusBar]];
    
    [preferences setBool:enabled forKey:@"hideFromStatusBarPreference"];
    [preferences synchronize];
    
    if (enabled)
    {
        if (![_statusBarHideTimer isValid] && [self statusBar])
        {
            _statusBarHideTimer = [NSTimer scheduledTimerWithTimeInterval:
                                   (NSTimeInterval)STATUS_BAR_HIDE_DELAY target:self selector:@selector(doHideFromStatusBar:) userInfo:nil repeats:NO];

            _hideFromStatusBarHintPopoverUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateHideFromStatusBarHintPopover:) userInfo:nil repeats:YES];
        }
    }
    else
    {
        [_hideFromStatusBarHintPopover close];
        [_statusBarHideTimer invalidate];
        [_hideFromStatusBarHintPopoverUpdateTimer invalidate];
        if (![self statusBar])
            [self showInStatusBar];
    }
}

- (void)doHideFromStatusBar:(NSTimer*)aTimer
{
    [aTimer invalidate];
    [_hideFromStatusBarHintPopoverUpdateTimer invalidate];
    [_hideFromStatusBarHintPopover close];
    [[NSStatusBar systemStatusBar] removeStatusItem:[self statusBar]];
    [self setStatusBar:nil];
}

- (void)showHideFromStatusBarHintPopover
{
    if ([_hideFromStatusBarHintPopover isShown]) return;
    
    if (! _hideFromStatusBarHintPopover)
    {
        CGRect popoverRect = (CGRect) {
            .size.width = 225,
            .size.height = 75
        };
        
        _hideFromStatusBarHintLabel = [[NSTextField alloc] initWithFrame:CGRectInset(popoverRect, 10, 10)];
        [_hideFromStatusBarHintLabel setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        [_hideFromStatusBarHintLabel setEditable:false];
        [_hideFromStatusBarHintLabel setSelectable:false];
        [_hideFromStatusBarHintLabel setBezeled:false];
        [_hideFromStatusBarHintLabel setBackgroundColor:[NSColor clearColor]];
        [_hideFromStatusBarHintLabel setAlignment:NSCenterTextAlignment];
        
        NSView* hintView = [[NSView alloc] initWithFrame:popoverRect];
        [hintView addSubview:_hideFromStatusBarHintLabel];
        
        NSViewController* hintVC = [[NSViewController alloc] init];
        [hintVC setView:hintView];
        
        _hideFromStatusBarHintPopover = [[NSPopover alloc] init];
        [_hideFromStatusBarHintPopover setContentViewController:hintVC];
    }
    
    [self setHideFromStatusBarHintLabelWithSeconds:STATUS_BAR_HIDE_DELAY];
    [_hideFromStatusBarHintPopover showRelativeToRect:[_statusBarItemView frame] ofView:_statusBarItemView preferredEdge:NSMinYEdge];
}

- (void)updateHideFromStatusBarHintPopover:(NSTimer*)aTimer
{
    NSDate* now = [NSDate date];
    [self setHideFromStatusBarHintLabelWithSeconds:[[_statusBarHideTimer fireDate] timeIntervalSinceDate:now]];
}

- (void)setHideFromStatusBarHintLabelWithSeconds:(NSUInteger)seconds
{
    [_hideFromStatusBarHintLabel setStringValue:
    [NSString stringWithFormat:@"%@ will hide after %ld seconds.\n\nLaunch it again to re-show the icon.",
     @"iTunes Volume Control", (unsigned long)seconds]];
}

#pragma mark - NSMenuDelegate

- (void)menuWillOpen:(NSMenu *)menu
{
    [self setMenuIsVisible:true];
    [_hideFromStatusBarHintPopover close];
}

- (void)menuDidClose:(NSMenu *)menu
{
    [self setMenuIsVisible:false];
    if ([self hideFromStatusBar])
        [self showHideFromStatusBarHintPopover];
}

@end
