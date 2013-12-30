//
//  SampleInfoViewController.m
//  PointInfoViewController
//
//  Created by Junfeng Shen on 19/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "SampleInfoViewController.h"


@implementation SampleInfoViewController
@synthesize s;
- (id)initWithSample:(sampleInfo*)samp{
    self = [super initWithStyle:UITableViewStyleGrouped];
	db = [[DatabaseOperation alloc] init];
	self.s = samp;
	[db getSignalsForSample:self.s];
	self.navigationItem.title = @"SampleInfo";
    return self;
}

- (void)dealloc{
	[self.s release];
	[super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
	[super viewDidLoad];
}
- (void)viewDidUnload{
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.s.signals.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 5;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return [[self.s.signals objectAtIndex:section] mac];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"] autorelease];
    }
    switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"SSID";
			cell.detailTextLabel.text = [[self.s.signals objectAtIndex:indexPath.section] ssid];
			break;
		case 1:
			cell.textLabel.text = @"Mode";
			if([[self.s.signals objectAtIndex:indexPath.section] mode] == 2)
				cell.detailTextLabel.text = @"Infrastructure";
			else
				cell.detailTextLabel.text = @"Ad-hoc";
			break;
		case 2:
			cell.textLabel.text = @"RSSI";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [[self.s.signals objectAtIndex:indexPath.section] rssi]];
			break;
		case 3:
			cell.textLabel.text = @"Noise";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[[self.s.signals objectAtIndex:indexPath.section] noise]];
			break;
		case 4:
			cell.textLabel.text = @"Beacon";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [[self.s.signals objectAtIndex:indexPath.section] beacon]];
			break;
		default:
			break;
	}
    return cell;
}


#pragma mark - Table view delegate

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	return nil;
}

@end
