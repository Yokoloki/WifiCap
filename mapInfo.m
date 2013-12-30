//
//  DBEntry.m
//  WifiCap
//
//  Created by Junfeng Shen on 28/1/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "mapInfo.h"

@implementation mapInfo
@synthesize eId;
@synthesize name;
@synthesize location;
@synthesize description;
@synthesize pCount;
@synthesize map;
@synthesize points;

- (id)init{
	self = [super init];
	self.points = [[NSMutableArray alloc] init];
	self.pCount = -1;
	return self;
}
- (void)dealloc{
	[self.name release];
	[self.location release];
	[self.description release];
	[super dealloc];
}

@end
