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
//#import "IntroWindowController.h"
//#import "MyNSVisualEffectView.h"

//#import "BezelServices.h"
#import "OSD.h"

#include <dlfcn.h>

#pragma mark - Signal handling

/**
 This will handle signals for us, specifically SIGTERM.
 */
void handleSIGTERM(int sig) {
    [NSApp terminate:nil];
}

#pragma mark - Tapping key stroke events

static void displayPreferencesChanged(CGDirectDisplayID displayID, CGDisplayChangeSummaryFlags flags, void *userInfo) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"displayResolutionHasChanged" object:NULL];
}

CGEventRef event_tap_callback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    static int previousKeyCode = 0;
    static bool muteDown = false;
    NSEvent * sysEvent;
    
    if (type == kCGEventTapDisabledByTimeout) {
//        NSAlert *alert = [NSAlert alertWithMessageText:@"iTunes Volume Control" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Event Taps Disabled! Re-enabling."];
//        [alert runModal];
//
//        NSLog(@"Event Taps Disabled! Re-enabling");
        [(__bridge AppDelegate *)(refcon) resetEventTap];
        return event;
    }
    
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
    //bool musicProgramRunning=[app->musicProgramPnt isRunning];
    
    // check that whether the Apple CMD modifier has been pressed or not
    if(((keyModifier&NX_COMMANDMASK)==NX_COMMANDMASK)==[app UseAppleCMDModifier])
    {
        switch( keyCode )
        {
            case NX_KEYTYPE_MUTE:
                
                    if(previousKeyCode!=keyCode && app->timer)
                    {
                        [app stopTimer];
                        //                        if(!app->timerImgSpeaker&&!app->fadeInAnimationReady){
                        //                            app->timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:app->waitOverlayPanel target:app selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
                        //                            [[NSRunLoop mainRunLoop] addTimer:app->timerImgSpeaker forMode:NSRunLoopCommonModes];
                        //                        }
                    }
                    previousKeyCode=keyCode;
                    
                    if( keyState == 1 )
                    {
                        muteDown = true;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"MuteITunesVolume" object:NULL];
                    }
                    else
                    {
                        muteDown = false;
                    }
                    return NULL;
                break;
            case NX_KEYTYPE_SOUND_UP:
            case NX_KEYTYPE_SOUND_DOWN:
                if(!muteDown)
                {
                    if(previousKeyCode!=keyCode && app->timer)
                    {
                        [app stopTimer];
                        //                        if(!app->timerImgSpeaker&&!app->fadeInAnimationReady){
                        //                            app->timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:app->waitOverlayPanel target:app selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
                        //                            [[NSRunLoop mainRunLoop] addTimer:app->timerImgSpeaker forMode:NSRunLoopCommonModes];
                        //                        }
                    }
                    previousKeyCode=keyCode;
                    
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
                        if(app->timer)
                        {
                            [app stopTimer];
                            
                            //                            if(!app->timerImgSpeaker&&!app->fadeInAnimationReady){
                            //                                app->timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:app->waitOverlayPanel target:app selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
                            //                                [[NSRunLoop mainRunLoop] addTimer:app->timerImgSpeaker forMode:NSRunLoopCommonModes];
                            //                            }
                        }
                    }
                    return NULL;
                }
                break;
        }
    }
    
    return event;
}

#pragma mark - Class extension for status menu

@interface AppDelegate () <NSMenuDelegate>
{
    StatusItemView* _statusBarItemView;
    NSTimer* _statusBarHideTimer;
    NSPopover* _hideFromStatusBarHintPopover;
    NSTextField* _hideFromStatusBarHintLabel;
    NSTimer *_hideFromStatusBarHintPopoverUpdateTimer;
    
    NSView* _hintView;
    NSViewController* _hintVC;
}

@end

#pragma mark - Extention music applications

@implementation PlayerApplication

@synthesize currentVolume = _currentVolume;

- (void) setCurrentVolume:(double)currentVolume
{
    [self setDoubleVolume:currentVolume];
    
    [musicPlayer setSoundVolume:round(currentVolume)];
}

- (double) currentVolume
{
    double vol = [musicPlayer soundVolume];
    
    if (fabs(vol-[self doubleVolume])<1)
    {
        vol = [self doubleVolume];
    }
    
    return vol;
}

- (BOOL) isPlaying
{
    
//    [iTunesApplication class];
//    [musicPlayer isKindOfClass:[iTunesApplication class]];
    
    return [musicPlayer isRunning];
}

- (BOOL) isRunning
{
    return [musicPlayer isRunning];
}

- (iTunesEPlS) playerState
{
    return [musicPlayer playerState];
}

-(id)initWithBundleIdentifier:(NSString*) bundleIdentifier {
    if (self = [super init])  {
        [self setCurrentVolume: -100];
        [self setOldVolume: -1];
        musicPlayer = [SBApplication applicationWithBundleIdentifier:bundleIdentifier];
        
    }
    return self;
}

@end

#pragma mark - Class extension for NSString

@implementation NSString (NSString_Extended)

- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    unsigned long int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end

