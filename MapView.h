//
//  MapView.h
//  MapView
//
//  Created by Junfeng Shen on 16/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapView : UIScrollView<UIScrollViewDelegate>{
	UIImageView *imageView;
}
@property (nonatomic, retain) UIImageView *imageView;
- (void) setUp:(UIImage*)map;
@end
