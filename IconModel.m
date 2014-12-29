//
//  IconModel.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 28.12.14.
//  Copyright (c) 2014 Andrea Alberti. All rights reserved.
//

#import "IconModel.h"

@implementation IconModel

@synthesize nameProgram = _nameProgram;
@synthesize iconImage = _iconImage;
@synthesize selected = _selected;

- (id)init{
    
    self = [super init];
    
    if(self)
    {
        _selected = false;
    }
    
    return self;
}

@end
