//
//  AppDelegate.h
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 25.12.12.
//  Copyright (c) 2012 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    iTunesApplication *iTunes;
}

- (IBAction)reduceVolMenuAction:(id)sender;
- (IBAction)increaseVolMenuAction:(id)sender;
- (void)changeVol:(int)vol;

//@property (assign) IBOutlet NSWindow *window;

@end


