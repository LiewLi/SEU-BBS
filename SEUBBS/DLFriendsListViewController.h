//
//  DLFriendsListViewController.h
//  SEUBBS
//
//  Created by li liew on 7/16/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DLFriendsListDelegate <NSObject>
- (void)didSelectFrirend:(NSString *)userID;
- (void)didDeSelectFriend:(NSString *)userID;
@end

@interface DLFriendsListViewController : UITableViewController
@property (nonatomic, weak)id<DLFriendsListDelegate> delegate;
@end
