//
//  IORegistryInfo.h
//  ioregistry
//
//  Created by Danil Korotenko on 12/25/23.
//

#import <Foundation/Foundation.h>
#import "IORegistryInfoOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface IORegistryInfo : NSObject

+ (instancetype)createWithRootEntry;

- (instancetype)initWithEntry:(io_registry_entry_t)anEntry;

#pragma mark -

@property (strong, nullable) NSString *plane;

@property(readonly) NSString *name;
@property(readonly) NSString *location;
@property(readonly) NSString *className;
@property(readonly) NSArray *children;
@property(readonly) NSDictionary *properties;

@end

NS_ASSUME_NONNULL_END