/*
 
#pragma mark - Extending NSView

#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_10


@implementation NSView (HS)

-(instancetype)insertVibrancyViewBlendingMode:(NSVisualEffectBlendingMode)mode
{
    Class vibrantClass=NSClassFromString(@"NSVisualEffectView");
    if (vibrantClass)
    {
        NSVisualEffectView *vibrant=[[vibrantClass alloc] initWithFrame:self.bounds];
        
        [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [vibrant setBlendingMode:mode];
        
        [vibrant setMaterial:NSVisualEffectMaterialLight];
        [vibrant setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
        [vibrant setState:NSVisualEffectStateActive];

        
        [self addSubview:vibrant positioned:NSWindowBelow relativeTo:nil];
        
        return vibrant;
    }
    
    return nil;
}

@end

#endif

*/

#pragma mark - Implementation AppDelegate

@implementation AppDelegate

@synthesize AppleRemoteConnected=_AppleRemoteConnected;
@synthesize StartAtLogin=_StartAtLogin;
@synthesize Tapping=_Tapping;
@synthesize UseAppleCMDModifier=_UseAppleCMDModifier;
@synthesize AutomaticUpdates=_AutomaticUpdates;
@synthesize hideFromStatusBar = _hideFromStatusBar;
@synthesize hideVolumeWindow = _hideVolumeWindow;
@synthesize loadIntroAtStart = _loadIntroAtStart;
@synthesize statusBar = _statusBar;

@synthesize iTunesBtn = _iTunesBtn;
@synthesize spotifyBtn = _spotifyBtn;
@synthesize systemBtn = _systemBtn;

@synthesize iTunesPerc = _iTunesPerc;
@synthesize spotifyPerc = _spotifyPerc;
@synthesize systemPerc = _systemPerc;

@synthesize volumeWindow=_volumeWindow;
@synthesize statusMenu=_statusMenu;

//static CFTimeInterval fadeInDuration=0.2;
//static CFTimeInterval fadeOutDuration=0.7;
static NSTimeInterval volumeRampTimeInterval=0.01;
static NSTimeInterval statusBarHideDelay=10;

/*
// El Capitan and probably older systems
void *(*_BSDoGraphicWithMeterAndTimeout)(CGDirectDisplayID arg0, BSGraphic arg1, int arg2, float v, int timeout) = NULL;

- (BOOL)_loadBezelServices
{
    // Load BezelServices framework
    void *handle = dlopen("/System/Library/PrivateFrameworks/BezelServices.framework/Versions/A/BezelServices", RTLD_GLOBAL);
    if (!handle) {
        NSLog(@"Error opening framework");
        return NO;
    }
    else {
        _BSDoGraphicWithMeterAndTimeout = dlsym(handle, "BSDoGraphicWithMeterAndTimeout");
        return _BSDoGraphicWithMeterAndTimeout != NULL;
    }
}
*/

- (BOOL)_loadOSDFramework
{
    return [[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/OSD.framework"] load];
}

- (BOOL)checkSIPforAppIdentifier:(NSString*)identifier {
    
    // First available from 10.14 Mojave
    if (@available(macOS 10.14, *)) {
        
        OSStatus status;
        NSAppleEventDescriptor *targetAppEventDescriptor;
        
        targetAppEventDescriptor = [NSAppleEventDescriptor descriptorWithBundleIdentifier:identifier];
        
        status = AEDeterminePermissionToAutomateTarget(targetAppEventDescriptor.aeDesc, typeWildCard, typeWildCard, true);
        
        switch (status) {
            case -600: //procNotFound
                NSLog(@"Not running app with id '%@'",identifier);
                break;
                
            case 0: // noErr
                NSLog(@"SIP check successfull for app with id '%@'",identifier);
                break;
                
            case -1744: // errAEEventWouldRequireUserConsent
                // This only appears if you send false for askUserIfNeeded
                NSLog(@"User consent required for app with id '%@'",identifier);
                break;
                
            case -1743: //errAEEventNotPermitted
                NSLog(@"User didn't allow usage for app with id '%@'",identifier);
                
                // Here you should present a dialog with a tutorial on how to activate it manually
                // This can be something like
                // Go to system preferences > security > privacy
                // Choose automation and active [APPNAME] for [APPNAME]
                
                return NO;
                
            default:
                break;
        }
    }
    return YES;
}

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
            CFURLRef url = NULL;
            
            // LSSharedFileListItemResolve is deprecated in Mac OS X 10.10
            // Switch to LSSharedFileListItemCopyResolvedURL if possible
#if MAC_OS_X_VERSION_MIN_REQUIRED < 101000 // MAC_OS_X_VERSION_10_10
            LSSharedFileListItemResolve(itemRef, 0, &url, NULL);
#else
            url = LSSharedFileListItemCopyResolvedURL(itemRef, 0, NULL);
#endif
            
            if ( url ) {
                if ( CFEqual(url, (__bridge CFTypeRef)(appURL)) ) // found it
                {
                    found=true;
                }
                CFRelease(url);
            }
            
            if(found)break;
        }
        
        CFRelease((__bridge CFTypeRef)(loginItemsArray));
        CFRelease(loginItems);
    }
    
    return found;
}

