//
//  pointInfo.h
//  WifiCap
//
//  Created by Junfeng Shen on 20/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pointInfo : NSObject{
	NSInteger pId;
	NSInteger sampleCount;
	NSDate *createDate;
	NSMutableArray *samples;
	CGPoint coordinate;
}
@property (nonatomic, assign) NSInteger pId;
@property (nonatomic, assign) NSInteger sampleCount;
@property (nonatomic, retain) NSDate *createDate;
@property (nonatomic, retain) NSMutableArray *samples;
@property (nonatomic, assign) CGPoint coordinate;

- (id)initWithID:(NSInteger)d at:(CGPoint)coo;
@end
