//
//  MapView.m
//  MapView
//
//  Created by Junfeng Shen on 16/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "MapView.h"
#import "PinView.h"
@implementation MapView
@synthesize imageView;

- (id) initWithFrame:(CGRect)frame{
	if(self = [super initWithFrame:frame]){
		self.delegate = self;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
	}
	return self;
}

- (void) setUp:(UIImage*)map{
	self.imageView = [[UIImageView alloc] initWithImage:map];
	self.imageView.userInteractionEnabled = YES;
	self.imageView.contentMode = UIViewContentModeCenter;
	self.maximumZoomScale = 2.0;
	self.minimumZoomScale = MIN(320.0/map.size.width, 480.0/map.size.height);
	self.zoomScale = self.minimumZoomScale;
	[self addSubview:self.imageView];
}

- (void)layoutSubviews{
	[super layoutSubviews];
	UIView* imgV = [self.delegate viewForZoomingInScrollView:self];
	CGFloat svw = self.bounds.size.width;
	CGFloat svh = self.bounds.size.height;
	CGFloat vw = imgV.frame.size.width;
	CGFloat vh = imgV.frame.size.height;
	CGRect f = imgV.frame;
	if(vw < svw)
		f.origin.x = (svw - vw) / 2.0;
	else f.origin.x = 0;
	if(vh < svh)
		f.origin.y = (svh - vh) / 2.0;
	else f.origin.y = 0;
	imgV.frame = f;
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return imageView;
}


- (void) dealloc{
	[self.imageView release];
	[super dealloc];
}
@end
