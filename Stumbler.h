//
//  Stumbler.h
//  WifiCap
//
//  Created by Junfeng Shen on 20/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#include <dlfcn.h>
#import "sampleInfo.h"
#import "signalInfo.h"
@interface Stumbler : NSObject{
	NSMutableDictionary *networks; //Key: MAC Address (BSSID)
	
	void *libHandle;
	void *airportHandle;    
	int (*apple80211Open)(void *);
	int (*apple80211Bind)(void *, NSString *);
	int (*apple80211Close)(void *);
	int (*associate)(void *, NSDictionary*, NSString*);
	int (*apple80211Scan)(void *, NSArray **, void *);
}
- (BOOL)scanNetwork:(sampleInfo*)sample;
@end
