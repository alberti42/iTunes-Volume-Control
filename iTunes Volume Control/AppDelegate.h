//
//  AppDelegate.h
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 25.12.12.
//  Copyright (c) 2012 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"
#import "AppleRemote.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    iTunesApplication *iTunes;
    CFMachPortRef eventTap;
    CFRunLoopSourceRef runLoopSource;
    NSImage *statusImageOn;
    NSImage *statusImageOff;
    AppleRemote* remote;
}

- (IBAction)reduceVolMenuAction:(id)sender;
- (IBAction)increaseVolMenuAction:(id)sender;
- (IBAction)toggleTapStatus:(id)sender;
- (IBAction)aboutPanel:(id)sender;

- (void)changeVol:(int)vol;

//@property (assign) IBOutlet NSWindow *window;

@end


