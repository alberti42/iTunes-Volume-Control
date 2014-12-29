//
//  IconModel.h
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 28.12.14.
//  Copyright (c) 2014 Andrea Alberti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IconModel : NSObject

@property (strong) NSString* nameProgram;
@property (strong) NSImage* iconImage;
@property (assign, nonatomic) BOOL selected;

@end
