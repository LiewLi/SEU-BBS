//
//  DLHotTenTableViewCell.m
//  SEUBBS
//
//  Created by li liew on 7/2/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLHotTenTableViewCell.h"
#import "UITableViewCell+TableView.h"
#import "DLPostViewController.h"

@implementation DLHotTenTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {

    }
    
    return self;
}

- (void)awakeFromNib
{
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 3.0f;
    self.profileImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.masterView.bounds];
//    self.masterView.layer.masksToBounds = NO;
//    self.masterView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.masterView.layer.shadowOffset = CGSizeMake(6.0f, 6.0f);
//    self.masterView.layer.shadowOpacity = 0.5f;
//    self.masterView.layer.shadowPath = shadowPath.CGPath;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
- (IBAction)viewDetailButtonTapped:(id)sender
{
    UITableViewController *vc = (UITableViewController *)[self tableViewController];
    [[self tableViewController] tableView:vc.tableView didSelectRowAtIndexPath:[vc.tableView indexPathForCell:self]];
}
@end
