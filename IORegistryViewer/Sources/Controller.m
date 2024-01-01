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
@property (strong) IBOutlet NSTextView *valueField;
@property (strong) IORegistryInfo *rootItem;
@property (strong) IORegistryInfo *selectedItem;

@end

@implementation Controller

- (void)awakeFromNib
{
    self.rootItem = [IORegistryInfo createWithRootEntry];
}

#pragma mark NSBrowser delegate

- (BOOL)browser:(NSBrowser *)browser shouldEditItem:(nullable id)item
{
    return NO;
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item
{
    if (nil == item)
    {
        return 1;
    }
    return [[(IORegistryInfo *)item children] count];
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item
{
    if (nil == item)
    {
        return self.rootItem;
    }
    return [[(IORegistryInfo *)item children] objectAtIndex:index];
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item
{
    if (nil == item)
    {
        return NO;
    }
    return [(IORegistryInfo *)item children].count == 0;
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item
{
    if (nil == item)
    {
        return @"root";
    }
    return [(IORegistryInfo *)item name];
}

- (NSIndexSet *)browser:(NSBrowser *)browser selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes inColumn:(NSInteger)column
{
    if (proposedSelectionIndexes.count > 1 ||
        proposedSelectionIndexes.count == 0)
    {
        [self selectedItemDidChange:nil];
    }

    NSIndexPath *indexPath = [browser indexPathForColumn:column];
    indexPath = [indexPath indexPathByAddingIndex:[proposedSelectionIndexes firstIndex]];
    IORegistryInfo *ioregInfo = [browser itemAtIndexPath:indexPath];

    [self selectedItemDidChange:ioregInfo];

    return proposedSelectionIndexes;
}

- (BOOL)browser:(NSBrowser *)sender selectRow:(NSInteger)row inColumn:(NSInteger)column
{
    NSIndexPath *indexPath = [self.browser indexPathForColumn:column];
    indexPath = [indexPath indexPathByAddingIndex:row];
    IORegistryInfo *ioregInfo = [self.browser itemAtIndexPath:indexPath];
    if (ioregInfo)
    {
        return YES;
    }

    return NO;
}

- (BOOL)browser:(NSBrowser *)sender selectCellWithString:(NSString *)title inColumn:(NSInteger)column
{
    return YES;
}

#pragma mark NSTableView delegate and data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (self.selectedItem)
    {
        return self.selectedItem.properties.count;
    }
    return 0;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (nil == self.selectedItem)
    {
        return nil;
    }

    NSString *key = [[self.selectedItem.properties allKeys] objectAtIndex:row];

    if ([tableColumn.identifier isEqualToString:@"name"])
    {
        return key;
    }

    return [self.selectedItem.properties objectForKey:key];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    [self.valueField setString:@""];

    if (nil == self.selectedItem)
    {
        return;
    }

    NSInteger selectedRow = [self.propertiesTable selectedRow];

    if (selectedRow >= 0 && selectedRow < self.selectedItem.properties.count)
    {
        NSString *key = [[self.selectedItem.properties allKeys] objectAtIndex:selectedRow];
        id value = [self.selectedItem.properties objectForKey:key];
        [self.valueField setString:[value description]];
    }
}

#pragma mark -

- (void)selectedItemDidChange:(IORegistryInfo *)ioregInfo
{
    self.selectedItem = ioregInfo;
    [self tableViewSelectionDidChange:nil];
    [self.propertiesTable reloadData];
}

@end
