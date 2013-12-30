//
//  MapViewController.h
//  WifiCap
//
//  Created by Junfeng Shen on 20/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseOperation.h"
#import "MapView.h"
#import "PinView.h"
#import "mapInfo.h"
@interface MapViewController : UIViewController{
	mapInfo* entry;
	MapView* mapView;
	DatabaseOperation* db;
	NSInteger nextPointID;
	BOOL appeared;
}
@property (nonatomic, retain) mapInfo* entry;
@property (nonatomic, retain) MapView* mapView;
- (id)initWithMapInfo:(mapInfo*)aEntry;
- (NSInteger)getNextPointID;
@end
