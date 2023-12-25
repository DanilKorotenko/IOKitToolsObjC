//
//  IORegistryInfo.m
//  ioregistry
//
//  Created by Danil Korotenko on 12/25/23.
//

#import "IORegistryInfo.h"

@implementation IORegistryInfo
{
    io_registry_entry_t _entry;
}

- (instancetype)initWithEntry:(io_registry_entry_t)anEntry
{
    self = [super init];
    if (self)
    {
        if (anEntry == 0)
        {
            return nil;
        }

        _entry = anEntry;
        IOObjectRetain(_entry);
    }
    return self;
}

- (void)dealloc
{
    if (_entry != 0)
    {
        IOObjectRelease(_entry);
    }
}

@end
