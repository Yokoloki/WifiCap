//
//  DBEntry.h
//  WifiCap
//
//  Created by Junfeng Shen on 28/1/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mapInfo : NSObject{
	NSInteger eId;
	NSString *name;
	NSString *location;
	NSString *description;
	NSInteger pCount;
	UIImage *map;
	NSMutableArray *points;
}
@property (nonatomic, assign) NSInteger eId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, assign) NSInteger pCount;
@property (nonatomic, retain) UIImage *map;
@property (nonatomic, retain) NSMutableArray *points;
@end