- (void)introWindowWillClose:(NSNotification *)aNotification{
    introWindowController = nil;
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
                    
                    // LSSharedFileListItemResolve is deprecated in Mac OS X 10.10
                    // Switch to LSSharedFileListItemCopyResolvedURL if possible
#if MAC_OS_X_VERSION_MIN_REQUIRED < 101000 // MAC_OS_X_VERSION_10_10
                    LSSharedFileListItemResolve(itemRef, 0, &URL, NULL);
#else
                    URL = LSSharedFileListItemCopyResolvedURL(itemRef, 0, NULL);
#endif

                    if ( URL ) {
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

- (bool)createEventTap
{
    CGEventMask eventMask = (/*(1 << kCGEventKeyDown) | (1 << kCGEventKeyUp) |*/CGEventMaskBit(NX_SYSDEFINED));
    eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault,
                                eventMask, event_tap_callback, (__bridge void *)self); // Create an event tap. We are interested in SYS key presses.
    
    if(eventTap != nil)
    {
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0); // Create a run loop source.
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes); // Add to the current run loop.
        return true;
    }
    else
        return false;
}

- (void) appleRemoteInit
{
    remote = [[AppleRemote alloc] init];
    [remote setDelegate:self];
}

- (void)playPauseITunes:(NSNotification *)aNotification
{
    // check if iTunes is running (Q1)
    [musicProgramPnt playpause];
}

- (void)nextTrackITunes:(NSNotification *)aNotification
{
    if ([musicProgramPnt isRunning])
    {
        [musicProgramPnt nextTrack];
    }
}

- (void)previousTrackITunes:(NSNotification *)aNotification
{
    if ([musicProgramPnt isRunning])
    {
        [musicProgramPnt previousTrack];
    }
}

- (void)muteITunesVolume:(NSNotification *)aNotification
{
    // [self displayVolumeBar];
    
    id musicPlayerPnt = [self runningPlayer];
    
    if (musicPlayerPnt != nil)
    {
        if([musicPlayerPnt oldVolume]<0)
        {
            [musicPlayerPnt setOldVolume:[musicPlayerPnt currentVolume]];
            [musicPlayerPnt setCurrentVolume:0];
            
            if(!_hideVolumeWindow)
                [[NSClassFromString(@"OSDManager") sharedManager] showImage:OSDGraphicSpeakerMute onDisplayID:CGSMainDisplayID() priority:OSDPriorityDefault msecUntilFade:1000 filledChiclets:0 totalChiclets:(unsigned int)100 locked:NO];
            
            //[self refreshVolumeBar:0];
        }
        else
        {
            [musicPlayerPnt setCurrentVolume:[musicPlayerPnt oldVolume]];
            [volumeImageLayer setContents:imgVolOn];
            
            if(!_hideVolumeWindow)
                [[NSClassFromString(@"OSDManager") sharedManager] showImage:OSDGraphicSpeaker onDisplayID:CGSMainDisplayID() priority:OSDPriorityDefault msecUntilFade:1000 filledChiclets:(unsigned int)[musicPlayerPnt oldVolume] totalChiclets:(unsigned int)100 locked:NO];
            
            //[self refreshVolumeBar:oldVolumeSetting];
            [musicPlayerPnt setOldVolume:-1];
        }
        
        if([_statusBarItemView menuIsVisible])
        {
            if( musicPlayerPnt == iTunes)
                [self setItunesVolume:[musicPlayerPnt currentVolume]];
            else if( musicPlayerPnt == spotify)
                [self setSpotifyVolume:[musicPlayerPnt currentVolume]];
            else if( musicPlayerPnt == systemAudio)
                [self setSystemVolume:[musicPlayerPnt currentVolume]];
        }
    }
}

- (void)increaseITunesVolume:(NSNotification *)aNotification
{
//    [self displayVolumeBar];

    if( [[aNotification name] isEqualToString:@"IncreaseITunesVolumeRamp"] )
    {
        timer=[NSTimer scheduledTimerWithTimeInterval:volumeRampTimeInterval*(NSTimeInterval)increment target:self selector:@selector(rampVolumeUp:) userInfo:nil repeats:YES];
    
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

        // if(timerImgSpeaker) {[timerImgSpeaker invalidate]; timerImgSpeaker=nil;}
    }
    else
    {
        [self changeVol:true];
    }
}

