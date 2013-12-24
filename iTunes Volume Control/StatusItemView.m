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
@synthesize image = _image;
@synthesize alternateImage = _alternateImage;
@synthesize isHighlighted = _isHighlighted;

- (void)mouseDown:(NSEvent *)theEvent
{
    AppDelegate* appDelegate = [[NSApplication sharedApplication] delegate];
    
    if (! [appDelegate menuIsVisible])
        [[appDelegate statusBar] popUpStatusItemMenu:[[appDelegate statusBar] menu]];
}

- (void)toggleIconStatusBar:(BOOL)status
{
    NSLog(@"dfdfdfd");

}

- (void)drawRect:(NSRect)dirtyRect
{
    [_statusItem drawStatusBarBackgroundInRect:NSMakeRect(0,0,22,22) withHighlight:YES];
    [super drawRect:dirtyRect];
    NSLog(@"%f\t%f",dirtyRect.size.width,dirtyRect.origin.y);
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
    return self;
}

- (void)setImage:(NSImage *)newImage
{
    if (_image != newImage) {
        _image = newImage;
        [self setNeedsDisplay:YES];
    }
}

- (void)setAlternateImage:(NSImage *)newImage
{
    if (_alternateImage != newImage) {
        _alternateImage = newImage;
        if (self.isHighlighted) {
            [self setNeedsDisplay:YES];
        }
    }
}

@end
