//
//  StatusItemView.m
//  iTunes Volume Control
//
//  Created by Thomas Heß on 23.7.13.
//  Copyright (c) 2013 Andrea Alberti. All rights reserved.
//

#import "StatusItemView.h"
#import "AppDelegate.h"

#define appDelegate ((AppDelegate*)([[NSApplication sharedApplication] delegate]))

@implementation StatusItemView

- (void)mouseDown:(NSEvent *)theEvent
{
    if (! [appDelegate menuIsVisible])
        [[appDelegate statusBar] popUpStatusItemMenu:[[appDelegate statusBar] menu]];
}

@end
