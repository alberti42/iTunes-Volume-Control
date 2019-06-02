#import "VolumeWindow.h"

@implementation VolumeWindow

- (id) initWithContentRect: (NSRect) contentRect
                 styleMask: (NSWindowStyleMask) aStyle
                   backing: (NSBackingStoreType) bufferingType
                     defer: (BOOL) flag
{
    self = [super initWithContentRect: contentRect styleMask: NSWindowStyleMaskBorderless backing: bufferingType defer: flag];
    if (!self) return nil;
    
    [self setOpaque:NO];
    [self setBackgroundColor: [NSColor clearColor]];
    [self setHasShadow:NO];
    [self orderOut:nil];
    [self setAlphaValue:1];
    
    return self;
}

//-(void)awakeFromNib
//{

//
//    [self setStyleMask:self.styleMask | NSFullSizeContentViewWindowMask];
//    [self setTitlebarAppearsTransparent:true];
    

    
//    NSVisualEffectView* visualEffectView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, 300, 180)];
//    visualEffectView.material =  NSVisualEffectMaterialLight;
//    visualEffectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
//    visualEffectView.state = NSVisualEffectStateActive;
//    
//    [self  setStyleMask:self.styleMask | NSFullSizeContentViewWindowMask];
//    [self setTitlebarAppearsTransparent:true];
//    //self.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
//    
//    [[self contentView] addSubview:visualEffectView];

//    [[self contentView] addConstraints:(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[visualEffectView]-0-|", views: ["visualEffectView":visualEffectView]))];
//     self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[visualEffectView]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["visualEffectView":visualEffectView]))
//}


@end
