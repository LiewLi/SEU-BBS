//
//  DLReplyMessageViewController.m
//  SEUBBS
//
//  Created by li liew on 7/15/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLEditMessageViewController.h"
#import "DLEditMailTableViewCell.h"
#import "DLEditMailContentTableViewCell.h"
#import "DLBBSAPIHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DLFriendsListViewController.h"

@interface DLEditMessageViewController() <DLFriendsListDelegate>
@property (nonatomic, strong)DLFriendsListViewController *friendsList;
@property (nonatomic, strong)UIPopoverController *pop;
@property (nonatomic, strong)NSMutableArray *selectedFriends;
@end

@implementation DLEditMessageViewController

- (void)didSelectFrirend:(NSString *)userID
{
    NSLog(@"select %@", userID);
}

- (void)didDeSelectFriend:(NSString *)userID
{
    NSLog(@"deselect %@", userID);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedFriends = [[NSMutableArray alloc]init];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        DLEditMailContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DLEditMailContentTableViewCell" forIndexPath:indexPath];
        return cell;
    } else {
        DLEditMailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DLEditMailTableViewCell" forIndexPath:indexPath];
        if (indexPath.section == 0) {
            cell.headerLabel.text = @"收信人:";
        }
        else if (indexPath.section == 1) {
            cell.headerLabel.text = @"标题:";
            cell.addContactButton.hidden = YES;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = self.tableView.frame.size;
    if (indexPath.section == 0 || indexPath.section == 1) {
        return 44;
    } else {
        return size.height - 128;
    }
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendButtonTapped:(id)sender
{
    [self.tableView endEditing:YES];
    DLEditMailTableViewCell *recv = (DLEditMailTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    DLEditMailTableViewCell *title = (DLEditMailTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    
     DLEditMailContentTableViewCell *content = (DLEditMailContentTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    [DLBBSAPIHelper sendMessageTo:recv.contentTextField.text reid:0 title:title.contentTextField.text content:content.contentTextView.text complete:^(BOOL success) {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        if (success) {
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
            HUD.customView = image;
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = @"成功发送";
            [HUD show:YES];
            dispatch_time_t deley = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
            dispatch_after(deley, dispatch_get_main_queue(), ^{
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            });
        } else {
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crossmark"]];
            HUD.customView = image;
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = @"发送失败";
            [HUD show:YES];
            dispatch_time_t deley = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
            dispatch_after(deley, dispatch_get_main_queue(), ^{
                [HUD removeFromSuperview];
            });
        }
    }];
}

- (IBAction)addContactButtonTapped:(id)sender
{
    UIButton *button = sender;
    CGRect rect = [self.tableView convertRect:button.frame fromView:button.superview];
    if (!self.friendsList) {
        self.friendsList = [[DLFriendsListViewController alloc] init];
        self.friendsList.delegate = self;
    }
    
    if (!self.pop) {
        self.pop = [[UIPopoverController alloc] initWithContentViewController:self.friendsList];
    }
    self.pop.popoverContentSize = CGSizeMake(200, 300);
    [self.pop presentPopoverFromRect:rect inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}
@end
