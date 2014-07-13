//
//  DLBoardTableViewCell.m
//  SEUBBS
//
//  Created by li liew on 7/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLBoardTableViewCell.h"
#import "UITableViewCell+TableView.h"

@implementation DLBoardTableViewCell

- (void)awakeFromNib
{
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 3.0f;
    self.profileImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
- (IBAction)viewMoreDetailButtonTapped:(id)sender
{
    UITableViewController *vc = (UITableViewController *)[self tableViewController];
    [[self tableViewController] tableView:vc.tableView didSelectRowAtIndexPath:[vc.tableView indexPathForCell:self]];
}
@end
