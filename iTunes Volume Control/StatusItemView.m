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

- (void)mouseDown:(NSEvent *)theEvent
{
    AppDelegate* appDelegate = [[NSApplication sharedApplication] delegate];
    
    if (! [appDelegate menuIsVisible])
        [[appDelegate statusBar] popUpStatusItemMenu:[[appDelegate statusBar] menu]];
}

@end
