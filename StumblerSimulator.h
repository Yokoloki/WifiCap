//
//  StumblerSimulator.h
//  WifiCap
//
//  Created by Junfeng Shen on 21/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sampleInfo.h"
#import "signalInfo.h"
@interface StumblerSimulator : NSObject
+ (BOOL)scanNetwork:(sampleInfo*)s;
@end
