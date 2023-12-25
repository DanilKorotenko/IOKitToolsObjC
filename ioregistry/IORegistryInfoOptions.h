//
//  IORegistryInfoOptions.h
//  ioregistry
//
//  Created by Danil Korotenko on 12/25/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IORegistryInfoOptions : NSObject

@property (readwrite) BOOL archive;               // (-a option)
@property (readwrite) BOOL bold;                  // (-b option)
@property (readwrite) BOOL format;                // (-f option)
@property (readwrite) BOOL hex;                   // (-x option)
@property (readwrite) BOOL inheritance;           // (-i option)
@property (readwrite) BOOL list;                  // (-l option)
@property (readwrite) BOOL root;                  // (-r option)
@property (readwrite) BOOL tree;                  // (-t option)
@property (readwrite) BOOL nouserclasses;         // (-y option)

@property (strong, nullable) NSString *classStr;           // (-c option)
@property (readwrite) UInt32 depth;                 // (-d option)
@property (strong, nullable) NSString *key;                // (-k option)
@property (strong, nullable) NSString *name;               // (-n option)
@property (strong, nullable) NSString *plane;              // (-p option)
@property (readwrite) UInt32 width;                 // (-w option)

@end

NS_ASSUME_NONNULL_END
