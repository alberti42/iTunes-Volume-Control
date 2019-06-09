//
//  AccessibilityDialog.h
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 09.06.19.
//  Copyright © 2019 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AccessibilityDialog : NSWindowController
{
    NSTimer* checkAuthorizationTimer;
    
@public
    
    BOOL authorized;
}

@property (nonatomic, assign) IBOutlet NSButton* exitBtn;
@property (nonatomic, assign) IBOutlet NSButton* openSecurityPrivacyBtn;

- (IBAction)onExitButton:(id)sender;
- (IBAction)onOpenSecurityPrivacy:(id)sender;

@end


NS_ASSUME_NONNULL_END
