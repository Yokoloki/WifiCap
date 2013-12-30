//
//  signalInfo.m
//  WifiCap
//
//  Created by Junfeng Shen on 20/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "signalInfo.h"

@implementation signalInfo
@synthesize mac;
@synthesize ssid;
@synthesize rssi;
@synthesize noise;
@synthesize channel;
@synthesize capabilities;
@synthesize mode;
@synthesize beacon;
- (void)dealloc{
	[self.mac release];
	[self.ssid release];
	[super dealloc];
}
@end
