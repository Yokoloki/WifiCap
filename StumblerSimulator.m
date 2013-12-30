//
//  StumblerSimulator.m
//  WifiCap
//
//  Created by Junfeng Shen on 21/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "StumblerSimulator.h"

@implementation StumblerSimulator
+ (BOOL)scanNetwork:(sampleInfo*)s{
	int k;
	for(int i=0; i<1000000; i++)
		for(int j=0; j<300; j++)
			if(i==j)
				k++;
	for(int i=0; i<1+(arc4random() % 7); i++){
		signalInfo* tmp = [[signalInfo alloc] init];
		tmp.mac = [NSString stringWithFormat:@"mac for sample %d", i];
		tmp.ssid = [NSString stringWithFormat:@"ssid for sample %d", i];
		tmp.mode = 2;
		tmp.beacon = 10;
		tmp.rssi = 100+i;
		tmp.noise = 0;
		tmp.channel = i;
		tmp.capabilities = i;
		[s.signals addObject:tmp];
		[tmp release];
	}
	s.signalCount = s.signals.count;
	return YES;
}
@end
