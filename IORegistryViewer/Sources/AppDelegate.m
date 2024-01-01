//
//  AppDelegate.m
//  IORegistryViewer
//
//  Created by Danil Korotenko on 1/1/24.
//

#import "AppDelegate.h"
#import "Controller.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app
{
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
