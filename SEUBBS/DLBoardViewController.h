//
//  DLBoardViewController.h
//  SEUBBS
//
//  Created by li liew on 7/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLBoardFetcher.h"

@interface DLBoardViewController : UITableViewController
@property (nonatomic, strong)DLBoardFetcher *postFetcher;
@end