- (void)decreaseITunesVolume:(NSNotification *)aNotification
{
    // [self displayVolumeBar];

    if( [[aNotification name] isEqualToString:@"DecreaseITunesVolumeRamp"] )
    {
        timer=[NSTimer scheduledTimerWithTimeInterval:volumeRampTimeInterval*(NSTimeInterval)increment target:self selector:@selector(rampVolumeDown:) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        // if(timerImgSpeaker) {[timerImgSpeaker invalidate]; timerImgSpeaker=nil;}
    }
    else
    {
        [self changeVol:false];
    }
}

- (void) appleRemoteButton: (AppleRemoteEventIdentifier)buttonIdentifier pressedDown: (BOOL) pressedDown clickCount: (unsigned int) count {
    if ([musicProgramPnt isRunning])
    {
        switch (buttonIdentifier)
        {
            case kRemoteButtonVolume_Plus_Hold:
                if(timer)
                {
                    [self stopTimer];
                    
                    //                    if(!timerImgSpeaker&&!fadeInAnimationReady) {
                    //                        timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:waitOverlayPanel target:self selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
                    //                        [[NSRunLoop mainRunLoop] addTimer:timerImgSpeaker forMode:NSRunLoopCommonModes];
                    //                    }
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
                    
                    //                    if(!timerImgSpeaker&&!fadeInAnimationReady){
                    //                        timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:waitOverlayPanel target:self selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
                    //                        [[NSRunLoop mainRunLoop] addTimer:timerImgSpeaker forMode:NSRunLoopCommonModes];
                    //                    }
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
        /*
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
        */
        
        if (floor(NSAppKitVersionNumber) <= 1038) { // NSAppKitVersionNumber10_6
            //10.6.x or earlier systems
            osxVersion = 106;
        } else if (floor(NSAppKitVersionNumber) <= 1138) { // NSAppKitVersionNumber10_7
            /* On a 10.7 - 10.7.x system */
            osxVersion = 107;
        } else if (floor(NSAppKitVersionNumber) <= 1187) { // NSAppKitVersionNumber10_8
            /* On a 10.8 - 10.8.x system */
            osxVersion = 108;
        } else if (floor(NSAppKitVersionNumber) <= 1265) { // NSAppKitVersionNumber10_9
            /* On a 10.9 - 10.9.x system */
            osxVersion = 109;
        } else {
            /* On a 10.10 - 10.10.x system */
            osxVersion = 110;
        }
        
    }
    return self;
}

-(void)awakeFromNib
{

    
}

-(void)awakeFromNib_disabled
{
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    [_volumeWindow setFrame:(osxVersion<110?  CGRectMake(round((screenFrame.size.width-210)/2),139,210,206) : CGRectMake(round((screenFrame.size.width-200)/2),140,200,200)) display:NO animate:NO];
    
    // NSVisualEffectView* view = [[_volumeWindow contentView] insertVibrancyViewBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    
    NSView* volumeView = [_volumeWindow contentView];
    
    [volumeView setWantsLayer:YES];
    
    mainLayer = [volumeView layer];
    CGColorRef backgroundColor=CGColorCreateGenericGray(0.00f, 0.30f);
    [mainLayer setBackgroundColor:backgroundColor];
    CFRelease(backgroundColor);
    
    [mainLayer setCornerRadius:16];
    [mainLayer setShouldRasterize:false];
    [mainLayer setEdgeAntialiasingMask: kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge];
    
    [mainLayer setOpacity:0.0f];
    
    imgVolOn=[NSImage imageNamed:@"volume"];
    imgVolOff=[NSImage imageNamed:@"volume-off"];
    
    NSRect rect = NSZeroRect;
    rect.size = [imgVolOff size];

    NSRect rectIcon = NSZeroRect;
    rectIcon.size = [iTunesIcon size];
    
    volumeImageLayer = [CALayer layer];
    [volumeImageLayer setFrame:NSRectToCGRect(rect)];
    [volumeImageLayer setPosition:CGPointMake([volumeView frame].size.width/2, [volumeView frame].size.height/2+12)];
    [volumeImageLayer setContents:imgVolOn];
    
    /*
    iconLayer = [CALayer layer];
    [iconLayer setFrame:NSRectToCGRect(rectIcon)];
    [iconLayer setPosition:CGPointMake([volumeImageLayer frame].size.width/2-22, [volumeImageLayer frame].size.height/2)];
    [iconLayer setContents:spotifyIcon];
    
     
    [volumeImageLayer addSublayer:iconLayer];
    */
    [mainLayer addSublayer:volumeImageLayer];
    
    [self createVolumeBar];
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    signal(SIGTERM, handleSIGTERM);
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString * operatingSystemVersionString = [[NSProcessInfo processInfo] operatingSystemVersionString];
    
    [[SUUpdater sharedUpdater] setFeedURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://quantum-technologies.iap.uni-bonn.de/alberti/iTunesVolumeControl/iTunesVolumeControlCast.xml.php?version=%@&osxversion=%@",version,[operatingSystemVersionString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    
    [[SUUpdater sharedUpdater] setUpdateCheckInterval:60*60*24*7]; // look for new updates every 7 days
    
    [_volumeWindow orderOut:self];
    [_volumeWindow setLevel:NSFloatingWindowLevel];
    
    [self showInStatusBar];   // Install icon into the menu bar
    
    //[self checkSIPforAppIdentifier:@"com.apple.iTunes"];
    
    iTunes = [[PlayerApplication alloc] initWithBundleIdentifier:@"com.apple.iTunes"];
    spotify = [[PlayerApplication alloc] initWithBundleIdentifier:@"com.spotify.client"];
    systemAudio = [[SystemApplication alloc] init];

    // NSString* iTunesVersion = [[NSString alloc] initWithString:[iTunes version]];
    // NSString* spotifyVersion = [[NSString alloc] initWithString:[spotify version]];
    
    musicProgramPnt = iTunes;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseITunesVolume:) name:@"IncreaseITunesVolume" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseITunesVolume:) name:@"IncreaseITunesVolumeRamp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decreaseITunesVolume:) name:@"DecreaseITunesVolume" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decreaseITunesVolume:) name:@"DecreaseITunesVolumeRamp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(muteITunesVolume:) name:@"MuteITunesVolume" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playPauseITunes:) name:@"PlayPauseITunes" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextTrackITunes:) name:@"NextTrackITunes" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(previousTrackITunes:) name:@"PreviousTrackITunes" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayResolutionChanged:) name:@"displayResolutionHasChanged" object:nil];

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
    
    CGDisplayRegisterReconfigurationCallback(displayPreferencesChanged, NULL);
    
    // [self _loadBezelServices]; // El Capitan and probably older systems
    [self _loadOSDFramework];
    
    bool res;
    do{
        res = [self createEventTap];
        
        if(!res)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"It seems that \"iTunes Volume Control\" is not authorized to respond upon events where the volume keys are pressed."];
            [alert setInformativeText:@"Open the \"System Preferences\", go to \"Security & Privacy\", and enable \"iTunes Volume Control\" in \"Accessibility\". If \"iTunes Volume Control\" appears to be already enabled, remove it from \"Accessibility\", so as to force MacOS to reconsider it."];
            [alert addButtonWithTitle:@"Restart"];
            [alert addButtonWithTitle:@"Exit"];
            
            NSModalResponse responseTag = [alert runModal];
            
            if (responseTag == NSAlertSecondButtonReturn) {
                [NSApp terminate:nil];
            }
            else {
                [self restartOurselves];
            }
        }
    }while(!res);
    
    [self appleRemoteInit];
    
    [self initializePreferences];
    
    [self setStartAtLogin:[self StartAtLogin] savePreferences:false];
    
