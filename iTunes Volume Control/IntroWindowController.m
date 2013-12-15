//
//  IntroWindowController.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 15.12.13.
//  Copyright (c) 2013 Andrea Alberti. All rights reserved.
//

#import "IntroWindowController.h"

@interface IntroWindowController ()

@end

@implementation IntroWindowController

@synthesize IntroImage;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.

        [[NSNotificationCenter defaultCenter] addObserver:[[NSApplication sharedApplication] delegate] selector:@selector(introWindowWillClose:) name:NSWindowWillCloseNotification object:window];
        
    }
    return self;
}

-(void)awakeFromNib
{
    iTunesScreenshot=[NSImage imageNamed:@"iTunes-screenshot.png"];
    NSRect rect = NSZeroRect;
    rect.size = [iTunesScreenshot size];
    
    [IntroImage setImage:iTunesScreenshot];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
