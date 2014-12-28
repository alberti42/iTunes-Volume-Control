//
//  iconView.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 28.12.14.
//  Copyright (c) 2014 Andrea Alberti. All rights reserved.
//

#import "iconView.h"

@implementation iconView

@synthesize iconImage = _iconImage;
@synthesize selected;

-(id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

+(void)initialize
{
    [self exposeBinding: @"iconImage"];
}

// Use a custom setter, because presumably, the view needs to re-draw
- (void)setIconImage:(NSImage*)iconImage{
    [self willChangeValueForKey:@"iconImage"];
    // Based on automatic garbage collection
    _iconImage = iconImage;
    [self didChangeValueForKey:@"iconImage"];
    
    [self setNeedsDisplayInRect:[self visibleRect]];
}


-(void)drawRect:(NSRect)dirtyRect
{
    if (selected)
    {
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect: NSMakeRect(0.5, 0.5, dirtyRect.size.width - 1, dirtyRect.size.height - 1) xRadius:5 yRadius:5];
    
        [[NSColor controlHighlightColor] set];
        [path stroke];
        [[NSColor controlHighlightColor] set];
        [path fill];
    }
    else
    {
//        [self setBorderColor:[NSColor controlBackgroundColor]];
//        [self setFillColor:[NSColor controlBackgroundColor]];
//        [self setBorderType:NSNoBorder];
    }

    [[self iconImage] drawAtPoint:NSMakePoint((dirtyRect.size.width-[self iconImage].size.width)/2,dirtyRect.size.height/2-5) fromRect:dirtyRect operation:NSCompositeSourceOver fraction:1];

    [super drawRect:dirtyRect];

}

@end