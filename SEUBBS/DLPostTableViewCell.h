//
//  DLPostTableViewCell.h
//  SEUBBS
//
//  Created by li liew on 7/3/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DLPostTableViewCellDelegate <NSObject>
- (void)replyPostAtIndexPath:(NSIndexPath *)indexPath;
- (void)viewImageAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface DLPostTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UILabel *experienceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *replyLablel;
@property (weak, nonatomic) IBOutlet UIButton *viewImageButton;
@property (weak, nonatomic) id<DLPostTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *masterView;
- (IBAction)replyButtonTapped:(id)sender;
- (IBAction)viewImageButtonTapped:(id)sender;

@end
