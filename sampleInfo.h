//
//  sampleInfo.h
//  WifiCap
//
//  Created by Junfeng Shen on 20/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sampleInfo : NSObject{
	NSInteger sId;
	NSMutableArray *signals;
	NSInteger signalCount;
	NSDate *capDate;
}
@property (nonatomic, assign) NSInteger sId;
@property (nonatomic, assign) NSInteger signalCount;
@property (nonatomic, retain) NSMutableArray *signals;
@property (nonatomic, retain) NSDate *capDate;
- (id)initWithDate;
@end
