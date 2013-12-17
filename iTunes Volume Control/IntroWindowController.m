//
//  IntroWindowController.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 15.12.13.
//  Copyright (c) 2013 Andrea Alberti. All rights reserved.
//

#import "IntroWindowController.h"
#import <QuartzCore/CoreAnimation.h>

@interface IntroWindowController ()

@end

@implementation IntroWindowController

@synthesize nextButton;
@synthesize previousButton;
@synthesize text;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.

        [[NSNotificationCenter defaultCenter] addObserver:[[NSApplication sharedApplication] delegate] selector:@selector(introWindowWillClose:) name:NSWindowWillCloseNotification object:window];
        
    }
    return self;
}

- (IBAction)nextButtonClicked:(id)sender
{
    NSLog(@"clicked");
//    CALayer* layer = [nextButton layer];
//    [layer setOpacity:0];
    
    
    CABasicAnimation* fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeOutAnimation setDuration:1.f];
    [fadeOutAnimation setRemovedOnCompletion:NO];
    [fadeOutAnimation setFillMode:kCAFillModeForwards];
    [fadeOutAnimation setFromValue:[NSNumber numberWithFloat:1.0f]];
    [fadeOutAnimation setToValue:[NSNumber numberWithFloat:0.0f]];
    
    [[NSAnimationContext currentContext] setDuration:4.0];
    [NSAnimationContext beginGrouping];
    [introLayer addAnimation:fadeOutAnimation forKey:@"decreaseOpacity"];
    [[text animator] setAlphaValue:0.f];
    [NSAnimationContext endGrouping];
    
}

-(void)awakeFromNib
{
    NSImage *iTunesScreenshot=[NSImage imageNamed:@"iTunes-screenshot"];
    NSRect imageRect = NSZeroRect;
    imageRect.size = [iTunesScreenshot size];
    
//    [introImage setImage:iTunesScreenshot];
//    [introImage setImageFrameStyle:NSImageFrameNone];
//    [introImage setFrame:NSMakeRect(0,0,827,505)];

//    NSSize introImageSize = [introImage frame].size;
//
    NSWindow* introWindow = [self window];
    
    CALayer* toplayer = [CALayer layer];
//    CGColorRef backgroundColor=CGColorCreateGenericRGB(1.f, 1.f, 1.f, 1.f);
//    [toplayer setBackgroundColor:backgroundColor];
//    CFRelease(backgroundColor);
    
    introLayer = [CALayer layer];
    [introLayer setFrame:NSRectToCGRect(imageRect)];
    [introLayer setPosition:CGPointMake(introWindow.frame.size.width/2,introWindow.frame.size.height-imageRect.size.height/2-30)];
    [introLayer setContents:iTunesScreenshot];
//    [introLayer setBorderColor:CGColorCreateGenericRGB(1.f, 0.f, 0.f, 1.f)];
//    [introLayer setBorderWidth:1];

    [toplayer addSublayer:introLayer];
    
    [[introWindow contentView] setLayer:toplayer];
    [[introWindow contentView] setWantsLayer:YES];

//
//    CALayer* toplayer = [CALayer layer];
//    [toplayer addSublayer:introLayer];
//    [introImage setLayer:toplayer];
//    [introImage setWantsLayer:YES];
//
//    
    NSImage *nextButtonImage=[NSImage imageNamed:@"introButtons-next"];
    NSImage *nextButtonImageHL=[NSImage imageNamed:@"introButtons-next-HL"];

    [nextButton setImage: nextButtonImage];
    [nextButton setAlternateImage: nextButtonImageHL];
    [nextButton setBordered:NO];
    [[nextButton cell] setHighlightsBy:1];

}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
