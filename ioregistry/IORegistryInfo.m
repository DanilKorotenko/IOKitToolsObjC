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

+ (instancetype)createWithRootEntry
{
    io_registry_entry_t service = IORegistryGetRootEntry(kIOMainPortDefault);
    IORegistryInfo *result = nil;
    if (service != MACH_PORT_NULL)
    {
        result = [[IORegistryInfo alloc] initWithEntry:service];
        IOObjectRelease(service);
    }
    return result;
}


- (instancetype)initWithEntry:(io_registry_entry_t)anEntry
{
    self = [super init];
    if (self)
    {
        if (anEntry == MACH_PORT_NULL)
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
    if (_entry != MACH_PORT_NULL)
    {
        IOObjectRelease(_entry);
    }
}

@end
