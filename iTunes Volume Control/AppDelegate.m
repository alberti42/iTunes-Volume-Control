//
//  AppDelegate.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 25.12.12.
//  Copyright (c) 2012 Andrea Alberti. All rights reserved.
//

#import "AppDelegate.h"
#import <IOKit/hidsystem/ev_keymap.h>

CGEventRef event_tap_callback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
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
    CGEventFlags keyModifier = [sysEvent modifierFlags]|0xFFFF;
    AppDelegate* app=(__bridge AppDelegate *)(refcon);
    app->keyIsRepeat = (keyFlags & 0x1);
    
    CGEventFlags mask=([app UseAppleCMDModifier] ? NX_COMMANDMASK:0)|0xFFFF;
    
    switch( keyCode )
	{
		case NX_KEYTYPE_SOUND_UP:
        case NX_KEYTYPE_SOUND_DOWN:
            if( keyModifier==mask )
            {
                if( keyState == 1 )
                {
                    if( keyCode == NX_KEYTYPE_SOUND_UP )
                    {
                        if (!app->keyIsRepeat||!app->previousKeyIsRepeat)
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"IncreaseITunesVolume" object:NULL];
                    }
                    else
                    {
                        if (!app->keyIsRepeat||!app->previousKeyIsRepeat)
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"DecreaseITunesVolume" object:NULL];
                    }
                }
                else
                {
                    if(app->previousKeyIsRepeat)
                    {
                        app->timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:0.7 target:app selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
                        [app->timer invalidate];
                        app->timer=nil;
                    }
                }
                app->previousKeyIsRepeat=app->keyIsRepeat;
                return NULL;
            }
            break;
    }
    
    return event;
}

@implementation AppDelegate

@synthesize AppleRemoteConnected=_AppleRemoteConnected;
@synthesize StartAtLogin=_StartAtLogin;
@synthesize Tapping=_Tapping;
@synthesize UseAppleCMDModifier=_UseAppleCMDModifier;

@synthesize window=_window;
@synthesize statusMenu=_statusMenu;

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
//            if (itemRef) {
//                CFRelease(itemRef);
//            }
            
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
//                    if (itemRef) {
//                        CFRelease(itemRef);
//                    }
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

- (void)increaseITunesVolume:(NSNotification *)aNotification
{
    if( keyIsRepeat&&!previousKeyIsRepeat )
    {
        timer=[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(rampVolumeUp:) userInfo:nil repeats:YES];
        if(timerImgSpeaker) [timerImgSpeaker invalidate];
    }
    else
    {
        [self displayVolumeBar];
        [self changeVol:+2];
    }
}

- (void)decreaseITunesVolume:(NSNotification *)aNotification
{
    if( keyIsRepeat&&!previousKeyIsRepeat )
    {
        timer=[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(rampVolumeDown:) userInfo:nil repeats:YES];
        if(timerImgSpeaker) [timerImgSpeaker invalidate];
    }
    else
    {
        [self displayVolumeBar];
        [self changeVol:-2];
    }
}

