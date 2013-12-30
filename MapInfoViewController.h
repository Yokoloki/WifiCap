//
//  DBEntryViewController.h
//  WifiCap
//
//  Created by Junfeng Shen on 19/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mapInfo.h"
#import "MapViewController.h"
#import "DatabaseOperation.h"
@interface MapInfoViewController : UITableViewController{
	mapInfo *entry;
	DatabaseOperation *db;
}
@property (nonatomic, retain) mapInfo *entry;

- (id)initWithEntry:(mapInfo*)aEntry;
@end
