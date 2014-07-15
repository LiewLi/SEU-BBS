//
//  DLNavigationPanelViewController.h
//  SEUBBS
//
//  Created by li liew on 7/2/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLNavigationPanelViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *masterFeedsButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonArray;
- (IBAction)buttonTapped:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *friendsButton;

@property (weak, nonatomic) IBOutlet UIButton *sectionsButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

@end
