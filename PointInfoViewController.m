//
//  ViewController.m
//  PointInfoViewController
//
//  Created by Junfeng Shen on 18/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "PointInfoViewController.h"
#define NumPerTime 15
@implementation PointInfoViewController
@synthesize pInfo;

- (id)initWithPoint:(pointInfo *)p{
	self = [super initWithStyle:UITableViewStyleGrouped];	
	self.pInfo = p;
	db = [[DatabaseOperation alloc] init];
	stumbler = [[Stumbler alloc] init];
	[db getSamplesForPoint:self.pInfo];
	formatter1 = [[NSDateFormatter alloc] init];
	[formatter1 setDateFormat:@"yyyy-MM-dd HH:mm"];
	formatter2 = [[NSDateFormatter alloc] init];
	[formatter2 setDateFormat:@"HH:mm:ss  yyyy-MM-dd"];
	nextSampleID = [db getNextSampleID];
	
	for(int i = 0; i<self.pInfo.samples.count; i++){
		sampleInfo *s = [self.pInfo.samples objectAtIndex:i];
		s.signalCount = [db getSignalCountForSample:s];
	}
	busyIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[busyIndicator hidesWhenStopped];
	return self;
}

- (void)dealloc{
	[self.pInfo release];
	[db release];
	[stumbler release];
	[formatter1 release];
	[formatter2 release];
	[busyIndicator release];
	[super dealloc];
}

- (NSInteger)getNextSampleID{
	nextSampleID ++;
	[db setNextSampleID:nextSampleID];
	return nextSampleID-1;
}
#pragma mark - View lifecycle
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return 1;
		case 1:
			return 3;
		case 2:
			return self.pInfo.samples.count;
	}
	return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell *cell;
	switch (indexPath.section) {
		case 0: 
			cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell"];
			if(cell == nil)
				cell = [[[NSBundle mainBundle] loadNibNamed:@"ButtonCell" owner:self options:nil] objectAtIndex:0];
			break;
		case 1:
			cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell"];
			if(cell == nil)
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"infoCell"];
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"cooradinate";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"(%.0f, %.0f)",pInfo.coordinate.x, pInfo.coordinate.y];
					break;
				case 1:
					cell.textLabel.text = @"create time";
					cell.detailTextLabel.text = [formatter1 stringFromDate:self.pInfo.createDate];
					break;
				case 2:
					cell.textLabel.text = @"samples count";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.pInfo.samples.count];
					break;
			}
			break;
		case 2:
			cell = [tableView dequeueReusableCellWithIdentifier:@"sampleCell"];
			if (cell == nil)
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"sampleCell"];
			sampleInfo *tmp = [self.pInfo.samples objectAtIndex:(self.pInfo.samples.count - 1 - [indexPath row])];
			
			cell.textLabel.text = [NSString stringWithFormat:@"%@", [formatter2 stringFromDate:tmp.capDate]];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"Number of captured AP = %d", tmp.signalCount];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
	}
	return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return nil;
		case 1:
			return @"Basic information";
		case 2:
			return @"Captured samples";
	}
	return nil;
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section == 1)
		return nil;
	else
		return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	switch(indexPath.section){
		case 0:
			NSLog(@"capture signals");
			self.tableView.userInteractionEnabled = NO;
			[self performSelectorInBackground:@selector(captureSample) withObject:nil];
			[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
			return;
		case 1:
			return;
		case 2:
			nextLevel = YES;
			[self.navigationController pushViewController:[[SampleInfoViewController alloc] initWithSample:[self.pInfo.samples objectAtIndex:(self.pInfo.samples.count - 1 - indexPath.row)]] animated:YES];
			[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
	}
}

- (void)captureSample{
	[self performSelectorInBackground:@selector(setBusy) withObject:nil];
	sampleInfo* sample;
	for(int i=0; i<NumPerTime; i++){
		sample = [[sampleInfo alloc] initWithDate];
		if ([stumbler scanNetwork:sample] == NO){
		//if([StumblerSimulator scanNetwork:sample] == NO){
			UIAlertView *al =[[UIAlertView alloc] initWithTitle:@"Capture Failed" message:@"Please turn on Wi-Fi option in Setting" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[self performSelectorInBackground:@selector(resetBusy) withObject:nil];
			[al show];
			[al release];
		}else{
			sample.sId = [self getNextSampleID];
			[self.pInfo.samples addObject:sample];
			[db addSample:sample forPoint:self.pInfo];
			self.pInfo.sampleCount = self.pInfo.samples.count;
			[self performSelector:@selector(resetBusy)];
		}
		[sample release];
		NSLog(@"the %d th sample",i+1);
		[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
	}
	self.tableView.userInteractionEnabled = YES;
}

- (void)setBusy{
	[busyIndicator startAnimating];
}

- (void)resetBusy{
	[busyIndicator stopAnimating];}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section == 2)
		return YES;
	else
		return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		[db delSample:[self.pInfo.samples objectAtIndex:(self.pInfo.samples.count - 1 - indexPath.row)]];
		[self.pInfo.samples removeObjectAtIndex:(self.pInfo.samples.count - 1 - indexPath.row)];
		self.pInfo.sampleCount = self.pInfo.samples.count;
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView reloadData];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	nextLevel = NO;
	self.navigationItem.title = @"PointInfo";
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:busyIndicator];
	self.navigationItem.rightBarButtonItem = item;
	[item release];
}

- (void)viewDidAppear:(BOOL)animated
{
	if(nextLevel == YES)
		nextLevel = NO;
	else
		preHide = self.navigationController.isNavigationBarHidden;
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	if(nextLevel){
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}
	else
		[self.navigationController setNavigationBarHidden:preHide animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
