//
//  DLAddFriendPopOverViewController.m
//  SEUBBS
//
//  Created by li liew on 7/13/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLAddFriendPopOverViewController.h"
#import "DLBBSAPIHelper.h"
#import "DLUserModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface DLAddFriendPopOverViewController() <UITextFieldDelegate>
@property (nonatomic, strong)NSShadow *shadow;
@property (nonatomic, strong)NSString *userID;
@end

@implementation DLAddFriendPopOverViewController

-(void)awakeFromNib
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 3.0f;
    self.profileImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addButton.enabled = NO;
    self.shadow = [[NSShadow alloc] init];
    [self.shadow setShadowColor:[UIColor colorWithRed:0.053 green:0.088 blue:0.205 alpha:1.000]];
    [self.shadow setShadowBlurRadius:4.0];
    [self.shadow setShadowOffset:CGSizeMake(2, 2)];
    
    self.userIDTextField.delegate = self;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.addButton.enabled = NO;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.userIDTextField.text = @"";
    self.profileImageView.image = nil;
    self.userIDLabel.text = @"";
    self.nameLabel.text = @"";
    self.genderImageView.image = nil;
    self.postsLabel.text = @"";
    self.performLabel.text = @"";
    self.experienceLabel.text = @"";
    self.levelLabel.text = @"";
    self.astroLabel.text = @"";
    
}
- (IBAction)searchButtonTapped:(id)sender
{
    if (self.userIDTextField.text.length) {
         self.userID = self.userIDTextField.text;
        [DLBBSAPIHelper fetchUserInfo:self.userID complete:^(NSDictionary *userInfo, NSError *error) {
            if (!error && userInfo) {
                self.hintLabel.text = @"";
                [self.userIDTextField resignFirstResponder];
                if (userInfo[@"avatar"] == [NSNull null]) {
                    self.profileImageView.image = [UIImage imageNamed:@"loginDefaultUser"];
                } else {
                    NSString *avatar = userInfo[@"avatar"];
                    [self.profileImageView setImageWithURL:[NSURL URLWithString:avatar]];
                }
                NSString *gender = userInfo[@"gender"];
                if ([gender isEqualToString:@"F"]) {
                    self.genderImageView.image = [UIImage imageNamed:@"female"];
                } else if ([gender isEqualToString:@"M"]) {
                    self.genderImageView.image = [UIImage imageNamed:@"male"];
                } else {
                    self.genderImageView.image = nil;
                }
                NSMutableAttributedString *attrUserID = [[NSMutableAttributedString alloc]initWithString:self.userID];
                [attrUserID addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, attrUserID.length)];
                [self.userIDLabel setAttributedText:attrUserID];
                self.experienceLabel.text = userInfo[@"experience"];
                self.addButton.enabled = YES;
                self.nameLabel.text = userInfo[@"name"];
                self.astroLabel.text = userInfo[@"astro"];
                self.levelLabel.text = userInfo[@"level"];
                self.postsLabel.text = userInfo[@"posts"];
                self.performLabel.text = userInfo[@"perform"];
                [self.delegate searchComplete];
            } else {
                self.userID = @"";
                self.hintLabel.text = @"该用户不存在";
                [self.delegate userNotFound];
                self.addButton.enabled = NO;
            }
        }];
    } else {
        self.addButton.enabled = NO;
    }
}
- (IBAction)addButtonTapped:(id)sender
{
    [self.delegate userAdd:self.userID];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length) {
        [self searchButtonTapped:nil];
        return YES;
    } else
        return NO;
}
@end
