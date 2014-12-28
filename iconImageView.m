//
//  iconImageView.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 28.12.14.
//  Copyright (c) 2014 Andrea Alberti. All rights reserved.
//

#import "iconImageView.h"

@implementation iconImageView

- (void)drawRect:(NSRect)dirtyRect {
    
    [[NSColor clearColor] setFill];
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];

    
    // Drawing code here.
}

@end
