//
//  MultiPhotoViewController.m
//  PhotoScroller
//
//  Created by li liew on 7/8/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "MultiPhotoViewController.h"
#import "PhotoViewController.h"

@interface MultiPhotoViewController() <UIPageViewControllerDataSource>
@property (nonatomic, strong)NSArray *images;
@property (nonatomic, strong)NSMutableArray *vc;
@property (nonatomic, strong)UIPageViewController *pageController;
@end

@implementation MultiPhotoViewController
- (instancetype)initWithImages:(NSArray *)images
{
    if (self = [super init]) {
        _images = images;
        _vc = [[NSMutableArray alloc]init];
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:@"完成(%ld)", self.images.count] style:UIBarButtonItemStylePlain target:self.parent action:@selector(doneAction:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[flexibleSpace, doneBarButton];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.dataSource = self;
    PhotoViewController *photoVC = [self viewControllerAtIndex:0];
    [self.pageController setViewControllers:@[photoVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
   self.view.gestureRecognizers = self.pageController.gestureRecognizers;
    
}

- (NSUInteger)indexOfViewController:(PhotoViewController *)vc
{
    return [self.images indexOfObject:vc.image];
}

- (PhotoViewController *)viewControllerAtIndex:(NSUInteger )index
{
    if (self.images.count == 0 || index >= self.images.count) {
        return nil;
    }
    if (index < self.vc.count) {
        return self.vc[index];
    } else {
        PhotoViewController* vc = [[PhotoViewController alloc] initWithImage:self.images[index]];
        [self.vc addObject:vc];
        return vc;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(PhotoViewController *)vc
{
    NSUInteger index = [self indexOfViewController:vc];
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    return [self viewControllerAtIndex:(index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(PhotoViewController *)vc
{
//    NSLog(@"after");
    NSUInteger index = [self indexOfViewController:vc];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == self.images.count) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

@end
