//
//  MapViewController.m
//  WifiCap
//
//  Created by Junfeng Shen on 20/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "MapViewController.h"

@implementation MapViewController
@synthesize entry;
@synthesize mapView;
- (id)initWithMapInfo:(mapInfo *)aEntry{
	self = [super init];
	appeared = NO;
	db = [[DatabaseOperation alloc] init];
	self.entry = aEntry;
	[db getPointsForMap:entry];
	nextPointID = [db getNextPointID];
	return self;
}

- (NSInteger)getNextPointID{
	nextPointID++;
	[db setNextPointID:nextPointID];
	return nextPointID-1;
}
#pragma mark - View lifecycle

- (void)dealloc{
	[db release];
	[self.entry release];
	[self.mapView release];
	[super dealloc];
}

- (void)viewDidLoad{
    [super viewDidLoad];
	
	
	self.view.backgroundColor = [UIColor grayColor];
	self.view.frame = CGRectMake(0, 0, 320, 480);
	self.navigationItem.title = @"MapView";
	UITapGestureRecognizer *tGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeBarStatus)];
	tGR.numberOfTapsRequired = 1;
	tGR.numberOfTouchesRequired = 2;
	[self.view addGestureRecognizer:tGR];
	[tGR release];
	
	self.mapView = [[MapView alloc] initWithFrame:self.view.frame];
	[self.mapView setUp:self.entry.map];
	
	UILongPressGestureRecognizer *lpGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
	lpGR.minimumPressDuration = 0.8;
	[self.mapView addGestureRecognizer:lpGR];
	[lpGR release];
	
	UILongPressGestureRecognizer *dlpGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doubleLongPress:)];
	dlpGR.minimumPressDuration = 1.2;
	dlpGR.numberOfTapsRequired = 2;
	[self.mapView addGestureRecognizer:dlpGR];
	[dlpGR release];
	
	UITapGestureRecognizer *dtGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
	dtGR.numberOfTapsRequired = 2;
	[self.mapView addGestureRecognizer:dtGR];
	[dtGR release];
	[self.view addSubview:self.mapView];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	for(int i=0; i<self.mapView.imageView.subviews.count; i++){
		PinView *view = [self.mapView.imageView.subviews objectAtIndex:i];
		if([view class] == [PinView class]){
			if(view.GR == YES && view.pInfo.sampleCount == 0){
				view.GR = NO;
				view.iv.image = [UIImage imageNamed:@"pin@2x.png"];
			}else if(view.GR == NO && view.pInfo.sampleCount !=0){
				view.GR = YES;
				view.iv.image = [UIImage imageNamed:@"pingreen@2x.png"];
			}
		}
	}
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	if(!appeared){
		for(int i=0; i<self.entry.points.count; i++){
			pointInfo *p = [self.entry.points objectAtIndex:i];
			p.sampleCount = [db getSampleCountForPoint:p];
			PinView *pv = [[PinView alloc] initWithPoint:p];
			[pv addToView:self.mapView.imageView withController:self.navigationController];
			[pv release];
		}
		appeared = YES;
	}
}

- (void)changeBarStatus{
	[self.navigationController setNavigationBarHidden:!([self.navigationController isNavigationBarHidden]) animated:YES];
}

- (void)longPress:(UILongPressGestureRecognizer*)lpGR{
	if(lpGR.state == UIGestureRecognizerStateBegan){
		NSLog(@"long press for map");
		pointInfo *p = [[pointInfo alloc] initWithID:[self getNextPointID] at:[lpGR locationInView:self.mapView.imageView]];
		[db addPoint:p forMap:self.entry];
		PinView *pv = [[PinView alloc] initWithPoint:p];
		[pv addToView:self.mapView.imageView withController:self.navigationController];
		[pv menu:lpGR];
		[pv release];
	}
	else
		return;
}

- (void)doubleLongPress:(UILongPressGestureRecognizer*)dlpGR{
	if(dlpGR.state == UIGestureRecognizerStateBegan){
		NSLog(@"double tap long press for map");
		/*
		pointInfo *p = [[pointInfo alloc] initWithID:[self getNextPointID] at:[dlpGR locationInView:self.mapView.imageView]];
		[db addPoint:p forMap:self.entry];
		PinView *pv = [[PinView alloc] initWithPoint:p];
		[pv addToView:self.mapView.imageView withController:self.navigationController];
		[pv menu:dlpGR];
		[pv release];
		 */
		//int dis = 100;
		//int wOffset = self.mapView.imageView.image.size.width % dis;
		//int hOffset = self.mapView.imageView.image.size.height % dis;
	}
	else
		return;
}

- (void)doubleTap:(UITapGestureRecognizer*)dtGR{
	NSLog(@"double tap");	
	if(self.mapView.zoomScale == 1.0){
		[self.mapView setZoomScale:self.mapView.minimumZoomScale animated:YES];
	}
	else{
		CGFloat dx = [dtGR locationInView:self.mapView.imageView].x - self.mapView.imageView.center.x;
		CGFloat dy = [dtGR locationInView:self.mapView.imageView].y - self.mapView.imageView.center.y;
		CGPoint p = self.mapView.contentOffset;
		p.x += dx;
		p.y += dy;
		if(p.x < 0)
			p.x = 0;
		if(p.y < 0)
			p.y = 0;
		if(p.x > (self.mapView.imageView.image.size.width - 320))
			p.x = self.mapView.imageView.image.size.width - 320;
		if(p.y > (self.mapView.imageView.image.size.height - 480))
			p.y = self.mapView.imageView.image.size.height - 480;
		[self.mapView setZoomScale:1.0 animated:YES];
		[self.mapView setContentOffset:p];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
