//
//  DBTableViewController.m
//  WifiCap
//
//  Created by Junfeng Shen on 28/1/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "DBTableViewController.h"
#import "NewTableViewController.h"
#import "mapInfo.h"

@implementation DBTableViewController{
	DatabaseOperation *db;
}
@synthesize entries;

- (void)NewTableDone:(NewTableViewController *)controller entry:(mapInfo *)entry{
	entry.eId = [self getNextMapID];
	[self.entries addObject:entry];
	[db addMap:entry];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.entries count]-1 inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.navigationController popViewControllerAnimated:YES];
	NSLog(@"One new entry added");
}

- (NSInteger)getNextMapID{
	nextMapID++;
	[db setNextMapID:nextMapID];
	return nextMapID-1;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	db = [[DatabaseOperation alloc] init];
	entries = [db getMaps];
	nextMapID = [db getNextMapID];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	db = nil;
	entries = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mapInfo"];
	mapInfo *en = [self.entries objectAtIndex:indexPath.row];
	cell.textLabel.text = en.name;
	cell.detailTextLabel.text = [en.description stringByAppendingFormat:@", %@", en.location];
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[db delMap:[entries objectAtIndex:indexPath.row]];
		[entries removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[entries objectAtIndex:indexPath.row] setPCount:[db getPointCountForMap:[entries objectAtIndex:indexPath.row]]];
	MapInfoViewController* entryVC = [[MapInfoViewController alloc] initWithEntry:[entries objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:entryVC animated:YES];
	[entryVC release];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddMap"])
	{
		NewTableViewController *newTable = segue.destinationViewController;
		newTable.delegate = self;
	}
}

@end
