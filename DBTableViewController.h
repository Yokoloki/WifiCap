//
//  DBTableViewController.h
//  WifiCap
//
//  Created by Junfeng Shen on 28/1/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewTableViewController.h"
#import "DatabaseOperation.h"
#import "MapInfoViewController.h"

@interface DBTableViewController : UITableViewController<NewTableDelegate>{
	NSMutableArray *entries;
	NSInteger nextMapID;
}
@property (nonatomic, retain) NSMutableArray *entries;

- (NSInteger)getNextMapID;
@end
