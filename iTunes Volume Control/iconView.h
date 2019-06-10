//
//  iconView.h
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 28.12.14.
//  Copyright (c) 2014 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface iconView : NSView {
    BOOL selected;
}

@property (readwrite) BOOL selected;

@property (assign, nonatomic) NSImage* iconImage;

@end
