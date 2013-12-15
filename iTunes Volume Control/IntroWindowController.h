//
//  IntroWindowController.h
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 15.12.13.
//  Copyright (c) 2013 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IntroWindowController : NSWindowController
{
    NSImage *iTunesScreenshot;
    
@public
}

@property (nonatomic) IBOutlet NSImageView *IntroImage;

@end
