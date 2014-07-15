//
//  DLMailboxTableViewCell.h
//  SEUBBS
//
//  Created by li liew on 7/15/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLMailboxTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *unreadimageView;
@end
