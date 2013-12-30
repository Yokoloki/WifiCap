//
//  ViewController.h
//  PointInfoViewController
//
//  Created by Junfeng Shen on 18/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DatabaseOperation.h"
#import "Stumbler.h"
#import "StumblerSimulator.h"
#import "pointInfo.h"
#import "ButtonCell.h"
#import "SampleInfoViewController.h"

@interface PointInfoViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate>{
	pointInfo* pInfo;
	Stumbler *stumbler;
	NSDateFormatter *formatter1;
	NSDateFormatter *formatter2;
	DatabaseOperation *db;
	NSInteger nextSampleID;
	BOOL preHide;
	BOOL nextLevel;
	UIActivityIndicatorView *busyIndicator;
}
@property (nonatomic, retain) pointInfo *pInfo;
- (id)initWithPoint:(pointInfo*)p;
- (NSInteger)getNextSampleID;
- (void)captureSample;
@end
