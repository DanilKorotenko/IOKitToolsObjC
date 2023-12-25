//
//  IORegistryInfo.h
//  ioregistry
//
//  Created by Danil Korotenko on 12/25/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IORegistryInfo : NSObject

+ (instancetype)createWithRootEntry;

- (instancetype)initWithEntry:(io_registry_entry_t)anEntry;

@end

NS_ASSUME_NONNULL_END
