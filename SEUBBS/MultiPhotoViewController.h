//
//  MultiPhotoViewController.h
//  PhotoScroller
//
//  Created by li liew on 7/8/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCAlbumPickerController.h"
@interface MultiPhotoViewController : UIViewController
- (instancetype)initWithImages:(NSArray *)images;
@property (nonatomic, strong)ELCAlbumPickerController *parent;
@end
