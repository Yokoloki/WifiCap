//
//  SampleInfoViewController.h
//  PointInfoViewController
//
//  Created by Junfeng Shen on 19/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseOperation.h"
#import "sampleInfo.h"
#import "signalInfo.h"

@interface SampleInfoViewController : UITableViewController{
	sampleInfo *s;
	DatabaseOperation *db;
}
@property (nonatomic, retain) sampleInfo *s;

- (id)initWithSample:(sampleInfo*)samp;
@end
