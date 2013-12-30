//
//  NewTableViewController.h
//  WifiCap
//
//  Created by Junfeng Shen on 28/1/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Three20UI/TTThumbsViewController.h"
#import "PhotoSource.h"
#import "mapInfo.h"
@class NewTableViewController;

@protocol NewTableDelegate <NSObject>
- (void) NewTableDone:(NewTableViewController*)controller entry:(mapInfo*)entry;
@end

@interface NewTableViewController : UITableViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, TTThumbsViewControllerDelegate>{
	IBOutlet UITextField *nameT;
	IBOutlet UITextField *locationT;
	IBOutlet UITextField *descriptionT;
	IBOutlet UIImageView *imageV;
	UIImage *image;
	UIImagePickerController *ipC;
	TTThumbsViewController *pvC;
	id<NewTableDelegate> delegate;
}
@property (nonatomic, retain) UITextField *nameT;
@property (nonatomic, retain) UITextField *locationT;
@property (nonatomic, retain) UITextField *descriptionT;
@property (nonatomic, retain) id<NewTableDelegate> delegate;
@property (nonatomic, retain) UIImageView *imageV;
@property (nonatomic, retain) UIImage *image;

- (IBAction)done:(id)sender;
@end
