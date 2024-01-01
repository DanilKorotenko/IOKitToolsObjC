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
        self.tree          = NO;
        self.nouserclasses = NO;

        self.plane = @kIOServicePlane;
    }
    return self;
}

@end