//    if([self loadIntroAtStart])
//        [self showIntroWindow:nil];
    
}

- (void) restartOurselves
{
    //$N = argv[N]
    NSString *killArg1AndOpenArg2Script = @"kill -15 $1 \n open \"$2\"";
    
    //NSTask needs its arguments to be strings
    NSString *ourPID = [NSString stringWithFormat:@"%d",
                        [[NSProcessInfo processInfo] processIdentifier]];
    
    //this will be the path to the .app bundle,
    //not the executable inside it; exactly what `open` wants
    NSString * pathToUs = [[NSBundle mainBundle] bundlePath];
    
    NSArray *shArgs = [NSArray arrayWithObjects:@"-c", // -c tells sh to execute the next argument, passing it the remaining arguments.
                       killArg1AndOpenArg2Script,
                       @"", //$0 path to script (ignored)
                       ourPID, //$1 in restartScript
                       pathToUs, //$2 in the restartScript
                       nil];
    NSTask *restartTask = [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:shArgs];
    [restartTask waitUntilExit]; //wait for killArg1AndOpenArg2Script to finish
    NSLog(@"*** ERROR: %@ should have been terminated, but we are still running", pathToUs);
    assert(!"We should not be running!");
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    [self showInStatusBar];
    [self setHideFromStatusBar:[self hideFromStatusBar]];
    if ([self hideFromStatusBar])
    {
        [self showHideFromStatusBarHintPopover];
    }
    
    return false;
}

- (void)showInStatusBar
{
    if (![self statusBar])
    {
        // the status bar item needs a custom view so that we can show a NSPopover for the hide-from-status-bar hint
        // the view now reacts to the mouseDown event to show the menu
        
        _statusBar =  [[NSStatusBar systemStatusBar] statusItemWithLength:26];
        [_statusBar setMenu:_statusMenu];
    }
    
    if (!_statusBarItemView)
    {
        _statusBarItemView = [[StatusItemView alloc] initWithStatusItem:_statusBar];
    }
    
    [_statusBar setView:_statusBarItemView];
}

- (void)initializePreferences
{
    preferences = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:2],      @"volumeIncrement",
                          [NSNumber numberWithBool:true] , @"TappingEnabled",
                          [NSNumber numberWithBool:false], @"AppleRemoteConnected",
                          [NSNumber numberWithBool:false], @"UseAppleCMDModifier",
                          [NSNumber numberWithBool:true],  @"AutomaticUpdates",
                          [NSNumber numberWithBool:false], @"hideFromStatusBarPreference",
                          [NSNumber numberWithBool:false], @"hideVolumeWindowPreference",
                          [NSNumber numberWithBool:true],  @"iTunesControl",
                          [NSNumber numberWithBool:true],  @"spotifyControl",
                          [NSNumber numberWithBool:true],  @"systemControl",
                          [NSNumber numberWithBool:true],  @"loadIntroAtStart",
                          nil ]; // terminate the list
    [preferences registerDefaults:dict];
    
    [self setAppleRemoteConnected:[preferences boolForKey: @"AppleRemoteConnected"]];
    [self setTapping:[preferences boolForKey:              @"TappingEnabled"]];
    [self setUseAppleCMDModifier:[preferences boolForKey:  @"UseAppleCMDModifier"]];
    [self setAutomaticUpdates:[preferences boolForKey:     @"AutomaticUpdates"]];
    [self setHideFromStatusBar:[preferences boolForKey:    @"hideFromStatusBarPreference"]];
    [self setHideVolumeWindow:[preferences boolForKey:     @"hideVolumeWindowPreference"]];
    [[self iTunesBtn] setState:[preferences boolForKey:    @"iTunesControl"]];
    [[self spotifyBtn] setState:[preferences boolForKey:   @"spotifyControl"]];
    [[self systemBtn] setState:[preferences boolForKey:    @"systemControl"]];
    [self setLoadIntroAtStart:[preferences boolForKey:     @"loadIntroAtStart"]];
    
    NSInteger volumeIncSetting = [preferences integerForKey:@"volumeIncrement"];
    [self setVolumeInc:volumeIncSetting];
    
    [[self volumeIncrementsSlider] setIntegerValue: volumeIncSetting];
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

- (IBAction)toggleIntroAtStart:(id)sender
{
    [self setLoadIntroAtStart:![self loadIntroAtStart]];
}

