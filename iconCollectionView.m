//
//  iconCollectionView.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 28.12.14.
//  Copyright (c) 2014 Andrea Alberti. All rights reserved.
//

#import "iconCollectionView.h"
#import "iconView.h"
#import "IconModel.h"

@implementation iconCollectionView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.

}

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object
{
    NSCollectionViewItem *newItem = [super newItemForRepresentedObject:object];
    
    [newItem setSelected: [(IconModel*)newItem.representedObject selected]];
    
    [(iconView*)[newItem view] bind:@"iconImage" toObject:newItem withKeyPath:@"representedObject.iconImage" options: nil];
    
    return newItem;
}

@end
