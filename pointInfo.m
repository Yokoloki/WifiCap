//
//  pointInfo.m
//  WifiCap
//
//  Created by Junfeng Shen on 20/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "pointInfo.h"

@implementation pointInfo
@synthesize pId;
@synthesize samples;
@synthesize coordinate;
@synthesize createDate;
@synthesize sampleCount;

- (id)init{
	self = [super init];
	self.pId = -1;
	self.samples = [[NSMutableArray alloc] init];
	self.sampleCount = 0;
	return self;
}

- (id)initWithID:(NSInteger)i at:(CGPoint)coo{
	self = [super init];
	self.coordinate = coo;
	self.samples = [[NSMutableArray alloc] init];
	self.sampleCount = 0;
	self.pId = i;
	createDate = [[NSDate alloc] init];
	return self;
}
- (void)dealloc{
	[self.samples release];
	[self.createDate release];
	[super dealloc];
}
@end
