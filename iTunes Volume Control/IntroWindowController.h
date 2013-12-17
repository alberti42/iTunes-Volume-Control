//
//  IntroWindowController.h
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 15.12.13.
//  Copyright (c) 2013 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppDelegate;

@interface IntroWindowController : NSWindowController
{
    CALayer* introLayer;
    CALayer* arrow_1_Layer;
    CALayer* arrow_2_Layer;
    
@public
}

@property (nonatomic,assign) IBOutlet NSButton *nextButton;
@property (nonatomic,assign) IBOutlet NSButton *previousButton;
@property (nonatomic,assign) IBOutlet NSTextField *iTune_label_1;
@property (nonatomic,assign) IBOutlet NSTextField *iTune_label_2;
@property (nonatomic,assign) IBOutlet NSButton *loadIntroAtStartButton;

@property (nonatomic, weak) AppDelegate *appDelegate;

- (IBAction)nextButtonClicked:(id)sender;
- (IBAction)loadIntroAtStartChanged:(id)sender;

@end
