//
//  AccessibilityDialog.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 09.06.19.
//  Copyright © 2019 Andrea Alberti. All rights reserved.
//

#import "AccessibilityDialog.h"

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
}

-(void)awakeFromNib
{
    [openSecurityPrivacyBtn setBezelStyle:NSBezelStyleRounded];
    [exitBtn setBezelStyle:NSBezelStyleRounded];

    [[self window] setDefaultButtonCell:[openSecurityPrivacyBtn cell]];
    
}


@end
