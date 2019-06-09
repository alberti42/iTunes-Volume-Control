//
//  AccessibilityDialog.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 09.06.19.
//  Copyright © 2019 Andrea Alberti. All rights reserved.
//

#import "AccessibilityDialog.h"
#import "AppDelegate.h"

@interface AccessibilityDialog ()

@end

@implementation AccessibilityDialog

@synthesize openSecurityPrivacyBtn;
@synthesize exitBtn;

- (IBAction)onExitButton:(id)sender
{
    [NSApp terminate:nil];
}

- (IBAction)onOpenSecurityPrivacy:(id)sender
{
    NSString *urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility";
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [openSecurityPrivacyBtn setBezelStyle:NSBezelStyleRounded];
    [exitBtn setBezelStyle:NSBezelStyleRounded];
    
    [[self window] setDefaultButtonCell:[openSecurityPrivacyBtn cell]];

}

- (void)checkAuthorization:(NSTimer*)aTimer
{
    extern CFStringRef kAXTrustedCheckOptionPrompt __attribute__((weak_import));
    
    authorized = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)@{(__bridge id)kAXTrustedCheckOptionPrompt: @NO});
    
    if(authorized)
    {
        [aTimer invalidate];
        aTimer = nil;
        
        [(AppDelegate*)[NSApp delegate] wasAuthorized];
    }
}

- (IBAction)showWindow:(id)sender
{
    [super showWindow:sender];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[self window] makeKeyAndOrderFront:sender];
    
    checkAuthorizationTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(checkAuthorization:) userInfo:nil repeats:YES];
}

-(id) init
{
    if (self = [super init])  {
        self->authorized = false;
    }
    return self;
}



@end
