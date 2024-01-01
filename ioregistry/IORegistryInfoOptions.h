//
//  IORegistryInfoOptions.h
//  ioregistry
//
//  Created by Danil Korotenko on 12/25/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IORegistryInfoOptions : NSObject

@property (readwrite) BOOL tree;                  // (-t option)
@property (readwrite) BOOL nouserclasses;         // (-y option)

@property (strong, nullable) NSString *plane;              // (-p option)

@end

NS_ASSUME_NONNULL_END
