//
//  DLBoardCollectionViewCell.m
//  SEUBBS
//
//  Created by li liew on 7/10/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLBoardCollectionViewCell.h"

@implementation DLBoardCollectionViewCell

-(void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.blurredView.backgroundColor = [UIColor colorWithRed:0.053 green:0.088 blue:0.205 alpha:1.000];
   // self.blurredView.backgroundColor = [UIColor whiteColor];
    self.blurredView.alpha = 0.5;
}
@end
