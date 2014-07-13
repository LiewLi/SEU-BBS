//
//  DLAddFriendPopOverViewController.h
//  SEUBBS
//
//  Created by li liew on 7/13/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DLAddFriendPopOverDelegate <NSObject>
- (void)searchComplete;
- (void)userNotFound;
- (void)userAdd:(NSString *)userID;
@end

@interface DLAddFriendPopOverViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
- (IBAction)searchButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
- (IBAction)addButtonTapped:(id)sender;
@property (weak, nonatomic)id<DLAddFriendPopOverDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *experienceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *astroLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *postsLabel;
@property (weak, nonatomic) IBOutlet UILabel *performLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end
