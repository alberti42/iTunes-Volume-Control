//
//  iconCollectionViewItem.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 28.12.14.
//  Copyright (c) 2014 Andrea Alberti. All rights reserved.
//

#import "iconCollectionViewItem.h"
#import "iconView.h"

@interface iconCollectionViewItem ()

@end

@implementation iconCollectionViewItem


-(void)setSelected:(BOOL)flag
{
    [super setSelected:	flag];
    
    [(iconView*)[self view] setSelected:flag];
    [(iconView*)[self view] setNeedsDisplay:YES];
    
}

-(void) dealloc
{
    [self unbind:@"iconImage"];
}

@end