- (void)setLoadIntroAtStart:(bool)enabled
{
    [preferences setBool:enabled forKey:@"loadIntroAtStart"];
    [preferences synchronize];
    
    _loadIntroAtStart=enabled;
}

- (void)setAppleRemoteConnected:(bool)enabled
{
    NSMenuItem* menuItem=[_statusMenu itemWithTag:2];
    [menuItem setState:enabled];
    
    if(enabled && _Tapping)
    {
        [remote startListening:self];
    }
    else
    {
        [remote stopListening:self];
    }
    waitOverlayPanel=1.0;
    
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
        [_statusBarItemView setIconStatusBarIsGrayed:NO];
        if([self AppleRemoteConnected]) [remote startListening:self];
    }
    else
    {
        [_statusBarItemView setIconStatusBarIsGrayed:YES];
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

/*
- (IBAction)showIntroWindow:(id)sender
{
    if(!introWindowController)
    {
        introWindowController = [[IntroWindowController alloc] initWithWindowNibName:@"IntroWindow"];
    }
    
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [introWindowController showWindow:self];
    [[introWindowController window] makeKeyAndOrderFront:self];
}
*/

- (IBAction)sliderValueChanged:(NSSliderCell*)slider
{
    NSInteger volumeIncSetting = [[self volumeIncrementsSlider] integerValue];
    
    [self setVolumeInc:volumeIncSetting];
    
    [preferences setInteger:volumeIncSetting forKey:@"volumeIncrement"];
    [preferences synchronize];

}

- (void) setVolumeInc:(NSInteger)volumeIncSetting
{
    switch(volumeIncSetting)
    {
        case 5:
            increment = 25;
            break;
        case 4:
            increment = 12.5;
            break;
        case 3:
            increment = 6.25;
            break;
        case 2:
            increment = 3.125;
            break;
        case 1:
        default:
            increment = 1.5625;
            break;
            
    }
}

- (IBAction)aboutPanel:(id)sender
{
    
//    return;
    
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

- (void) displayResolutionChanged: (NSNotification*) note
{
    /* TODO test with the old operating system and check it is triggered when res is changed */
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    [_volumeWindow setFrame:(osxVersion<110?  CGRectMake(round((screenFrame.size.width-210)/2),139,210,206) : CGRectMake(round((screenFrame.size.width-200)/2),140,200,200)) display:NO animate:NO];
}

- (void) receiveWakeNote: (NSNotification*) note
{
    [self setTapping:[self Tapping]];
    [self setAppleRemoteConnected:[self AppleRemoteConnected]];
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
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    
    [remote stopListening:self];

    /*
     remote=nil;
     
     imgVolOn=nil;
     imgVolOff=nil;
     
     introWindowController = nil;
     
     volumeImageLayer=nil;
     for(int i=0; i<16; i++)
     {
     volumeBar[i]=nil;
     }
     
     imgVolOn=nil;
     imgVolOff=nil;
     
     fadeOutAnimation=nil;
     fadeInAnimation=nil;
     
     _statusBar = nil;
     */
    
}

- (void) showSpeakerImg:(NSTimer*)theTimer
{
    [_volumeWindow orderFront:self];
    
    fadeInAnimationReady=false;
    [mainLayer addAnimation:fadeInAnimation forKey:@"increaseOpacity"];
}

- (void) hideSpeakerImg:(NSTimer*)theTimer
{
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            [self->_volumeWindow orderOut:self];
            self->fadeInAnimationReady=true;
        }];
        [mainLayer addAnimation:fadeOutAnimation forKey:@"decreaseOpacity"];
    } [CATransaction commit];
}

-(void)resetEventTap
{
        CGEventTapEnable(eventTap, _Tapping);
}

- (IBAction)increaseVol:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IncreaseITunesVolume" object:NULL];
    
}

- (id)runningPlayer
{
    id musicPlayerPnt = nil;
    if([_iTunesBtn state] && [iTunes isRunning] && [iTunes playerState] == iTunesEPlSPlaying)
    {
        musicPlayerPnt = iTunes;
    }
    else if([_spotifyBtn state] && [spotify isRunning] && [spotify playerState] == SpotifyEPlSPlaying)
    {
        musicPlayerPnt = spotify;
    }
    else if([_systemBtn state])
    {
        musicPlayerPnt = systemAudio;
    }
    
    return musicPlayerPnt;
}

