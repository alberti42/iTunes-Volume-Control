//
//  musicPlayersView.h
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 29.12.14.
//  Copyright (c) 2014 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iconView.h"

@interface musicPlayersView : NSView

@property (assign,nonatomic) IBOutlet iconView* iTunesView;
@property (assign,nonatomic) IBOutlet iconView* spotifyView;

@end
