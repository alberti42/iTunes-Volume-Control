//
//  StatusItemView.h
//  iTunes Volume Control
//
//  Created by Thomas Heß on 23.7.13.
//  Copyright (c) 2013 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatusItemView : NSImageView{
    
@private

}

@property (nonatomic, strong, readonly) NSStatusItem *statusItem;

@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSImage *alternateImage;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;

- (void)toggleIconStatusBar:(BOOL)status;

- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@end
