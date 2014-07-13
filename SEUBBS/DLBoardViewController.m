//
//  DLBoardViewController.m
//  SEUBBS
//
//  Created by li liew on 7/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLBoardViewController.h"
#import "DLBoardTableViewCell.h"
#import "DLBoardTopicModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "DLPostViewController.h"
#import "DLPostReplyViewController.h"

@interface DLBoardViewController()
@property (nonatomic, strong)NSMutableArray *postItems;
@property (nonatomic, strong)NSShadow *shadow;
@property (nonatomic,strong)NSDateFormatter *dateFormatter;
@end
@implementation DLBoardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.postItems = [[NSMutableArray alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setDateFormat:@"MMM dd, yyyy-h:mm"];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    self.shadow = [[NSShadow alloc] init];
    [self.shadow setShadowColor:[UIColor colorWithRed:0.053 green:0.088 blue:0.205 alpha:1.000]];
    [self.shadow setShadowBlurRadius:4.0];
    [self.shadow setShadowOffset:CGSizeMake(2, 2)];
    
    UIBarButtonItem *addPostBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"addPost"] style:UIBarButtonItemStylePlain target:self action:@selector(addPost:)];
    self.navigationItem.rightBarButtonItem = addPostBarButton;

    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"刷新..."];

    
    [self tableView:self.tableView willDisplayCell:nil forRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:0]];
    
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"TOKEN"];
    NSLog(@"%@", token);
    
    
}

- (void)reload:(id)sender
{
    [self.refreshControl beginRefreshing];
    [self.postItems removeAllObjects];
    [self.tableView reloadData];
    [self.postFetcher reload];
    [self tableView:self.tableView willDisplayCell:nil forRowAtIndexPath:[NSIndexPath indexPathForRow:self.postItems.count - 1 inSection:0]];
    [self.refreshControl endRefreshing];
}


- (void)addPost:(id)sender
{
    DLTopicPostModel *item = [[DLTopicPostModel alloc]init];
    item.board = ((DLBoardTopicModel *)(self.postItems[0])).board;
    item.postID = 0;
    item.title = @"";
    NSLog(@"%@:%ld", item.board, item.postID);
    
    DLPostReplyViewController *vc = (DLPostReplyViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DLPostReplyViewController"];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    vc.item = item;
    vc.postOrReply = @"发帖";
    [self presentViewController:vc animated:YES completion:nil];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.postItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLBoardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DLBoardTableViewCell" forIndexPath:indexPath];
    
    DLBoardTopicModel *item = (DLBoardTopicModel *)self.postItems[indexPath.row];
    NSMutableAttributedString *attrUserID = [[NSMutableAttributedString alloc]initWithString:item.author.userID];
    [attrUserID addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, attrUserID.length)];
    [cell.nameLabel setAttributedText:attrUserID];
    
    
    NSString *timeDescription = [self.dateFormatter stringFromDate:item.time];
    cell.timeLabel.text = timeDescription;

    cell.titleLabel.text = item.title;
    
    cell.topLabel.text = item.top ? @"Top" : @"";
    cell.readLabel.text = [NSString stringWithFormat:@"%ld", item.read];
    
    if ([item.author.userID compare:@"Anonymous"] != NSOrderedSame) {
        [cell.profileImageView setImageWithURL:[NSURL URLWithString:item.author.avatar] placeholderImage:[UIImage imageNamed:@"loginDefaultUser"]];
        if (item.author.gender && [item.author.gender compare:@"F"] == NSOrderedSame) {
            cell.genderImageView.image = [UIImage imageNamed:@"female"];
        }
        else if (item.author.gender && [item.author.gender compare:@"M"] == NSOrderedSame){
            cell.genderImageView.image = [UIImage imageNamed:@"male"];
        } else {
            cell.genderImageView.image = nil;
        }
        if (item.author.experience) {
            cell.experienceLabel.text = item.author.experience;
        } else {
            cell.experienceLabel.text = @"";
        }
    } else {
        cell.profileImageView.image = [UIImage imageNamed:@"loginDefaultUser"];
        cell.genderImageView.image = nil;
        cell.experienceLabel.text = @"";
    }
    

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLBoardTopicModel *item = (DLBoardTopicModel *)self.postItems[indexPath.row];
    NSDictionary *atrr = @{NSFontAttributeName:[UIFont systemFontOfSize:16.0]};
    CGRect labelSize;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        labelSize = [item.title boundingRectWithSize:CGSizeMake(1024, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:atrr context:nil];
    } else {
        labelSize = [item.title boundingRectWithSize:CGSizeMake(768, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:atrr context:nil];
    }
    return labelSize.size.height + 140;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.postItems.count -1) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadMore];
        });
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLBoardTopicModel *item = (DLBoardTopicModel *)self.postItems[indexPath.row];
    DLPostViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PostViewController"];
    DLTopicPostFetcher *fetcher = [[DLTopicPostFetcher alloc]initWithTopicID:item.postID atBoard:item.board];
    vc.postFetcher = fetcher;
    vc.title = item.title;
    NSLog(@"%ld:%@", item.postID, item.board);
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadMore
{
    NSArray *more = [self.postFetcher fetchMoreBoardPosts];

    [self performSelectorOnMainThread:@selector(appendTableWith:) withObject:more waitUntilDone:NO];
}


- (void)appendTableWith:(NSArray *)more
{
    for (DLBoardTopicModel* obj in more) {
        [self.postItems addObject:obj];
    }
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc]initWithCapacity:10];
    for (int idx = 0; idx < more.count; idx++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.postItems indexOfObject:more[idx]] inSection:0];
        [insertIndexPaths addObject:indexPath];
    }
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
}

@end
