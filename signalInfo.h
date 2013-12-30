//
//  signalInfo.h
//  WifiCap
//
//  Created by Junfeng Shen on 20/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface signalInfo : NSObject{
	NSString *mac;
	NSString *ssid;
	NSInteger channel;
	NSInteger rssi;
	NSInteger noise;
	NSInteger capabilities;
	NSInteger mode;
	NSInteger beacon;
}
@property (nonatomic, retain) NSString *mac;
@property (nonatomic, retain) NSString *ssid;
@property (nonatomic, assign) NSInteger channel;
@property (nonatomic, assign) NSInteger rssi;
@property (nonatomic, assign) NSInteger noise;
@property (nonatomic, assign) NSInteger capabilities;
@property (nonatomic, assign) NSInteger mode;
@property (nonatomic, assign) NSInteger beacon;
@end
