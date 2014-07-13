//
//  DLMultipleImageViewController.m
//  SEUBBS
//
//  Created by li liew on 7/6/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLMultipleImageViewController.h"
#import "DLImageViewController.h"

@interface DLMultipleImageViewController() <UIPageViewControllerDataSource>
@property (nonatomic, strong)UIPageViewController *pageViewController;
@property (nonatomic, strong)NSMutableArray *vc;
@end

@implementation DLMultipleImageViewController

- (void)viewDidLoad
{
    self.vc = [[NSMutableArray alloc] init];
    self.pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource= self;
    DLImageViewController *imageVC = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[imageVC];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.title = @"查看附件";
    
}

- (DLImageViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if ((self.images.count == 0) || (index >= self.images.count)) {
        return nil;
    }
    
    if (index < self.vc.count) {
        return self.vc[index];
    } else {
        DLImageViewController *imageVC = [[DLImageViewController alloc]init];
        imageVC.image = (DLAttachmentModel *)self.images[index];
        imageVC.pageIndex = index;
        [self.vc addObject:imageVC];
        return imageVC;
    }
}


#pragma mark - UIPageViewControllerDataSource
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = ((DLImageViewController *)viewController).pageIndex;
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = ((DLImageViewController *)viewController).pageIndex;
    if (index == 0 || index ==NSNotFound) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.images.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}
@end
