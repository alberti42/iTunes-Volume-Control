//
//  IconController.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 28.12.14.
//  Copyright (c) 2014 Andrea Alberti. All rights reserved.
//

#import "IconController.h"
#import "IconModel.h"

@implementation IconController

@synthesize icons = _icons;

-(void) awakeFromNib {
    
    IconModel* itunes = [[IconModel alloc] init];
    itunes.nameProgram = @"iTunes";
    itunes.iconImage = [NSImage imageNamed:@"iTunes12Big"];

    IconModel* spotify = [[IconModel alloc] init];
    spotify.nameProgram = @"Spotify";
    spotify.iconImage = [NSImage imageNamed:@"spotifyBig"];

    
    _icons = [[NSMutableArray alloc] init];
    [arrayController addObject:itunes];
    [arrayController addObject:spotify];

}

@end
