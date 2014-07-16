//
//  DLFriendsListViewController.m
//  SEUBBS
//
//  Created by li liew on 7/16/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLFriendsListViewController.h"
#import "DLUserModel.h"
#import "DLBBSAPIHelper.h"

@interface DLFriendsListViewController()
@property (nonatomic, strong) NSArray *friends;
@end


@implementation DLFriendsListViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [DLBBSAPIHelper fetchFriendsWithComplete:^(NSArray *friends, NSError *error) {
        if (!error) {
            self.friends = friends;
            [self.tableView reloadData];
        }
    }];
    self.tableView.allowsMultipleSelection = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    DLUserModel *item = self.friends[indexPath.row];
    cell.textLabel.text = item.userID;
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = nil;
    DLUserModel *item = self.friends[indexPath.row];
    NSString *userID = item.userID;
    [self.delegate didDeSelectFriend:userID];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *selected = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"selectedIcon"]];
    [cell setAccessoryView:selected];
    DLUserModel *item = self.friends[indexPath.row];
    NSString *userID = item.userID;
    [self.delegate didSelectFrirend:userID];
}
@end
