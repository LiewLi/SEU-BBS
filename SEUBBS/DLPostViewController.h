//
//  DLPostViewController.h
//  SEUBBS
//
//  Created by li liew on 7/3/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLTopicPostFetcher.h"
#import "DLPostReplyViewController.h"

@interface DLPostViewController : UITableViewController 
@property (nonatomic, strong)DLTopicPostFetcher *postFetcher;
@end
