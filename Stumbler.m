//
//  Stumbler.m
//  WifiCap
//
//  Created by Junfeng Shen on 20/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "Stumbler.h"

@implementation Stumbler

- (id)init{
	self = [super init];
	libHandle = dlopen("/System/Library/SystemConfiguration/IPConfiguration.bundle/IPConfiguration", RTLD_LAZY);
	char *error;
	if (libHandle == NULL && (error = dlerror()) != NULL){
		NSLog(@"%s", error);
		exit(1);
	}
	apple80211Open = dlsym(libHandle, "Apple80211Open");
	apple80211Bind = dlsym(libHandle, "Apple80211BindToInterface");
	apple80211Close = dlsym(libHandle, "Apple80211Close");
	apple80211Scan = dlsym(libHandle, "Apple80211Scan");
	apple80211Open(&airportHandle);
	apple80211Bind(airportHandle, @"en0");
	return self;
}
- (void)dealloc{
	apple80211Close(airportHandle);
	[super dealloc];
}

- (BOOL)scanNetwork:(sampleInfo*)result{
	NSArray *scan_networks;
	NSLog(@"scanning wifi channels");
	NSDictionary *parameters = [[NSDictionary alloc] init];
	apple80211Scan(airportHandle, &scan_networks, parameters);
	if(scan_networks == nil)
		return NO;
	for(int i=0; i<scan_networks.count; i++){
		
		NSDictionary *dic = [scan_networks objectAtIndex:i];
		NSNumber *age = [dic objectForKey:@"AGE"];
		if(age.integerValue < 800){
			signalInfo* sig = [[signalInfo alloc] init];
			sig.mac = [dic objectForKey:@"BSSID"];
			sig.ssid = [dic objectForKey:@"SSID_STR"];
            if(sig.ssid.length == 0)
                sig.ssid = [NSString stringWithFormat:@"NULL"];
			NSNumber* channel = [dic objectForKey:@"CHANNEL"];
			sig.channel = channel.integerValue;
			NSNumber* noise = [dic objectForKey:@"NOISE"];
			sig.noise = noise.integerValue;
			NSNumber* rssi = [dic objectForKey:@"RSSI"];
			sig.rssi = rssi.integerValue;
			NSNumber* capabilities = [dic objectForKey:@"CAPABILITIES"];
			sig.capabilities = capabilities.integerValue;
			NSNumber *mode = [dic objectForKey:@"AP_MODE"];
			sig.mode = mode.integerValue;
			NSNumber *beacon = [dic objectForKey:@"BEACON_INT"];
			sig.beacon = beacon.integerValue;
			[result.signals addObject:sig];
			[sig release];
            NSLog(@"--%d, age=%@, MAC=%@, SSID=%@, Rssi=%d, ,Channel=%d, Noise=%d, Capabilities=%d, Mode=%d, Beacon=%d--", i, age,sig.mac, sig.ssid, sig.rssi, sig.channel, sig.noise, sig.capabilities, sig.mode, sig.beacon);
		}
	}
	result.signalCount = result.signals.count;
	[parameters release];
	NSLog(@"finish scanning");
	return YES;
}
@end
