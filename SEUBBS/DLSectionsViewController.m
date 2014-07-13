//
//  DLSectionsViewController.m
//  SEUBBS
//
//  Created by li liew on 7/10/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLSectionsViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "DLBoardModel.h"
#import "DLBBSAPIHelper.h"
#import "DLBoardCollectionViewCell.h"
#import "DLTimer.h"
#import "DLBoardViewController.h"
@import CoreImage;


@interface DLSectionsViewController()
@property (nonatomic, strong)CIContext *context;
@end

@implementation DLSectionsViewController

- (UIImage *)blurryImage:(UIImage *)image
           withBlurLevel:(CGFloat)blur {
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, inputImage,
                        @"inputRadius", @(blur),
                        nil];
    
    CIImage *outputImage = filter.outputImage;
    
    CGImageRef outImage = [self.context createCGImage:outputImage
                                             fromRect:[outputImage extent]];
    return [UIImage imageWithCGImage:outImage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.13 green:0.36 blue:0.62 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
//    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;

    
    self.context = [CIContext contextWithOptions:nil];
    UIImage *background = [UIImage imageNamed:@"defaultLoginBackgroundHorizontal.jpg"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       UIImage *blurredImage =  [self blurryImage:background withBlurLevel:4];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.collectionView.backgroundColor = [UIColor colorWithPatternImage:blurredImage];
        });
    });
    
  //  self.collectionView.backgroundColor = [UIColor blackColor];
   // [self.collectionView reloadData];
    self.collectionView.contentSize = self.collectionView.frame.size;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.sidePanelController.state == JASidePanelLeftVisible) {
        [self.sidePanelController toggleLeftPanel:self];
    }
    [self.collectionViewLayout invalidateLayout];
    
}


#pragma mark  - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DLBoardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DLBoardCollectionViewCell" forIndexPath:indexPath];
    DLBoardModel *board =(DLBoardModel *)(self.boards[indexPath.row]);
    cell.descriptionLabel.text = board.description;
    cell.nameLabel.text = board.name;
    if (!board.leaf) {
        cell.subBoardsLabel.text = [NSString stringWithFormat:@"+%ld个子版块", board.boards.count];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.boards.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DLBoardModel *item = (DLBoardModel *)self.boards[indexPath.row];
    if (item.leaf) {
        DLBoardViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DLBoardViewController"];
        DLBoardFetcher *fetcher = [[DLBoardFetcher alloc]initWithBoard:item.name];
        vc.postFetcher = fetcher;
        vc.title = item.description;
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        DLSectionsViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DLSectionsViewController"];
        NSArray *sections = ((DLBoardModel *)self.boards[indexPath.row]).boards;
        vc.boards = [[NSMutableArray alloc]init];
        for (NSDictionary *section in sections) {
            DLBoardModel *model = [[DLBoardModel alloc]initWithInfo:section];
            [vc.boards addObject:model];
        }
        vc.title = item.description;
        
        [self.navigationController pushViewController:vc animated:YES];
    }

}


@end
