//
//  DLMailboxViewController.m
//  SEUBBS
//
//  Created by li liew on 7/15/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLMailboxViewController.h"
#import "DLMailboxTableViewCell.h"
#import "DLMailboxModel.h"
#import "DLMailboxFetcher.h"
#import "DLMailViewController.h"
#import "DLBBSAPIHelper.h"
#import <Toast+UIView.h>
#import "DLEditMessageViewController.h"

@interface DLMailboxViewController ()
@property (nonatomic, strong)NSMutableArray *mails;
@property (nonatomic, strong)NSDateFormatter *dateFormatter;
@property (nonatomic, strong)DLMailboxFetcher *fetcher;
@end

@implementation DLMailboxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mails = [[NSMutableArray alloc] init];
    
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setDateFormat:@"MMM dd, yyyy-h:mm"];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    self.fetcher = [[DLMailboxFetcher alloc]init];
    self.fetcher.type = DLMailboxTypeInbox; // default case
    self.title = @"站内信";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.13 green:0.36 blue:0.62 alpha:1.0];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self tableView:self.tableView willDisplayCell:nil forRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:0]];
    
    UIBarButtonItem *edit = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStyleDone target:self action:@selector(composeMessage:)];
    self.navigationItem.rightBarButtonItem = edit;
    
}

- (void)composeMessage:(id)sender
{
    DLEditMessageViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DLEditMessageViewController"];
    vc.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)refresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    [self reload];
    [self.refreshControl endRefreshing];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLMailboxModel *item = self.mails[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [DLBBSAPIHelper deleteMailFor:item.mailID type:self.fetcher.type complete:^(BOOL success) {
            if (success) {
                [self.mails removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [self.view makeToast:@"操作失败"];
            }
        }];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLMailboxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DLMailboxCell" forIndexPath:indexPath];
    DLMailboxModel *item = self.mails[indexPath.row];
    cell.authorLabel.text = item.author;
    cell.titleLabel.text = item.title;
    NSString *timeDescription = [self.dateFormatter stringFromDate:item.time];
    cell.timeLabel.text = timeDescription;
    cell.unreadimageView.hidden = !item.unread;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.mails.count - 1) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadMore];
        });
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLMailboxModel *item = self.mails[indexPath.row];
    item.unread = NO;
    DLMailboxTableViewCell *cell = (DLMailboxTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.unreadimageView.hidden = YES;
    DLMailViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DLMailViewController"];
    vc.mailID = item.mailID;
    vc.author = item.author;
    vc.title = item.title;
    vc.time = [self.dateFormatter stringFromDate:item.time];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLMailboxModel *item = self.mails[indexPath.row];
    NSDictionary *atrr = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0]};
    CGRect labelSize;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        labelSize = [item.title boundingRectWithSize:CGSizeMake(824, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:atrr context:nil];
    } else {
        labelSize = [item.title boundingRectWithSize:CGSizeMake(568, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:atrr context:nil];
    }
    return labelSize.size.height + 50;
}

- (void)loadMore
{
    NSArray *more = [self.fetcher fetchMore];
    [self performSelectorOnMainThread:@selector(appendTableWith:) withObject:more waitUntilDone:NO];
}

- (void)appendTableWith:(NSArray *)more
{
    for (id obj in more) {
        [self.mails addObject:obj];
    }
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc]initWithCapacity:10];
    for (int idx = 0; idx < more.count; idx++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.mails indexOfObject:more[idx]] inSection:0];
        [insertIndexPaths addObject:indexPath];
    }
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
}
-(void)reload
{
    [self.mails removeAllObjects];
    [self.tableView reloadData];
    [self.fetcher reload];
    [self tableView:self.tableView willDisplayCell:nil forRowAtIndexPath:[NSIndexPath indexPathForRow:self.mails.count - 1 inSection:0]];
}

- (IBAction)segmentChange:(id)sender
{
    DLMailboxType type = (DLMailboxType)((UISegmentedControl *)sender).selectedSegmentIndex;
    self.fetcher.type = type;
    [self reload];
}


@end
