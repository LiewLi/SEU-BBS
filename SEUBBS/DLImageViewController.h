//
//  DLImageViewController.h
//  SEUBBS
//
//  Created by li liew on 7/5/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLAttachmentModel.h"
#import "ImageScrollView.h"
@interface DLImageViewController : UIViewController
@property (nonatomic, strong)DLAttachmentModel *image;
@property (nonatomic, assign)NSInteger pageIndex;
@end
