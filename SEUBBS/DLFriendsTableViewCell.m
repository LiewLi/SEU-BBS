//
//  DLFriendsTableViewCell.m
//  SEUBBS
//
//  Created by li liew on 7/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLFriendsTableViewCell.h"

@implementation DLFriendsTableViewCell
- (void)awakeFromNib
{
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 3.0f;
    self.profileImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}
@end
