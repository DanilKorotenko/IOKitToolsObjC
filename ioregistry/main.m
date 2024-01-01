//
//  main.m
//  ioregistry
//
//  Created by Danil Korotenko on 12/24/23.
//

#import <Foundation/Foundation.h>

#include <CoreFoundation/CoreFoundation.h>            // (CFDictionary, ...)
#include <IOKit/IOCFSerialize.h>                      // (IOCFSerialize, ...)
#include <IOKit/IOKitLib.h>                           // (IOMasterPort, ...)
//#include <IOKit/IOKitLibPrivate.h>                    // (IOServiceGetState, ...)
//#include <IOKit/IOKitKeysPrivate.h>                   // (kIOClassNameOverrideNone, ...)
#include <sys/ioctl.h>                                // (TIOCGWINSZ, ...)
#include <term.h>                                     // (tputs, ...)
#include <unistd.h>                                   // (getopt, ...)

#include "IORegistryInfoOptions.h"
#include "IORegistryInfo.h"

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#define assertion_fatal(e, message) ((void) (__builtin_expect(!(e), 0) ? fprintf(stderr, "ioreg: error: %s.\n", message), exit(1) : 0))
#define assertion(e, message, fail) ((void) (__builtin_expect(!(e), 0) ? fprintf(stderr, "ioreg: error: %s.\n", message), (fail) : 0))

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

struct context
{
    io_registry_entry_t service;
    UInt32              serviceDepth;
    UInt64              stackOfBits;
    IORegistryInfoOptions *options;
};

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

static void print(const char * format, ...)  __printflike(1, 2);

static void cfshow(CFTypeRef object);
static void cfarrayshow(CFArrayRef object);
static void cfbooleanshow(CFBooleanRef object);
static void cfdatashow(CFDataRef object);
static void cfdictionaryshow(CFDictionaryRef object);
static void cfnumbershow(CFNumberRef object);
static void cfsetshow(CFSetRef object);
static void cfstringshow(CFStringRef object);

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

