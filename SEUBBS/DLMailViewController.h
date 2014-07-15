//
//  DLMailViewController.h
//  SEUBBS
//
//  Created by li liew on 7/15/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLMailViewController : UITableViewController
@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *time;
@property (nonatomic, strong)NSString *author;
@property (nonatomic, assign)NSInteger mailID;
@property (nonatomic, assign)NSInteger mailType;
@end
