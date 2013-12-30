//
//  NewTableViewController.m
//  WifiCap
//
//  Created by Junfeng Shen on 28/1/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "NewTableViewController.h"


@implementation NewTableViewController
@synthesize nameT;
@synthesize locationT;
@synthesize descriptionT;
@synthesize delegate;
@synthesize imageV;
@synthesize image;

- (IBAction)done:(id)sender{
	mapInfo *newEntry = [[mapInfo alloc] init];
	if (self.nameT.text.length < 1) {
		[self.nameT becomeFirstResponder];
		return;
	}
	if (self.locationT.text.length < 1){
		[self.locationT becomeFirstResponder];
		return;
	}
	if (self.descriptionT.text.length < 1){
		[self.descriptionT becomeFirstResponder];
		return;
	}
	if (self.image == nil){
		[[[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please select a photo as the map from your photo library" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
		[self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
		return;
	}
	newEntry.name = self.nameT.text;
	newEntry.location = self.locationT.text;
	newEntry.description = self.descriptionT.text;
	newEntry.eId = arc4random()%10000;
	newEntry.map = self.image;
	[self.delegate NewTableDone:self entry:newEntry];
	NSLog(@"NewTableViewController call done.");
}

- (void) dealloc
{
	[nameT release];
	[locationT release];
	[descriptionT release];
	[imageV release];
	[image release];
	[delegate release];
	[super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.image = nil;
	ipC = [[UIImagePickerController alloc] init];
	pvC = [[TTThumbsViewController alloc] init];
	pvC.delegate = self;
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	pvC.photoSource = [[PhotoSource alloc] initWithDirection:[path stringByAppendingPathComponent:@"WifiCap"]];
	
}

- (void)viewDidUnload{
	[super viewDidUnload];
	[ipC release];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				[self.nameT becomeFirstResponder];
				break;
			case 1:
				[self.locationT becomeFirstResponder];
				break;
			case 2:
				[self.descriptionT becomeFirstResponder];
				break;
			default:
				break;
		}
	}
	else if(indexPath.section == 1){
		UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Please choose a photo source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Photo Library" otherButtonTitles:@"Camera", @"App's Document", nil];
		[as showInView:self.view];
		[as release];
		[tableView cellForRowAtIndexPath:indexPath].selected = NO;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section == 1){
		if(self.image != nil){
			return 100;
		}
	}
	return 44;
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
	if(self.image.size.height < self.image.size.width*0.8){
		CGSize size = self.image.size;
		CGRect rect = CGRectMake((size.width - size.height*0.8)/2, 0, size.height*0.8, size.height);
		self.imageV.image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([self.image CGImage], rect)];
	}
	else
		self.imageV.image = image;
	[self.tableView reloadData];
	[picker dismissModalViewControllerAnimated:YES];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIActionsheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	switch (buttonIndex) {
		case 0:
			ipC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			ipC.delegate = self;
			[self presentModalViewController:ipC animated:YES];
			break;
		case 1:
			ipC.sourceType = UIImagePickerControllerSourceTypeCamera;
			ipC.delegate = self;
			[self presentModalViewController:ipC animated:YES];
			break;
		case 2:
			[self.navigationController pushViewController:pvC animated:YES];
			break;
		default:
			break;
	}
}

#pragma mark - TTThumbsViewController

- (void)thumbsViewController:(TTThumbsViewController *)controller didSelectPhoto:(id<TTPhoto>)photo{
	Photo *tmp = (Photo*)photo;
	self.image = [UIImage imageWithContentsOfFile:tmp.path];
	
	if(self.image.size.height < self.image.size.width*0.8){
		CGSize size = self.image.size;
		CGRect rect = CGRectMake((size.width - size.height*0.8)/2, 0, size.height*0.8, size.height);
		self.imageV.image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([self.image CGImage], rect)];
	}
	else
		self.imageV.image = image;
	[self.tableView reloadData];
	[self.navigationController popViewControllerAnimated:YES];
}
@end
