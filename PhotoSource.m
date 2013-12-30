//
//  PhotoSource.m
//  WifiCap
//
//  Created by Junfeng Shen on 23/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "PhotoSource.h"

@implementation PhotoSource
@synthesize photos;
@synthesize title;
- (id)initWithDirection:(NSString*)dir{
	//dir = /var/mobile/Documents/WifiCap/
	self = [super init];
	self.title = @"Photo";
	self.photos = [[NSMutableArray alloc] init];
	NSLog(@"dir = %@", dir);
	NSFileManager *fm = [NSFileManager defaultManager];
	pathForPhotos = [[NSMutableArray alloc] init];
	pathForThumbs = [[NSMutableArray alloc] init];
	BOOL isDir;
	if(![fm fileExistsAtPath:dir isDirectory:&isDir] || !isDir){
		[fm createDirectoryAtPath:[dir stringByAppendingPathComponent:@"thumbs"] withIntermediateDirectories:YES attributes:nil error:nil];
		NSLog(@"generate direction");
	}else{
		NSArray *contents = [fm contentsOfDirectoryAtPath:dir error:nil];
		for(int i=0; i<contents.count; i++){
			NSLog(@"%@", [contents objectAtIndex:i]);
			NSString *tmp = [[contents objectAtIndex:i] pathExtension];
			NSString *tmp2 = [contents objectAtIndex:i];
			if([tmp isEqualToString:@"jpg"] || [tmp isEqualToString:@"jpeg"] || [tmp isEqualToString:@"png"] ||
			   [tmp isEqualToString:@"bmp"] || [tmp isEqualToString:@"gif"] || [tmp isEqualToString:@"tif"] ||
			   [tmp isEqualToString:@"tiff"]){
				[pathForPhotos addObject:[dir stringByAppendingPathComponent:[contents objectAtIndex:i]]];
				[pathForThumbs addObject:[[[dir stringByAppendingPathComponent:@"thumbs"] stringByAppendingPathComponent:[tmp2 substringToIndex:(tmp2.length - tmp.length)]] stringByAppendingString:@"jpeg"]];
			}
		}
	}
	for(int i=0; i<pathForPhotos.count; i++){
		NSLog(@"%@", [pathForPhotos objectAtIndex:i]);
		[self.photos addObject:[[Photo alloc] initWithPath:[pathForPhotos objectAtIndex:i] thumbPath:[pathForThumbs objectAtIndex:i]]];
		[[self.photos objectAtIndex:i] setPhotoSource:self];
		[[self.photos objectAtIndex:i] setIndex:i];
	}
	[self performSelectorInBackground:@selector(thumbing) withObject:nil];
	return self;
}

- (void)thumbing{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int j = 0;
	for(int i=0; i<pathForPhotos.count; i++){
		NSFileManager *fm = [NSFileManager defaultManager];
		if(![fm fileExistsAtPath:[pathForThumbs objectAtIndex:i]]){
			j++;
			UIImage *oriImage = [UIImage imageWithContentsOfFile:[pathForPhotos objectAtIndex:i]];
			CGSize size = oriImage.size;  
			CGSize croppedSize;  
			CGFloat ratio = 160.0; 
			CGFloat offsetX = 0.0;  
			CGFloat offsetY = 0.0; 
			if (size.width > size.height) {  
				offsetX = (size.height - size.width) / 2;  
				croppedSize = CGSizeMake(size.height, size.height);  
			} else {  
				offsetY = (size.width - size.height) / 2;  
				croppedSize = CGSizeMake(size.width, size.width);  
			}
			CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);  
			CGImageRef imageRef = CGImageCreateWithImageInRect([oriImage CGImage], clippedRect);
			CGRect rect = CGRectMake(0.0, 0.0, ratio, ratio);  
			UIGraphicsBeginImageContext(rect.size);  
			[[UIImage imageWithCGImage:imageRef] drawInRect: rect];
			UIImage * thumbnail = UIGraphicsGetImageFromCurrentImageContext();  
			UIGraphicsEndImageContext();  
			[UIImageJPEGRepresentation(thumbnail, 0.7) writeToFile:[pathForThumbs objectAtIndex:i] atomically:NO];
			NSLog(@"Done thumbing %d image", i);
		}
	}
	[pool release];
}

- (NSInteger)numberOfPhotos{
	return self.photos.count;
}
- (NSInteger)maxPhotoIndex{
	
	return self.photos.count-1;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)index{
	if (index < self.photos.count) {
		return [self.photos objectAtIndex:index];
	} else {
		return nil;
	}
}

- (void)dealloc{
	[pathForPhotos release];
	[pathForThumbs release];
	[self.photos release];
	[self.title release];
	[super dealloc];
}
- (BOOL)isLoading{
	return NO;
}
- (BOOL)isLoaded{
	return !!self.photos;
}
@end







@implementation Photo
@synthesize photoSource;
@synthesize size;
@synthesize index;
@synthesize caption;
@synthesize path;
@synthesize thumbUrl;

- (id)initWithPath:(NSString*)aPath thumbPath:(NSString*)tPath{
	self = [super init];
	self.path = aPath;
	self.thumbUrl = [NSString stringWithFormat:@"file://localhost%@", tPath];
	self.photoSource = nil;
	self.caption = nil;
	self.index = -1;
	return self;
}

- (NSString*)URLForVersion:(TTPhotoVersion)version{
	return self.thumbUrl;
}

- (void) dealloc{
	//[self.url release];
	[self.thumbUrl release];
	[self.caption release];
	[super dealloc];
}
@end