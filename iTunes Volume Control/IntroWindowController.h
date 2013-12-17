//
//  IntroWindowController.h
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 15.12.13.
//  Copyright (c) 2013 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IntroWindowController : NSWindowController
{
    CALayer* introLayer;
    
@public
}

@property (nonatomic,assign) IBOutlet NSButton *nextButton;
@property (nonatomic,assign) IBOutlet NSButton *previousButton;

- (IBAction)nextButtonClicked:(id)sender;

@end
