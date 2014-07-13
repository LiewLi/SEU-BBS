//
//  DLNavigationPanelViewController.m
//  SEUBBS
//
//  Created by li liew on 7/2/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLNavigationPanelViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "DLSectionsViewController.h"
#import "DLBBSAPIHelper.h"
#import "DLBoardModel.h"
#import "DLFriendsViewController.h"
#import "DLHotTenViewController.h"

@implementation DLNavigationPanelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 3.0f;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"/avatar.jpg"];
    self.profileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfMappedFile:imagePath]];
    self.view.frame = CGRectMake(0, 0, 100, self.view.frame.size.height);
    self.view.backgroundColor = [UIColor blackColor];
    
    NSString *userID = [[NSUserDefaults standardUserDefaults]stringForKey:@"USER"];
    self.userNameLabel.text = userID;
    [self.masterFeedsButton setImage:[UIImage imageNamed:@"masterFeedsButtonPressed"] forState:UIControlStateSelected];
    self.masterFeedsButton.selected = YES;
    [self.sectionsButton setImage:[UIImage imageNamed:@"sectionsPressed"] forState:UIControlStateSelected];
    [self.friendsButton setImage:[UIImage imageNamed:@"friendsIconPressed"] forState:UIControlStateSelected];
    
}

- (IBAction)buttonTapped:(UIButton *)sender
{
    for (UIButton * button in self.buttonArray) {
        button.selected = NO;
    }
    
    sender.selected = YES;
    
    
    if (self.masterFeedsButton.selected) {
        DLHotTenViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"HotTenViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        self.sidePanelController.centerPanel = nav;
    }
    
    else if (self.sectionsButton.selected) {
        DLSectionsViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DLSectionsViewController"];
        vc.title = @"分类讨论区";
        [DLBBSAPIHelper fetchSectionsInfoWithComplete:^(NSArray *sections, NSError *error) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                vc.boards = [[NSMutableArray alloc]init];
                for (NSDictionary *section in sections) {
                    DLBoardModel *model = [[DLBoardModel alloc]initWithInfo:section];
                    [vc.boards addObject:model];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [vc.collectionView reloadData];
                });
//            });
        }];

        
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        self.sidePanelController.centerPanel = nav;
    }
    else if (self.friendsButton.selected) {
        DLFriendsViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"DLFriendsViewController"];
        
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        self.sidePanelController.centerPanel = nav;
    }
    
}
@end