int main(int argc, char ** argv)
{
    IORegistryInfoOptions *options = [[IORegistryInfoOptions alloc] init];

    // Obtain the command-line arguments.

//    while ( (argument = getopt(argc, argv, ":abc:d:fik:ln:p:rsStw:xy")) != -1 )
//    {
//        switch (argument)
//        {
//            case 'p':
//                options.plane = [NSString stringWithUTF8String:optarg];
//                break;
//            case 't':
//                options.tree = YES;
//                break;
//            case 'y':
//                options.nouserclasses = YES;
//                break;
//            default:
//                usage();
//                break;
//        }
//    }

    // Traverse over all the I/O Kit services.

    IORegistryInfo *registryInfo = [IORegistryInfo createWithRootEntry];
    registryInfo.plane = options.plane;
    NSLog(@"%@", registryInfo);

    return 0;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

static char * printbuf     = 0;
static int    printbufclip = FALSE;
static int    printbufleft = 0;
static int    printbufsize = 0;

__attribute__((format(printf, 1, 0)))
static void printva(const char * format, va_list arguments)
{
    if (printbufsize)
    {
        char * c;
        int    count = vsnprintf(printbuf, printbufleft, format, arguments);

        while ( (c = strchr(printbuf, '\n')) )  *c = ' ';    // (strip newlines)

        printf("%s", printbuf);

        if (count >= printbufleft)
        {
            count = printbufleft - 1;
            printbufclip = TRUE;
        }

        printbufleft -= count;   // (printbufleft never hits zero, stops at one)
    }
    else
    {
        vprintf(format, arguments);
    }
}

static void print(const char * format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    printva(format, arguments);
    va_end(arguments);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

static Boolean cfshowhex;

static void cfshow(CFTypeRef object)
{
    CFTypeID type = CFGetTypeID(object);

    if      ( type == CFArrayGetTypeID()      )  cfarrayshow(object);
    else if ( type == CFBooleanGetTypeID()    )  cfbooleanshow(object);
    else if ( type == CFDataGetTypeID()       )  cfdatashow(object);
    else if ( type == CFDictionaryGetTypeID() )  cfdictionaryshow(object);
    else if ( type == CFNumberGetTypeID()     )  cfnumbershow(object);
    else if ( type == CFSetGetTypeID()        )  cfsetshow(object);
    else if ( type == CFStringGetTypeID()     )  cfstringshow(object);
    else print("<unknown object>");
}

static void cfarrayshowapplier(const void * value, void * parameter)
{
    Boolean * first = (Boolean *) parameter;

    if (*first)
        *first = FALSE;
    else
        print(",");

    cfshow(value);
}

static void cfarrayshow(CFArrayRef object)
{
    Boolean first = TRUE;
    CFRange range = { 0, CFArrayGetCount(object) };

    print("(");
    CFArrayApplyFunction(object, range, cfarrayshowapplier, &first);
    print(")");
}

static void cfbooleanshow(CFBooleanRef object)
{
    print(CFBooleanGetValue(object) ? "Yes" : "No");
}

static void cfdatashow(CFDataRef object)
{
    UInt32        asciiNormalCount = 0;
    UInt32        asciiSymbolCount = 0;
    const UInt8 * bytes;
    CFIndex       index;
    CFIndex       length;

    print("<");
    length = CFDataGetLength(object);
    bytes  = CFDataGetBytePtr(object);

    //
    // This algorithm detects ascii strings, or a set of ascii strings, inside a
    // stream of bytes.  The string, or last string if in a set, needn't be null
    // terminated.  High-order symbol characters are accepted, unless they occur
    // too often (80% of characters must be normal).  Zero padding at the end of
    // the string(s) is valid.  If the data stream is only one byte, it is never
    // considered to be a string.
    //

    for (index = 0; index < length; index++)  // (scan for ascii string/strings)
    {
        if (bytes[index] == 0)       // (detected null in place of a new string,
        {                            //  ensure remainder of the string is null)
            break;          // (either end of data or a non-null byte in stream)
        }
        else                         // (scan along this potential ascii string)
        {
            for (; index < length; index++)
            {
                if (isprint(bytes[index]))
                    asciiNormalCount++;
                else if (bytes[index] >= 128 && bytes[index] <= 254)
                    asciiSymbolCount++;
                else
                    break;
            }

            if (index < length && bytes[index] == 0)          // (end of string)
                continue;
            else             // (either end of data or an unprintable character)
                break;
        }
    }

    if ((asciiNormalCount >> 2) < asciiSymbolCount)    // (is 80% normal ascii?)
        index = 0;
    else if (length == 1)                                 // (is just one byte?)
        index = 0;
    else if (cfshowhex)
        index = 0;

    if (index >= length && asciiNormalCount) // (is a string or set of strings?)
    {
        Boolean quoted = FALSE;

        for (index = 0; index < length; index++)
        {
            if (bytes[index])
            {
                if (quoted == FALSE)
                {
                    quoted = TRUE;
                    if (index)
                        print(",\"");
                    else
                        print("\"");
                }
                print("%c", bytes[index]);
            }
            else
            {
                if (quoted == TRUE)
                {
                    quoted = FALSE;
                    print("\"");
                }
                else
                    break;
            }
        }
        if (quoted == TRUE)
            print("\"");
    }
    else                                  // (is not a string or set of strings)
    {
        for (index = 0; index < length; index++)  print("%02x", bytes[index]);
    }

    print(">");
}

static void cfdictionaryshowapplier( const void * key,
                                     const void * value,
                                     void *       parameter )
{
    Boolean * first = (Boolean *) parameter;

    if (*first)
        *first = FALSE;
    else
        print(",");

    cfshow(key);
    print("=");
    cfshow(value);
}

static void cfdictionaryshow(CFDictionaryRef object)
{
    Boolean first = TRUE;

    print("{");
    CFDictionaryApplyFunction(object, cfdictionaryshowapplier, &first);
    print("}");
}

static void cfnumbershow(CFNumberRef object)
{
    long long number;

    if (CFNumberGetValue(object, kCFNumberLongLongType, &number))
    {
        if (cfshowhex)
            print("0x%qx", (unsigned long long)number); 
        else
            print("%qu", (unsigned long long)number); 
    }
}

static void cfsetshowapplier(const void * value, void * parameter)
{
    Boolean * first = (Boolean *) parameter;

    if (*first)
        *first = FALSE;
    else
        print(",");

    cfshow(value);
}

static void cfsetshow(CFSetRef object)
{
    Boolean first = TRUE;
    print("[");
    CFSetApplyFunction(object, cfsetshowapplier, &first);
    print("]");
}

static void cfstringshow(CFStringRef object)
{
    const char * c = CFStringGetCStringPtr(object, kCFStringEncodingUTF8);

    if (c)
        print("\"%s\"", c);
    else
    {
        CFIndex bufferSize = CFStringGetLength(object) + 1;
        char *  buffer     = malloc(bufferSize);

        if (buffer)
        {
            if ( CFStringGetCString(
                    /* string     */ object,
                    /* buffer     */ buffer,
                    /* bufferSize */ bufferSize,
                    /* encoding   */ kCFStringEncodingUTF8 ) )
                print("\"%s\"", buffer);

            free(buffer);
        }
    }
}