- (void) appleRemoteButton: (AppleRemoteEventIdentifier)buttonIdentifier pressedDown: (BOOL) pressedDown clickCount: (unsigned int) count {
    switch (buttonIdentifier)
    {
        case kRemoteButtonVolume_Plus_Hold:
            if(timer==nil)
            {
                if(timerImgSpeaker) [timerImgSpeaker invalidate];
                timer=[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(rampVolumeUp:) userInfo:nil repeats:YES];
            }
            else
            {
                timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
                [self stopTimer];
            }
            break;
        case kRemoteButtonVolume_Plus:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"IncreaseITunesVolume" object:NULL];
            break;
            
        case kRemoteButtonVolume_Minus_Hold:
            if(timer==nil)
            {
                if(timerImgSpeaker) [timerImgSpeaker invalidate];
                timer=[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(rampVolumeDown:) userInfo:nil repeats:YES];
            }
            else
            {
                timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
                [self stopTimer];
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

- (id)init
{
    self = [super init];
    if(self)
    {
        previousKeyIsRepeat=false;
        
        fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [fadeOutAnimation setDuration:0.7f];
        [fadeOutAnimation setRemovedOnCompletion:NO];
        [fadeOutAnimation setFillMode:kCAFillModeForwards];
        [fadeOutAnimation setFromValue:[NSNumber numberWithFloat:1.0f]];
        [fadeOutAnimation setToValue:[NSNumber numberWithFloat:0.0f]];
        // [fadeOutAnimation setDelegate:self];
        
        fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [fadeInAnimation setDuration:0.2f];
        [fadeInAnimation setRemovedOnCompletion:NO];
        [fadeInAnimation setFillMode:kCAFillModeForwards];
        [fadeInAnimation setFromValue:[NSNumber numberWithFloat:0.0f]];
        [fadeInAnimation setToValue:[NSNumber numberWithFloat:1.0f]];
        // [fadeInAnimation setDelegate:self];
        fadeInAnimationReady=true;
        
    }
    return self;
}


// http://cocoadevcentral.com/d/intro_to_quartz/

-(void)awakeFromNib
{
    //[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    //[_window makeKeyAndOrderFront:self];
    
    [[_window contentView] setWantsLayer:YES];
    [_window setFrame:[_window frame]/*[[NSScreen mainScreen] frame]*/ display:NO animate:NO];
    
    mainLayer = [[_window contentView] layer];
    CGColorRef backgroundColor=CGColorCreateGenericRGB(0.459f, 0.459f, 0.459f, 0.30f);
    [mainLayer setBackgroundColor:backgroundColor];
    CFRelease(backgroundColor);
    //mainLayer.borderColor=CGColorCreateGenericRGB(0.0f,0.0f,0.0f,1.0f);
    //mainLayer.borderWidth=4.0;
    [mainLayer setCornerRadius:22];
    [mainLayer setOpacity:0.0f];
    
    //[root insertSublayer:mainLayer above:0];
    
    NSImage *img=[NSImage imageNamed:@"volume"];
    NSRect rect = NSZeroRect;
	rect.size = img.size;
    
    CALayer* imageLayer = [CALayer layer];
    [imageLayer setFrame:NSRectToCGRect(rect)];
    [imageLayer setContents:img];
    [imageLayer setPosition:CGPointMake([[_window contentView] frame].size.width/2-1, [[_window contentView]frame].size.height/2+12)];
    
	[mainLayer addSublayer:imageLayer];
    
    [self createVolumeBar];
    
    //    volumeBar = [CALayer layer];
    //    [volumeBar setFrame:[[_window contentView] frame]];
    //    [mainLayer addSublayer:volumeBar];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [_window orderOut:nil];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    // [statusItem setTitle:@"iTunes Volume Control"];
    [statusItem setMenu:_statusMenu];
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
    
    [self initializePreferences];
    
    [self setStartAtLogin:[self StartAtLogin] savePreferences:false];
}

- (void)initializePreferences
{
    preferences = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithBool:false] ,@"TappingEnabled",
                          [NSNumber numberWithBool:false] ,@"AppleRemoteConnected",
                          [NSNumber numberWithBool:false] ,@"UseAppleCMDModifier",
                          nil ]; // terminate the list
    [preferences registerDefaults:dict];
    
    [self setAppleRemoteConnected:[preferences boolForKey:@"AppleRemoteConnected"]];
    [self setTapping:[preferences boolForKey:@"TappingEnabled"]];
    [self setUseAppleCMDModifier:[preferences boolForKey:@"UseAppleCMDModifier"]];
}

- (IBAction)toggleStartAtLogin:(id)sender
{
    [self setStartAtLogin:![self StartAtLogin] savePreferences:true];
}

