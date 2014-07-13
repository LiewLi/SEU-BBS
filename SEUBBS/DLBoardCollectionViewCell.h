//
//  DLBoardCollectionViewCell.h
//  SEUBBS
//
//  Created by li liew on 7/10/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLBoardCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subBoardsLabel;
@property (weak, nonatomic) IBOutlet UIView *blurredView;

@end
