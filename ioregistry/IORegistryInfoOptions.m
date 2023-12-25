//
//  IORegistryInfoOptions.m
//  ioregistry
//
//  Created by Danil Korotenko on 12/25/23.
//

#import "IORegistryInfoOptions.h"

@implementation IORegistryInfoOptions

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.archive       = NO;
        self.bold          = NO;
        self.format        = NO;
        self.hex           = NO;
        self.inheritance   = NO;
        self.list          = NO;
        self.root          = NO;
        self.tree          = NO;
        self.nouserclasses = NO;

        self.classStr = nil;
        self.depth = 0;
        self.key   = nil;
        self.name  = nil;
        self.plane = @kIOServicePlane;
        self.width = 0;
    }
    return self;
}

@end
