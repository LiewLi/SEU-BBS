//
//  DLFriendsViewController.m
//  SEUBBS
//
//  Created by li liew on 7/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLFriendsViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "DLUserModel.h"
#import "DLFriendsTableViewCell.h"
#import "DLBBSAPIHelper.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface DLFriendsViewController() <UISearchDisplayDelegate>
@property (nonatomic, strong)NSMutableArray *friends;
@property (nonatomic, strong)NSArray *filteredFriends;
@property (nonatomic, strong)NSShadow *shadow;
@end

@implementation DLFriendsViewController 
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.sidePanelController.state == JASidePanelLeftVisible) {
        [self.sidePanelController toggleLeftPanel:self];
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"(SELF.name contains[cd] %@) OR (SELF.userID contains[cd] %@)",
                                    searchText, searchText];
    
    self.filteredFriends = [self.friends filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.title = @"好友";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.13 green:0.36 blue:0.62 alpha:1.0];
    
    [DLBBSAPIHelper fetchFriendsWithComplete:^(NSArray *friends, NSError *error) {
        if (!error && friends.count) {
            self.friends = [friends mutableCopy];
            [self.tableView reloadData];
        }
    }];
    
    self.shadow = [[NSShadow alloc] init];
    [self.shadow setShadowColor:[UIColor colorWithRed:0.053 green:0.088 blue:0.205 alpha:1.000]];
    [self.shadow setShadowBlurRadius:4.0];
    [self.shadow setShadowOffset:CGSizeMake(2, 2)];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DLUserModel *item = (DLUserModel *)self.friends[indexPath.row];
        [DLBBSAPIHelper deleteFriend:item.userID withComplete:^(BOOL success, NSError *error) {
            if (success && !error) {
                [self.friends removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            } else {

            }
        }];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *array = [NSMutableArray array];
    for(int section='A';section<='Z';section++)
    {
        [array addObject:[NSString stringWithFormat:@"%c",section]];
    }
    return array;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.filteredFriends.count;
    } else {
        return self.friends.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLFriendsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DLFriendsTableViewCell" forIndexPath:indexPath];
    
    DLUserModel *item;
    if (tableView == self.tableView) {
        item = (DLUserModel *)self.friends[indexPath.row];
    } else {
        item = (DLUserModel *)self.filteredFriends[indexPath.row];
    }

    
    [cell.profileImageView setImageWithURL:[NSURL URLWithString:item.avatar] placeholderImage:[UIImage imageNamed:@"loginDefaultUser"]];
    cell.nameLabel.text = item.name;
    NSMutableAttributedString *attrUserID = [[NSMutableAttributedString alloc]initWithString:item.userID];
    [attrUserID addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, attrUserID.length)];
    [cell.userIDLabel setAttributedText:attrUserID];
    

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}
@end
