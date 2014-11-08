#import "VolumeView.h"

@implementation VolumeView


//- (void)drawRect:(NSRect)rect
//{
//    [[NSColor clearColor] set];
//    NSRectFill(self.frame);
//    
//    // make a rounded rect and fill it with whatever color you like
//    NSBezierPath* clipPath = [NSBezierPath bezierPathWithRoundedRect:self.frame xRadius:18.0 yRadius:18.0];
//    [[NSColor blackColor] set]; // your bg color
//    [clipPath fill];
//    
//}


-(void)awakeFromNib
{
    [self setMaterial:NSVisualEffectMaterialLight];
    [self setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
    [self setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [self setState:NSVisualEffectStateActive];

    
}

@end
