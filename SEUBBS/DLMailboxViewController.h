//
//  DLMailboxViewController.h
//  SEUBBS
//
//  Created by li liew on 7/15/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLMailboxFetcher.h"

@interface DLMailboxViewController : UITableViewController
@property(nonatomic, strong) DLMailboxFetcher *mailboxFetcher;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mailboxSegmentControl;
- (IBAction)segmentChange:(id)sender;
@end
