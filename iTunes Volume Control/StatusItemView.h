//
//  StatusItemView.h
//  iTunes Volume Control
//
//  Created by Thomas Heß on 23.7.13.
//  Copyright (c) 2013 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatusItemView : NSView{
    
    NSImage *statusImageClicked;
    NSImage *statusImageOn;
    NSImage *statusImageOff;
    NSPoint iconPoint;
}

@property (nonatomic, readwrite, assign) BOOL menuIsVisible;

@property (nonatomic, strong, readonly) NSStatusItem *statusItem;

@property (nonatomic, assign) bool iconStatusBarIsGrayed;

@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;

@property (nonatomic, assign) NSImage* image;

- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@end