- (void)setAppleRemoteConnected:(bool)enabled
{
    NSMenuItem* menuItem=[_statusMenu itemWithTag:2];
    [menuItem setState:enabled];
    
    if(enabled && CGEventTapIsEnabled(eventTap))
        [remote startListening:self];
    else
        [remote stopListening:self];
    
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
        [statusItem setImage:statusImageOn];
        if([self AppleRemoteConnected]) [remote startListening:self];
    }
    else
    {
        [statusItem setImage:statusImageOff];
        [remote stopListening:self];
    }
    
    [preferences setBool:CGEventTapIsEnabled(eventTap) forKey:@"TappingEnabled"];
    [preferences synchronize];
    
    _Tapping=enabled;
}

- (IBAction)toggleTapping:(id)sender
{
    [self setTapping:![self Tapping]];
}

- (IBAction)aboutPanel:(id)sender
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:sender];
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
}

- (void) showSpeakerImg:(NSTimer*)theTimer
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [_window makeKeyAndOrderFront:self];
    
    //[fadeInAnimation setFromValue:[NSNumber numberWithFloat:0.0f /*mainLayer.opacity*/]];
    //[fadeInAnimation setDuration:0.2f];//*(1.0f-mainLayer.opacity);
    fadeInAnimationReady=false;
    [mainLayer addAnimation:fadeInAnimation forKey:@"increaseOpacity"];
}

- (void) hideSpeakerImg:(NSTimer*)theTimer
{
    fadeInAnimationReady=true;
    [mainLayer addAnimation:fadeOutAnimation forKey:@"decreaseOpacity"];
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
        
        [background setShadowOffset:CGSizeMake(-1, -2)];
        [background setShadowRadius:2.0];
        [background setShadowColor:CGColorCreateGenericRGB(0.3f, 0.3f, 0.3f, 1.0f)];
        [background setShadowOpacity:0.5];
        
        [mainLayer addSublayer:background];
    }
    
    for(i=0; i<16; i++)
    {
        volumeBar[i] = [CALayer layer];
        [volumeBar[i] setFrame:CGRectMake(9*i+32, 29.0, 7.0, 9.0)];
        [volumeBar[i] setBackgroundColor:CGColorCreateGenericRGB(1.0f, 1.0f, 1.0f, 1.0f)];
        
        /*[volumeBar[i] setShadowOffset:CGSizeMake(-1, -2)];
         [volumeBar[i] setShadowRadius:1.0];
         [volumeBar[i] setShadowColor:CGColorCreateGenericRGB(0.3f, 0.3f, 0.3f, 1.0f)];
         [volumeBar[i] setShadowOpacity:0.5];*/
        
        [volumeBar[i] setHidden:YES];
        
        [mainLayer addSublayer:volumeBar[i]];
    }
}

- (void) refreshVolumeBar:(NSInteger)volume
{
    NSInteger i;
    NSInteger fullRectangles=(NSInteger)(16.0f*volume/100.0f);
    for(i=0; i<fullRectangles; i++)
    {
        [volumeBar[i] setHidden:NO];
    }
    for(NSInteger i=fullRectangles; i<16; i++)
    {
        [volumeBar[i] setHidden:YES];
    }
    
    //    CGRect frame;
    //
    //    if(fullRectangles!=0)
    //    {
    //        frame = [volumeBar[fullRectangles-1] frame];
    //        frame.size.width=7;
    //        [volumeBar[fullRectangles-1] setFrame:frame];
    //    }
    //
    //    if(fullRectangles!=16)
    //    {
    //        NSInteger partialRectangle = (NSInteger)(16.f*volume/50.f)%2;
    //
    //        frame = [volumeBar[fullRectangles] frame];
    //        frame.size.width=round(3.5f*partialRectangle);
    //
    //        [volumeBar[fullRectangles] setFrame:frame];
    //        [volumeBar[fullRectangles] setHidden:NO];
    //    }
    
    
}

- (void) displayVolumeBar
{
    if(fadeInAnimationReady) [self showSpeakerImg:nil];
    if(timerImgSpeaker) [timerImgSpeaker invalidate];
    timerImgSpeaker=[NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(hideSpeakerImg:) userInfo:nil repeats:NO];
}

@end
