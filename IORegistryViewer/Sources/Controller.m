//
//  Controller.m
//  IORegistryViewer
//
//  Created by Danil Korotenko on 1/1/24.
//

#import "Controller.h"
#import <AppKit/AppKit.h>

#import "../../Common/IORegistryInfo.h"

@interface Controller ()

@property (strong) IBOutlet NSBrowser *browser;
@property (strong) IBOutlet NSTableView *propertiesTable;

@end

@implementation Controller

#pragma mark NSBrowser delegate

- (nullable id)rootItemForBrowser:(NSBrowser *)browser
{
    return [IORegistryInfo createWithRootEntry];
}


- (BOOL)browser:(NSBrowser *)browser shouldEditItem:(nullable id)item
{
    return NO;
}


@end
