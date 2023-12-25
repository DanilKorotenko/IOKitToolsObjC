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

- (NSString *)description
{
    NSDictionary *descriptionDictopnary =
        @{
            @"name": self.name == nil ? @"<null>" : self.name,
            @"location": self.location == nil ? @"<null>" : self.location
        };
    return [descriptionDictopnary description];
}

#pragma mark -

- (NSString *)name
{
    if (nil == name)
    {
        io_name_t              ioName;           // (don't release)

        kern_return_t status = IORegistryEntryGetNameInPlane(_entry, [self.options.plane UTF8String], ioName);
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
        kern_return_t  status = IORegistryEntryGetLocationInPlane(_entry, [self.options.plane UTF8String], ioLocation);
        if (status == KERN_SUCCESS)
        {
            location = [NSString stringWithUTF8String:ioLocation];
        }
    }
    return location;
}

#pragma mark -

- (void)scan
{
    [self show];

    io_registry_entry_t child       = 0; // (needs release)
    io_registry_entry_t childUpNext = 0; // (don't release)
    io_iterator_t       children    = 0; // (needs release)
    kern_return_t       status      = KERN_SUCCESS;

    // Obtain the service's children.

    status = IORegistryEntryGetChildIterator(_entry, [self.options.plane UTF8String], &children);
    if (status == KERN_SUCCESS)
    {
        childUpNext = IOIteratorNext(children);

        // Save has-more-siblings state into stackOfBits for this depth.

//        if (serviceHasMoreSiblings)
//        {
//            stackOfBits |=  (1 << serviceDepth);
//        }
//        else
//        {
//            stackOfBits &= ~(1 << serviceDepth);
//        }

        // Save has-children state into stackOfBits for this depth.

//        if (options.depth == 0 || options.depth > serviceDepth + 1)
//        {
//            if (childUpNext)
//            {
//                stackOfBits |=  (2 << serviceDepth);
//            }
//            else
//            {
//                stackOfBits &= ~(2 << serviceDepth);
//            }
//        }

        // Print out the relevant service information.

//        show(service, serviceDepth, stackOfBits, options);

        // Traverse over the children of this service.

//        if (options.depth == 0 || options.depth > serviceDepth + 1)
//        {
//            while (childUpNext)
//            {
//                child       = childUpNext;
//                childUpNext = IOIteratorNext(children);
//
//                scan( /* service                */ child,
//                      /* serviceHasMoreSiblings */ (childUpNext) ? TRUE : FALSE,
//                      /* serviceDepth           */ serviceDepth + 1,
//                      /* stackOfBits            */ stackOfBits,
//                      /* options                */ options );
//
//                IOObjectRelease(child);
//            }
//        }
//
//        IOObjectRelease(children);
    }
}

- (void)show
{
    io_name_t              class;          // (don't release)
//    struct context         context    = { service, serviceDepth, stackOfBits, options };
    uint32_t               integer    = 0;
    uint32_t               state      = 0;
    uint64_t               accumulated_busy_time = 0;
    CFMutableDictionaryRef properties = 0; // (needs release)
    kern_return_t          status     = KERN_SUCCESS;

    // Print out the name of the service.

    NSLog(@"%@", self.description);

//    // Print out the class of the service.
//
//    print("  <class ");
//
//    if (options.inheritance)
//    {
//        CFStringRef classCFStr;
//        CFStringRef ancestryCFStr;
//        char *      aCStr;
//
////        classCFStr = _IOObjectCopyClass (service, kIOClassNameOverrideNone);
//        classCFStr = IOObjectCopyClass (service);
//        if (classCFStr) {
//            ancestryCFStr = createInheritanceStringForIORegistryClassName (classCFStr);
//            if (ancestryCFStr) {
//                aCStr = (char *) CFStringGetCStringPtr (ancestryCFStr, kCFStringEncodingUTF8);
//                if (NULL != aCStr)
//                {
//                    print("%s", aCStr);
//                }
//                CFRelease (ancestryCFStr);
//            }
//            CFRelease (classCFStr);
//        }
//    }
//    else
//    {
////        status = _IOObjectGetClass(service, kIOClassNameOverrideNone, class);
//        status = IOObjectGetClass(service, class);
//        assertion(status == KERN_SUCCESS, "can't obtain class", strcpy(class, "<class error>"));
//
//        print("%s", class);
//    }
//
//    // Prepare to print out the service's useful debug information.
//
//    uint64_t entryID;
//
//    status = IORegistryEntryGetRegistryEntryID(service, &entryID);
//    if (status == KERN_SUCCESS)
//    {
//        print(", id 0x%llx", entryID);
//    }
//
//    // Print out the busy state of the service (for IOService objects).
//
////    if (_IOObjectConformsTo(service, "IOService", kIOClassNameOverrideNone))
//    if (IOObjectConformsTo(service, "IOService"))
//    {
////        status = IOServiceGetBusyStateAndTime(service, &state, &integer, &accumulated_busy_time);
//        status = IOServiceGetBusyState(service, &state);
//        assertion(status == KERN_SUCCESS, "can't obtain state", accumulated_busy_time = integer = state = 0);
//
////        print( ", %sregistered, %smatched, %sactive",
////               state & kIOServiceRegisteredState ? "" : "!",
////               state & kIOServiceMatchedState    ? "" : "!",
////               state & kIOServiceInactiveState   ? "in" : "" );
//
//        print( ", %sregistered, %smatched, %sactive",
//               state & 1 ? "" : "!",
//               state & 1    ? "" : "!",
//               state & 1   ? "in" : "" );
//
//        print(", busy %ld", 
//        (unsigned long)integer);
//
//        if (accumulated_busy_time)
//        {
//            print(" (%lld ms)", 
//            accumulated_busy_time / kMillisecondScale);
//        }
//    }
//
//    // Print out the retain count of the service.
//
//    integer = IOObjectGetKernelRetainCount(service);
//
//    print(", retain %ld", (unsigned long)integer);
//
//    println(">");
//
//    // Determine whether the service is a match.
//
//    if (options.list || compare(service, options))
//    {
//        indent(FALSE, serviceDepth, stackOfBits);
//        println("{");
//
//        // Obtain the service's properties.
//
//        status = IORegistryEntryCreateCFProperties( service,
//                                                    &properties,
//                                                    kCFAllocatorDefault,
//                                                    kNilOptions );
//        assertion(status == KERN_SUCCESS, "can't obtain properties", properties = NULL);
//
//        if (!properties)
//        {
//            properties = CFDictionaryCreateMutable( kCFAllocatorDefault,
//                                                    0,
//                                                    &kCFTypeDictionaryKeyCallBacks,
//                                                    &kCFTypeDictionaryValueCallBacks );
//            assertion_fatal(properties != NULL, "can't create dictionary");
//        }
//
//        // Print out the service's properties.
//
//        CFDictionaryApplyFunction(properties, showitem, &context);
//
//        indent(FALSE, serviceDepth, stackOfBits);
//        println("}");
//        indent(FALSE, serviceDepth, stackOfBits);
//        println("");
//
//        // Release resources.
//
//        CFRelease(properties);
//    }
}

@end
