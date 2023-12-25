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

@property(strong) IORegistryInfoOptions *options;

@property(readonly) NSString *name;
@property(readonly) NSString *location;

#pragma mark -

- (void)scan;
- (void)show;

@end

NS_ASSUME_NONNULL_END
