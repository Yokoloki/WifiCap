//
//  DBEntryViewController.m
//  WifiCap
//
//  Created by Junfeng Shen on 19/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "MapInfoViewController.h"

@implementation MapInfoViewController
@synthesize entry;

- (id)initWithEntry:(mapInfo*)aEntry{
	self = [super initWithStyle:UITableViewStyleGrouped];
	self.entry = aEntry;
	db = [[DatabaseOperation alloc] init];
	return self;
}

- (void)dealloc{
	[self.entry release];
	[db release];
	[super dealloc];
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	self.entry.pCount = [db getPointCountForMap:self.entry];
	[self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.title = @"DataBase Info";
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Enter" style:UIBarButtonItemStyleBordered target:self action:@selector(enterMap)];
	self.navigationItem.rightBarButtonItem = barButton;
	[barButton release];
}

- (void)enterMap{
	MapViewController *mvC = [[MapViewController alloc] initWithMapInfo:entry];
	[self.navigationController pushViewController:mvC animated:YES];
	[mvC release];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"entryCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"entryCell"] autorelease];
    }
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Name";
			cell.detailTextLabel.text = self.entry.name;
			break;
		case 1:
			cell.textLabel.text = @"Location";
			cell.detailTextLabel.text = self.entry.location;
			break;
		case 2:
			cell.textLabel.text = @"Description";
			cell.detailTextLabel.text = self.entry.description;
			break;
		case 3:
			cell.textLabel.text = @"Point Count";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.entry.pCount];
			break;
		default:
			break;
	}
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return @"Basic Information";
}
#pragma mark - Table view delegate

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	return nil;
}

@end
