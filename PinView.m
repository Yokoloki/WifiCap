//
//  PointView.m
//  MapView
//
//  Created by Junfeng Shen on 16/2/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "PinView.h"

@implementation PinView
@synthesize pInfo;
@synthesize GR;
@synthesize iv;
@synthesize navController;
- (id)initWithPoint:(pointInfo*)aPoint{
	if(aPoint.sampleCount > 0){
		self.iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pingreen@2x.png"]];
		self.GR = YES;
	}
	else{
		self.iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin@2x.png"]];
		self.GR = NO;
	}
	CGRect f = self.iv.frame;
	f.origin.x -= f.size.width /2.0;
	f.origin.y -= f.size.height /2.0;
	f.size.height *= 2;
	f.size.width *= 2;
	self = [super initWithFrame:f];
	
	f = self.iv.frame;
	f.origin.x += f.size.width/2.0;
	f.origin.y += f.size.height/2.0;
	self.iv.frame = f;
	[self addSubview:self.iv];
	
	f = self.frame;
	f.origin.x = aPoint.coordinate.x - f.size.width*0.36;
	f.origin.y = self.frame.origin.y;
	self.frame = f;
	self.userInteractionEnabled = YES;
	self.pInfo = aPoint;
	UILongPressGestureRecognizer *lpGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(menu:)];
	lpGR.minimumPressDuration = 0.4;
	[self addGestureRecognizer:lpGR];
	[lpGR release];
	return self;
}
- (void)addToView:(UIView*)view withController:(UINavigationController*)controller{
	self.navController = controller;
	[view addSubview:self];
	CGRect f = self.frame;
	[UIView beginAnimations:nil context:NULL];
	f.origin.y = pInfo.coordinate.y - f.size.height*0.7;
	self.frame = f;
	[UIView commitAnimations];
}
- (void)dealloc{
	[self.iv release];
	[self.navController release];
	[super dealloc];
}


- (void)menu:(UILongPressGestureRecognizer*)lpGR{
	
	if(lpGR.state == UIGestureRecognizerStateBegan){
		NSLog(@"subLongPress");
		UIMenuController *m = [UIMenuController sharedMenuController];
		CGRect f = self.frame;
		f.size.width /= 2.0;
		f.size.height /= 2.0;
		f.origin.x += f.size.width/4.0;
		f.origin.y += f.size.height/1.9;
		[m setTargetRect:f inView:self.superview];
		
		UIMenuItem *mi1 = [[UIMenuItem alloc] initWithTitle:@"Info" action:@selector(info:)];
		UIMenuItem *mi2 = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(del:)];
		[m setMenuItems:[NSArray arrayWithObjects:mi1, mi2, nil]];
		[mi1 release];
		[mi2 release];
		[self becomeFirstResponder];
		[m setMenuVisible:YES animated:YES];
	}
}

- (void)info:(id)sender{
	PointInfoViewController *piVC = [[PointInfoViewController alloc] initWithPoint:self.pInfo];
	[self.navController pushViewController:piVC animated:YES];
	[piVC release];
}

- (void)del:(id)sender{
	DatabaseOperation* db = [[DatabaseOperation alloc] init];
	[db delPoint:self.pInfo];
	[db release];
	[UIView beginAnimations:nil context:NULL];
	CGRect f = self.frame;
	f.origin.y += 480;
	self.frame = f;
	[UIView commitAnimations];
	[self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2];
}


- (BOOL) canBecomeFirstResponder{
	return YES;
}
@end
