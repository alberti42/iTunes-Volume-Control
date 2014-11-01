//
//  StatusItemView.m
//  iTunes Volume Control
//
//  Created by Thomas Heß on 23.7.13.
//  Copyright (c) 2013 Andrea Alberti. All rights reserved.
//

#import "StatusItemView.h"
#import "AppDelegate.h"

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize iconStatusBarIsGrayed = _iconStatusBarIsGrayed;
@synthesize menuIsVisible = _menuIsVisible;
@synthesize image = _image;

- (void)mouseDown:(NSEvent *)theEvent
{
    AppDelegate* appDelegate = [[NSApplication sharedApplication] delegate];
    
    if (! [self menuIsVisible])
        [[appDelegate statusBar] popUpStatusItemMenu:[[appDelegate statusBar] menu]];
}

- (void) setIconStatusBarIsGrayed:(bool)isGrayed
{
    _iconStatusBarIsGrayed = isGrayed;
    [self setImage: isGrayed? statusImageOff : statusImageOn];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
    NSRect bounds = [self bounds];
    if (_menuIsVisible)
    {
        [_statusItem drawStatusBarBackgroundInRect:bounds withHighlight:true];
    }
    else
    {
        [_statusItem drawStatusBarBackgroundInRect:bounds withHighlight:false];
    }
    
	[[self image] drawAtPoint:iconPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void) dealloc
{
    /*
    statusImageOnClicked=nil;
    statusImageOn=nil;
    statusImageOff=nil;    
     */
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];
    
    if (self != nil) {
        
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(darkModeChanged:) name:@"AppleInterfaceThemeChangedNotification" object:nil];

        _statusItem = statusItem;
        
        statusImageBlack = [NSImage imageNamed:@"statusbar-item-black"];
        statusImageBlue = [NSImage imageNamed:@"statusbar-item-blue"];
        statusImageGray = [NSImage imageNamed:@"statusbar-item-gray"];
        statusImageWhite = [NSImage imageNamed:@"statusbar-item-white"];
        
        [self setAppropriateColorScheme];
        
        NSSize iconSize = [statusImageOn size];
        NSRect bounds = self.bounds;
        CGFloat iconX = roundf((NSWidth(bounds) - iconSize.width) / 2) - 2;
        CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
        iconPoint = NSMakePoint(iconX, iconY);
    }
    
    return self;
}

-(void)setAppropriateColorScheme
{
    bool isDark = [[[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"] isEqualToString:@"Dark"];

    if(isDark)
    {
        statusImageOnClicked = statusImageWhite;
        statusImageOffClicked = statusImageBlue;
        statusImageOn = statusImageWhite;
        statusImageOff = statusImageGray;
    }
    else
    {
        statusImageOnClicked = statusImageWhite;
        statusImageOffClicked = statusImageBlue;
        statusImageOn = statusImageBlack;
        statusImageOff = statusImageGray;
    }
    

}

-(void)darkModeChanged:(NSNotification *)notif
{
    [self setAppropriateColorScheme];

    [self setNeedsDisplay:YES];
 
}


-(void)setMenuIsVisible:(BOOL)menuIsVisible
{
    if (_menuIsVisible!=menuIsVisible)
    {
        _menuIsVisible = menuIsVisible;

        [self setImage: menuIsVisible? ([self iconStatusBarIsGrayed]? statusImageOffClicked : statusImageOnClicked) : ([self iconStatusBarIsGrayed]? statusImageOff : statusImageOn)];

        [self setNeedsDisplay:YES];
    }
}

@end
