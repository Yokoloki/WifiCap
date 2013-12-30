//
//  PointView.h
//  MapView
//
//  Created by Junfeng Shen on 16/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointInfoViewController.h"
#import "pointInfo.h"
#import "DatabaseOperation.h"
@interface PinView : UIView{
	UIImageView *iv;
	BOOL GR;
	pointInfo *pInfo;
	UINavigationController *navController;
}
@property (nonatomic, retain) pointInfo *pInfo;
@property (nonatomic, retain) UIImageView *iv;
@property (nonatomic, assign) BOOL GR;
@property (nonatomic, retain) UINavigationController *navController;

- (id)initWithPoint:(pointInfo*)p;
- (void)addToView:(UIView*)view withController:(UINavigationController*)controller;
- (void)menu:(id)sender;
@end
