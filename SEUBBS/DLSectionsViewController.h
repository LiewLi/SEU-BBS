//
//  DLSectionsViewController.h
//  SEUBBS
//
//  Created by li liew on 7/10/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLSectionsViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong)NSMutableArray *boards;
@end