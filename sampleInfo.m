//
//  sampleInfo.m
//  WifiCap
//
//  Created by Junfeng Shen on 20/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "sampleInfo.h"

@implementation sampleInfo
@synthesize sId;
@synthesize signals;
@synthesize capDate;
@synthesize signalCount;

- (id)initWithDate{
	self = [super init];
	self.sId = -1;
	self.capDate = [NSDate date];
	self.signals = [[NSMutableArray alloc] init];
	self.signalCount = 0;
	return self;
}

- (id)init{
	self = [super init];
	self.sId = -1;
	self.signalCount = 0;
	self.signals = [[NSMutableArray alloc] init];
	return self;
}
- (void)dealloc{
	[self.signals release];
	[self.capDate release];
	[super dealloc];
}
@end
