//
//  PhotoSource.h
//  WifiCap
//
//  Created by Junfeng Shen on 23/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Three20/Three20.h>

@interface PhotoSource : TTURLRequestModel<TTPhotoSource>{
	NSMutableArray *photos;
	NSMutableArray *pathForPhotos;
	NSMutableArray *pathForThumbs;
}
@property (nonatomic, retain) NSMutableArray *photos;
- (id)initWithDirection:(NSString*)dir;
- (void)thumbing;
@end

@interface Photo : NSObject<TTPhoto>{
	NSString *path;
	NSString *thumbUrl;
}
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *thumbUrl;
- (id)initWithPath:(NSString*)aPath thumbPath:(NSString*)tPath;
@end
