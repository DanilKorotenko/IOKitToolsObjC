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

@synthesize name;
@synthesize location;
@synthesize className;
@synthesize children;
@synthesize properties;

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

        self.plane = @kIOServicePlane;

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

- (NSString *)description
{
    NSDictionary *descriptionDictopnary =
        @{
            @"name": self.name == nil ? @"<null>" : self.name,
            @"location": self.location == nil ? @"<null>" : self.location,
            @"className": self.className == nil ? @"<null>" : self.className,
            @"children": self.children,
            @"properties": self.properties
        };
    return [descriptionDictopnary description];
}

#pragma mark -

- (NSString *)name
{
    if (nil == name)
    {
        io_name_t              ioName;           // (don't release)

        kern_return_t status = IORegistryEntryGetNameInPlane(_entry, [self.plane UTF8String], ioName);
        if (status == KERN_SUCCESS)
        {
            name = [NSString stringWithUTF8String:ioName];
        }
    }
    return name;
}

- (NSString *)location
{
    if (nil == location)
    {
        io_name_t              ioLocation;           // (don't release)
        kern_return_t  status = IORegistryEntryGetLocationInPlane(_entry, [self.plane UTF8String], ioLocation);
        if (status == KERN_SUCCESS)
        {
            location = [NSString stringWithUTF8String:ioLocation];
        }
    }
    return location;
}

- (NSString *)className
{
    if (nil == className)
    {
        io_name_t class;          // (don't release)
        kern_return_t status = IOObjectGetClass(_entry, class);
        if (status == KERN_SUCCESS)
        {
            className = [NSString stringWithUTF8String:class];
        }
    }
    return className;
}

- (NSArray *)children
{
    if (nil == children)
    {
        children = [self scan];
    }
    return children;
}

- (NSDictionary *)properties
{
    if (nil == properties)
    {
        CFMutableDictionaryRef propertiesRef = NULL; // (needs release)

        kern_return_t status = IORegistryEntryCreateCFProperties(
            _entry, &propertiesRef, kCFAllocatorDefault, kNilOptions );
        if (status == KERN_SUCCESS && propertiesRef != NULL)
        {
            properties = CFBridgingRelease(propertiesRef);
        }
    }
    return properties;
}

#pragma mark -

- (NSArray *)scan
{
    NSMutableArray *result = [NSMutableArray array];

    // Obtain the service's children.
    io_iterator_t       children    = 0; // (needs release)
    kern_return_t status = IORegistryEntryGetChildIterator(_entry, [self.plane UTF8String], &children);

    if (status == KERN_SUCCESS)
    {
        io_registry_entry_t childUpNext = 0; // (don't release)
        childUpNext = IOIteratorNext(children);

        while (childUpNext)
        {
            io_registry_entry_t child = childUpNext;
            IORegistryInfo *ch = [[IORegistryInfo alloc] initWithEntry:child];
            [result addObject:ch];
            childUpNext = IOIteratorNext(children);
            IOObjectRelease(child);
        }

        IOObjectRelease(children);
    }

    return result;
}

@end
