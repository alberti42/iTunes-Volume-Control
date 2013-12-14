#import "IntroWindow.h"

@implementation IntroWindow

- (id) initWithContentRect: (NSRect) contentRect
                 styleMask: (unsigned long) aStyle
                   backing: (NSBackingStoreType) bufferingType
                     defer: (BOOL) flag
{
    self = [super initWithContentRect: contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag];
    if (!self) return nil;
    [self setBackgroundColor: [NSColor blueColor]];
    [self setOpaque:YES];
    [self makeKeyAndOrderFront:nil];
    
    
    [self setBackgroundColor: [NSColor clearColor]];
    [self setAlphaValue:1.0];
    [self setOpaque:NO];
    [self setHasShadow:YES];
    [self setMovableByWindowBackground:YES];
//    [self setBackgroundColor:[self sizedHUDBackground]];
    
//    [self addCloseWidget];
    
    
    return self;
}

@end