- (void)changeVol:(bool)increase
{
    id musicPlayerPnt = [self runningPlayer];
    
    if (musicPlayerPnt != nil)
    {
        double volume = [musicPlayerPnt currentVolume];
        
        if([musicPlayerPnt oldVolume]<0) // if it was not mute
        {
            //volume=[musicProgramPnt soundVolume]+_volumeInc*(increase?1:-1);
            volume += (increase?1:-1)*increment;
        }
        else // if it was mute
        {
            // [volumeImageLayer setContents:imgVolOn];  // restore the image of the speaker from mute speaker
            volume=[musicPlayerPnt oldVolume];
            [musicPlayerPnt setOldVolume:-1];  // this says that it is not mute
        }
        if (volume<0) volume=0;
        if (volume>100) volume=100;
        
        /*
        NSInteger i = 0;
        double diff1 = abs(100);
        double diff2;
        
        for (NSInteger j = 1; j < numPos; j++ ) {
            diff2 = fabs(volume - (double)positions[j]);
            if ( diff2<diff1 )
            {
                diff1 = diff2;
                i = j;
            }
        }
        */
        
        OSDGraphic image = (volume > 0)? OSDGraphicSpeaker : OSDGraphicSpeakerMute;
        
        NSInteger numFullBlks = floor(volume/6.25);
        NSInteger numQrtsBlks = round((volume-(double)numFullBlks*6.25)/1.5625);
        
        //NSLog(@"%d %d",(int)numFullBlks,(int)numQrtsBlks);
        
        if(!_hideVolumeWindow)
            [[NSClassFromString(@"OSDManager") sharedManager] showImage:image onDisplayID:CGSMainDisplayID() priority:OSDPriorityDefault msecUntilFade:1000 filledChiclets:(unsigned int)(round(((numFullBlks*4+numQrtsBlks)*1.5625)*100)) totalChiclets:(unsigned int)10000 locked:NO];
        
        [musicPlayerPnt setCurrentVolume:volume];
        
        if([_statusBarItemView menuIsVisible])
        {
            if( musicPlayerPnt == iTunes)
                [self setItunesVolume:volume];
            else if( musicPlayerPnt == spotify)
                [self setSpotifyVolume:volume];
            else if( musicPlayerPnt == systemAudio)
                [self setSystemVolume:volume];
        }
        // [self refreshVolumeBar:(int)volume];
    }
}

- (void) setItunesVolume:(NSInteger)volume
{
    if (volume == -1)
        [[self iTunesPerc] setHidden:YES];
    else
    {
        [[self iTunesPerc] setHidden:NO];
        [[self iTunesPerc] setStringValue:[NSString stringWithFormat:@"(%d%%)",(int)volume]];
    }
}

- (void) setSpotifyVolume:(NSInteger)volume
{
    if (volume == -1)
        [[self spotifyPerc] setHidden:YES];
    else
    {
        [[self spotifyPerc] setHidden:NO];
        [[self spotifyPerc] setStringValue:[NSString stringWithFormat:@"(%d%%)",(int)volume]];
    }
}

- (void) setSystemVolume:(NSInteger)volume
{
    if (volume == -1)
        [[self systemPerc] setHidden:YES];
    else
    {
        [[self systemPerc] setHidden:NO];
        [[self systemPerc] setStringValue:[NSString stringWithFormat:@"(%d%%)",(int)volume]];
    }
    
}

- (void) updatePercentages
{
    if([iTunes isRunning])
        [self setItunesVolume:[iTunes currentVolume]];
    else
        [self setItunesVolume:-1];
    
    if([spotify isRunning])
        [self setSpotifyVolume:[spotify currentVolume]];
    else
        [self setSpotifyVolume:-1];
    
    [self setSystemVolume:[systemAudio currentVolume]];
}

- (void) createVolumeBar
{
    
    CALayer* background;
    int i;
    
    /*
    for(i=0; i<16; i++)
    {
        background = [CALayer layer];
        [background setFrame:CGRectMake(9*i+32, 29.0, 7.0, 9.0)];
        [background setBackgroundColor:CGColorCreateGenericRGB(0.f, 0.f, 0.f, 0.5f)];
        
        [mainLayer addSublayer:background];
    }
     
    */
    
    background = [CALayer layer];
    [background setFrame:CGRectMake(20.0, 20, 160.0, 8.0)];
    [background setBackgroundColor:CGColorCreateGenericRGB(0.f, 0.f, 0.f, 0.5f)];
     
    [mainLayer addSublayer:background];
    
    for(i=0; i<16; i++)
    {
        volumeBar[i] = [CALayer layer];
        [volumeBar[i] setFrame:CGRectMake(10*i+21, 21.0, 9.0, 6.0)];
        [volumeBar[i] setBackgroundColor:CGColorCreateGenericRGB(1.0f, 1.0f, 1.0f, 1.0f)];
        
        /*
        [volumeBar[i] setShadowOffset:CGSizeMake(-1, -1)];
        [volumeBar[i] setShadowRadius:1.0];
        [volumeBar[i] setShadowColor:CGColorCreateGenericRGB(0.f, 0.f, 0.f, 1.0f)];
        [volumeBar[i] setShadowOpacity:0.5];
        */
        
        [volumeBar[i] setHidden:YES];
        
        [mainLayer addSublayer:volumeBar[i]];
    }
    
}

- (void) refreshVolumeBar:(NSInteger)volume
{
    NSInteger doubleFullRectangles = (NSInteger)round(32.0f * volume / 100.0f);
    NSInteger fullRectangles=doubleFullRectangles>>1;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration: 0.0];
    [CATransaction setDisableActions: TRUE];
    
    if(volume==0)
    {
        [volumeImageLayer setContents:imgVolOff];
    }
    else
    {
        [volumeImageLayer setContents:imgVolOn];
    }
    
    CGRect frame;
    
    for(NSInteger i=0; i<fullRectangles; i++)
    {
        frame = [volumeBar[i] frame];
        frame.size.width=9;
        [volumeBar[i] setFrame:frame];

        [volumeBar[i] setHidden:NO];
    }
    for(NSInteger i=fullRectangles; i<16; i++)
    {
        frame = [volumeBar[i] frame];
        frame.size.width=9;
        [volumeBar[i] setFrame:frame];
        
        [volumeBar[i] setHidden:YES];
    }
    
    if(fullRectangles*2 != doubleFullRectangles)
    {
        
        frame = [volumeBar[fullRectangles] frame];
        frame.size.width=5;
        
        [volumeBar[fullRectangles] setFrame:frame];
        [volumeBar[fullRectangles] setHidden:NO];
    }
    
    [CATransaction commit];
}

