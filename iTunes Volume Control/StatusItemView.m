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
@synthesize isHighlighted = _isHighlighted;
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
    [self setImage: isGrayed? statusImageOff : statusImageOn];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
    if (_menuIsVisible)
    {
        NSRect bounds = [self bounds];
        [_statusItem drawStatusBarBackgroundInRect:bounds withHighlight:YES];
    }
    
	[[self image] drawAtPoint:iconPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];

}

- (void) dealloc
{
    statusImageClicked=nil;
    statusImageOn=nil;
    statusImageOff=nil;    
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];
    
    if (self != nil) {
        _statusItem = statusItem;
        _statusItem.view = self;
    }
    
    statusImageClicked = [NSImage imageNamed:@"statusbar-item-clicked"];
    statusImageOn = [NSImage imageNamed:@"statusbar-item-on"];
    statusImageOff = [NSImage imageNamed:@"statusbar-item-off"];
    
    NSSize iconSize = [statusImageOn size];
    NSRect bounds = self.bounds;
    CGFloat iconX = roundf((NSWidth(bounds) - iconSize.width) / 2) - 1;
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    iconPoint = NSMakePoint(iconX, iconY);

    return self;
}

-(void)setMenuIsVisible:(BOOL)menuIsVisible
{
    if (_menuIsVisible!=menuIsVisible)
    {
        _menuIsVisible = menuIsVisible;

        [self setImage: menuIsVisible? statusImageClicked : ([self iconStatusBarIsGrayed]? statusImageOff : statusImageOn)];
        
        [self setNeedsDisplay:YES];
    }
}

@end
