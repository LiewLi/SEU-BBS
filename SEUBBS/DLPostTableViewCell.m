//
//  DLPostTableViewCell.m
//  SEUBBS
//
//  Created by li liew on 7/3/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLPostTableViewCell.h"
#import "UITableViewCell+TableView.h"

@implementation DLPostTableViewCell

- (void)awakeFromNib
{
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 3.0f;
    self.profileImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentLabel.numberOfLines = 0;
    
}
- (IBAction)replyButtonTapped:(id)sender
{
    UITableViewController *vc = (UITableViewController *)[self tableViewController];
    NSIndexPath *indexPath = [vc.tableView indexPathForCell:self];
    [self.delegate replyPostAtIndexPath:indexPath];
}

- (IBAction)viewImageButtonTapped:(id)sender
{
    UITableViewController *vc = (UITableViewController *)[self tableViewController];
    NSIndexPath *indexPath = [vc.tableView indexPathForCell:self];
    [self.delegate viewImageAtIndexPath:indexPath];
}
@end