/*
- (void) displayVolumeBar
{
    if(fadeInAnimationReady) [self showSpeakerImg:nil];
    if(timerImgSpeaker) {[timerImgSpeaker invalidate]; timerImgSpeaker=nil;}
    timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:waitOverlayPanel target:self selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timerImgSpeaker forMode:NSRunLoopCommonModes];
}
*/

#pragma mark - Hide From Status Bar

- (IBAction)toggleHideFromStatusBar:(id)sender
{
    [self setHideFromStatusBar:![self hideFromStatusBar]];
    if ([self hideFromStatusBar])
        [self showHideFromStatusBarHintPopover];
}

- (void)setHideFromStatusBar:(bool)enabled
{
    _hideFromStatusBar=enabled;
    
    NSMenuItem* menuItem=[_statusMenu itemWithTag:5];
    [menuItem setState:[self hideFromStatusBar]];
    
    [preferences setBool:enabled forKey:@"hideFromStatusBarPreference"];
    [preferences synchronize];
    
    if(enabled)
    {
        if (![_statusBarHideTimer isValid] && [self statusBar])
        {
            [self setHideFromStatusBarHintLabelWithSeconds:statusBarHideDelay];
            _statusBarHideTimer = [NSTimer scheduledTimerWithTimeInterval:statusBarHideDelay target:self selector:@selector(doHideFromStatusBar:) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:_statusBarHideTimer forMode:NSRunLoopCommonModes];
            _hideFromStatusBarHintPopoverUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateHideFromStatusBarHintPopover:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_hideFromStatusBarHintPopoverUpdateTimer forMode:NSRunLoopCommonModes];
        }
    }
    else
    {
        [_hideFromStatusBarHintPopover close];
        [_statusBarHideTimer invalidate];
        _statusBarHideTimer = nil;
        [_hideFromStatusBarHintPopoverUpdateTimer invalidate];
        _hideFromStatusBarHintPopoverUpdateTimer = nil;
    }
}

- (void)doHideFromStatusBar:(NSTimer*)aTimer
{
    [_hideFromStatusBarHintPopoverUpdateTimer invalidate];
    _hideFromStatusBarHintPopoverUpdateTimer = nil;
    _statusBarHideTimer = nil;
    [_hideFromStatusBarHintPopover close];
    [[NSStatusBar systemStatusBar] removeStatusItem:[self statusBar]];
    _statusBar = nil;
    
    [self setHideFromStatusBar:true];
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
        
        _hintView = [[NSView alloc] initWithFrame:popoverRect];
        [_hintView addSubview:_hideFromStatusBarHintLabel];
        
        _hintVC = [[NSViewController alloc] init];
        [_hintVC setView:_hintView];
        
        _hideFromStatusBarHintPopover = [[NSPopover alloc] init];
        [_hideFromStatusBarHintPopover setContentViewController:_hintVC];
    }
    
    [_hideFromStatusBarHintPopover showRelativeToRect:[_statusBarItemView frame] ofView:_statusBarItemView preferredEdge:NSMinYEdge];
}

- (void)updateHideFromStatusBarHintPopover:(NSTimer*)aTimer
{
    NSDate* now = [NSDate date];
    [self setHideFromStatusBarHintLabelWithSeconds:[[_statusBarHideTimer fireDate] timeIntervalSinceDate:now]];
}

- (void)setHideFromStatusBarHintLabelWithSeconds:(NSUInteger)seconds
{
    [_hideFromStatusBarHintLabel setStringValue:[NSString stringWithFormat:@"iTunes Volume Control will hide after %ld seconds.\n\nLaunch it again to re-show the icon.",seconds]];
}

#pragma mark - Music players

- (IBAction)toggleMusicPlayer:(id)sender
{
    if (sender == _iTunesBtn) {
        [preferences setBool:[sender state] forKey:@"iTunesControl"];
    }
    else if (sender == _spotifyBtn)
    {
        [preferences setBool:[sender state] forKey:@"spotifyControl"];
    }
    else if (sender == _systemBtn)
    {
        [preferences setBool:[sender state] forKey:@"systemControl"];
    }
    [preferences synchronize];
}

#pragma mark - NSMenuDelegate

- (IBAction)toggleHideVolumeWindow:(id)sender
{
    [self setHideVolumeWindow:![self hideVolumeWindow]];
}

- (void)setHideVolumeWindow:(bool)enabled
{
    _hideVolumeWindow=enabled;
    
    NSMenuItem* menuItem=[_statusMenu itemWithTag:6];
    [menuItem setState:[self hideVolumeWindow]];
    
    [preferences setBool:enabled forKey:@"hideVolumeWindowPreference"];
    [preferences synchronize];
}


- (void)menuWillOpen:(NSMenu *)menu
{
    [_statusBarItemView setMenuIsVisible:true];
    [_hideFromStatusBarHintPopover close];
}

- (void)menuDidClose:(NSMenu *)menu
{
    [_statusBarItemView setMenuIsVisible:false];
    if ([self hideFromStatusBar])
        [self showHideFromStatusBarHintPopover];
}

@end
