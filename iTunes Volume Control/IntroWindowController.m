//
//  IntroWindowController.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 15.12.13.
//  Copyright (c) 2013 Andrea Alberti. All rights reserved.
//

#import "IntroWindowController.h"
#import <QuartzCore/CoreAnimation.h>
#import "AppDelegate.h"

@interface IntroWindowController ()

@end

@implementation IntroWindowController

@synthesize nextButton;
@synthesize previousButton;
@synthesize iTune_label_1;
@synthesize iTune_label_2;
@synthesize loadIntroAtStartButton;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        
        [[NSNotificationCenter defaultCenter] addObserver:[[NSApplication sharedApplication] delegate] selector:@selector(introWindowWillClose:) name:NSWindowWillCloseNotification object:window];
        
    }
    return self;
}

- (IBAction)loadIntroAtStartChanged:(id)sender
{
    [[self appDelegate] setLoadIntroAtStart:[loadIntroAtStartButton state]];
}

- (IBAction)nextButtonClicked:(id)sender
{
    
    static int step_number = 0;
    //    CABasicAnimation* fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    //    [fadeOutAnimation setDuration:1.f];
    //    [fadeOutAnimation setRemovedOnCompletion:NO];
    //    [fadeOutAnimation setFillMode:kCAFillModeForwards];
    //    [fadeOutAnimation setFromValue:[NSNumber numberWithFloat:1.0f]];
    //    [fadeOutAnimation setToValue:[NSNumber numberWithFloat:0.0f]];
    
    switch (step_number)
    {
        case 0:
            
            [previousButton setEnabled:YES];
            
            [[NSAnimationContext currentContext] setDuration:1.3f];
            [NSAnimationContext beginGrouping];
            //    [introLayer addAnimation:fadeOutAnimation forKey:@"decreaseOpacity"];
            [[iTune_label_2 animator] setAlphaValue:1.f];
            [arrow_2_Layer setOpacity:1.f];
            [NSAnimationContext endGrouping];
            
            
            break;
        case 1:
            break;
    }
    
    step_number++;
    
}

-(void)showFirstMessage:(NSTimer*)theTimer
{
    [[NSAnimationContext currentContext] setDuration:1.3f];
    [NSAnimationContext beginGrouping];
    [[iTune_label_1 animator] setAlphaValue:1.f];
    [arrow_1_Layer setOpacity:1.f];
    [NSAnimationContext endGrouping];
}

-(void)awakeFromNib
{
    NSWindow* introWindow = [self window];
    NSView* introContentView = [introWindow contentView];
    
    CGSize windowViewSize = [introContentView frame].size;
    
    NSRect imageRect = NSZeroRect;
    
    NSImage *iTunesScreenshot=[NSImage imageNamed:@"iTunes-screenshot"];
    NSImage *iTunes_arrow_1=[NSImage imageNamed:@"iTunes-arrow-1"];
    NSImage *iTunes_arrow_2=[NSImage imageNamed:@"iTunes-arrow-2"];
    
    //[introWindow setContentBorderThickness:36 forEdge:NSMinYEdge];
    
    CALayer* toplayer = [CALayer layer];
    //CGColorRef backgroundColor=CGColorCreateGenericRGB(1.f, 1.f, 1.f, 1.f);
    //[toplayer setBackgroundColor:backgroundColor];
    //CFRelease(backgroundColor);
    
    introLayer = [CALayer layer];
    imageRect.size = [iTunesScreenshot size];
    [introLayer setFrame:NSRectToCGRect(imageRect)];
    [introLayer setPosition:CGPointMake(windowViewSize.width/2-16,windowViewSize.height-imageRect.size.height/2-60)];
    [introLayer setContents:iTunesScreenshot];
    //[introLayer setBorderColor:CGColorCreateGenericRGB(1.f, 0.f, 0.f, 1.f)];
    //[introLayer setBorderWidth:1];
    [toplayer addSublayer:introLayer];
    
    arrow_1_Layer = [CALayer layer];
    imageRect.size = [iTunes_arrow_1 size];
    [arrow_1_Layer setFrame:NSRectToCGRect(imageRect)];
    [arrow_1_Layer setPosition:CGPointMake(312,windowViewSize.height-95)];
    [arrow_1_Layer setContents:iTunes_arrow_1];
    [arrow_1_Layer setOpacity:0.f];
    [toplayer addSublayer:arrow_1_Layer];
    
    [iTune_label_1 setAlphaValue:0.f];
    
    arrow_2_Layer = [CALayer layer];
    imageRect.size = [iTunes_arrow_2 size];
    [arrow_2_Layer setFrame:NSRectToCGRect(imageRect)];
    [arrow_2_Layer setPosition:CGPointMake(242,windowViewSize.height-96)];
    [arrow_2_Layer setContents:iTunes_arrow_2];
    [arrow_2_Layer setOpacity:0.f];
    [toplayer addSublayer:arrow_2_Layer];
    
    [iTune_label_2 setAlphaValue:0.f];
    
    [introContentView setLayer:toplayer];
    [introContentView setWantsLayer:YES];
    
    NSImage *nextButtonImage=[NSImage imageNamed:@"introButtons-next"];
    NSImage *nextButtonImageHL=[NSImage imageNamed:@"introButtons-next-HL"];
    [nextButton setImage: nextButtonImage];
    [nextButton setAlternateImage: nextButtonImageHL];
    [nextButton setBordered:NO];
    [[nextButton cell] setHighlightsBy:1];
    
    NSImage *prevButtonImage=[NSImage imageNamed:@"introButtons-prev"];
    NSImage *prevButtonImageHL=[NSImage imageNamed:@"introButtons-prev-HL"];
    [previousButton setImage: prevButtonImage];
    [previousButton setAlternateImage: prevButtonImageHL];
    [previousButton setBordered:NO];
    [previousButton setEnabled:NO];
    [[previousButton cell] setHighlightsBy:1];
    
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(showFirstMessage:) userInfo:nil repeats:NO];

    [loadIntroAtStartButton setState: [[self appDelegate] loadIntroAtStart]];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
