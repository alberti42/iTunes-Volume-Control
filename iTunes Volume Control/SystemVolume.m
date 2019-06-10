//
//  AppDelegate.m
//  iTunes Volume Control
//
//  Created by Andrea Alberti on 25.12.12.
//  Copyright (c) 2012 Andrea Alberti. All rights reserved.
//

#import <Carbon/Carbon.h>

#import "SystemVolume.h"

@implementation SystemApplication

@synthesize currentVolume = _currentVolume;
@synthesize doubleVolume = _doubleVolume;

- (void) setCurrentVolume:(double)currentVolume
{
    [self setDoubleVolume:currentVolume];
    
    NSAppleEventDescriptor* AEsetVolumeParams = [NSAppleEventDescriptor listDescriptor];
    [AEsetVolumeParams insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:(int)currentVolume] atIndex:1];
    [AEsetVolume setParamDescriptor:AEsetVolumeParams forKeyword:keyDirectObject];
    
    NSDictionary *error = nil;
    NSAppleEventDescriptor *resultEventDescriptor = [ASSystemVolume executeAppleEvent:AEsetVolume error:&error];
    if (! resultEventDescriptor) {
        NSLog(@"%s AppleScript setVolume error = %@", __PRETTY_FUNCTION__, error);
    }
    
}

- (double) currentVolume
{
    double vol = 0;
    
    NSAppleEventDescriptor* AEsetVolumeParams = [NSAppleEventDescriptor listDescriptor];
    [AEsetVolume setParamDescriptor:AEsetVolumeParams forKeyword:keyDirectObject];
    
    NSDictionary *error = nil;
    NSAppleEventDescriptor *resultEventDescriptor = [ASSystemVolume executeAppleEvent:AEgetVolume error:&error];
    if (! resultEventDescriptor) {
        NSLog(@"%s AppleScript getVolume error = %@", __PRETTY_FUNCTION__, error);
    }
    else {
        if ([resultEventDescriptor descriptorType] == cLongInteger) {
            vol = (double)[resultEventDescriptor int32Value];
        }
        else
        {
            NSLog(@"%s AppleScript getVolume error = Return argument has wrong type", __PRETTY_FUNCTION__);
        }
    }
    
    if (fabs(vol-[self doubleVolume])<1)
    {
        vol = [self doubleVolume];
    }
    
    return vol;
}

-(void)dealloc
{
    ASSystemVolume = nil;
    AEsetVolume = nil;
    AEgetVolume = nil;
}

-(id)init {
    if (self = [super init])  {
        [self setOldVolume: -1];
        
        NSURL *URL = [[NSBundle mainBundle] URLForResource:@"SystemVolume" withExtension:@"scpt"];
        if (URL) {
            ASSystemVolume = [[NSAppleScript alloc] initWithContentsOfURL:URL error:NULL];
            
            // target
            ProcessSerialNumber psn = {0, kCurrentProcess};
            NSAppleEventDescriptor *target = [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber bytes:&psn length:sizeof(ProcessSerialNumber)];
            
            // functions
            NSAppleEventDescriptor *setVolumeHandler = [NSAppleEventDescriptor descriptorWithString:@"setVolume"];
            NSAppleEventDescriptor *getVolumeHandler = [NSAppleEventDescriptor descriptorWithString:@"getVolume"];
            
            // events
            AEsetVolume = [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite eventID:kASSubroutineEvent targetDescriptor:target returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];
            [AEsetVolume setParamDescriptor:setVolumeHandler forKeyword:keyASSubroutineName];

            AEgetVolume = [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite eventID:kASSubroutineEvent targetDescriptor:target returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];
            [AEgetVolume setParamDescriptor:getVolumeHandler forKeyword:keyASSubroutineName];
        }
    }
    return self;
}

@end
