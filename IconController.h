//
//  IconController.h
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 28.12.14.
//  Copyright (c) 2014 Andrea Alberti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IconController : NSObject
{
    IBOutlet NSArrayController* arrayController;
}

@property (strong) NSMutableArray* icons;

@end
