//
//  DLPostViewController.m
//  SEUBBS
//
//  Created by li liew on 7/3/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLPostViewController.h"
#import "DLPostTableViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "DLTopicPostModel.h"
#import "DLMultipleImageViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "DLBBSAPIHelper.h"

@interface DLPostViewController()<DLPostTableViewCellDelegate>
@property (nonatomic, strong)NSMutableArray *postItems;
@property (nonatomic, strong)NSCache *cache;
@property (nonatomic, strong)NSArray *positionName;
@property (nonatomic, strong)NSMutableDictionary *replayName;
@property (nonatomic, strong)NSMutableDictionary *position;
@property (nonatomic, strong)NSDateFormatter *dateFormatter;
@property (nonatomic, strong)NSShadow *shadow;
@end

@implementation DLPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.postItems = [[NSMutableArray alloc]init];
    self.cache = [[NSCache alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self tableView:self.tableView willDisplayCell:nil forRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:0]];
    self.positionName = @[@"楼主",@"沙发",@"藤椅",@"板凳", @"报纸", @"地板", @"下水道", @"垫砖"];
    self.replayName = [[NSMutableDictionary alloc]init];
    self.position = [[NSMutableDictionary alloc]init];
    
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setDateFormat:@"MMM dd, yyyy-h:mm"];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    self.shadow = [[NSShadow alloc] init];
    [self.shadow setShadowColor:[UIColor colorWithRed:0.053 green:0.088 blue:0.205 alpha:1.000]];
    [self.shadow setShadowBlurRadius:4.0];
    [self.shadow setShadowOffset:CGSizeMake(2, 2)];
    
    UIBarButtonItem *refreshBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"refreshIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(reload:)];
    self.navigationItem.rightBarButtonItem = refreshBarButton;

}

- (void)reload:(id)sender
{
    [self.postItems removeAllObjects];
    [self.tableView reloadData];
    [self.postFetcher reload];
    [self tableView:self.tableView willDisplayCell:nil forRowAtIndexPath:[NSIndexPath indexPathForRow:self.postItems.count - 1 inSection:0]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.sidePanelController.state == JASidePanelLeftVisible) {
        [self.sidePanelController toggleLeftPanel:self];
    }
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
    DLPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopicPostCell" forIndexPath:indexPath];
    
    DLTopicPostModel *item = (DLTopicPostModel *)self.postItems[indexPath.row];
    
    [self.position setObject:@(indexPath.row) forKey:@(item.postID)];

    NSMutableAttributedString *attrUserID = [[NSMutableAttributedString alloc]initWithString:item.author.userID];
    [attrUserID addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, attrUserID.length)];
    [cell.nameLabel setAttributedText:attrUserID];
    
    NSString *timeDescription = [self.dateFormatter stringFromDate:item.time];
    cell.timeLabel.text = timeDescription;
    
    cell.contentLabel.text = item.content;
    
    
    if (!item.attachments) {
        cell.viewImageButton.hidden = YES;
    } else {
        cell.viewImageButton.hidden = NO;
    }
    
    NSNumber *p = self.position[@(item.replyID)];
    NSInteger index = MIN(self.positionName.count - 1, indexPath.row);
    cell.positionLabel.text = [NSString stringWithFormat:@"第%ld楼(%@)", indexPath.row, self.positionName[index]];
    
    if (indexPath.row == 0 || [p integerValue] == 0 || !p) {
        if (indexPath.row == 0) {
            cell.positionLabel.text = @"楼主";
        } else {
            if (p) {
                if (indexPath.row != 0) {
                    cell.replyLablel.text = @"回复:楼主";
                }
            } else {
                cell.replyLablel.text = @"回复:(oops!原帖已删除)";
            }
        }
    
    } else {
        NSString* replayName =  [NSString stringWithFormat:@"回复:%@", (NSString *)self.replayName[@(item.replyID)]];
        if ([replayName compare:@"回复:Anonymous"] == NSOrderedSame) {
            replayName = [NSString stringWithFormat:@"回复:%@楼", self.position[@(item.replyID)]];
        } else {
            replayName = [replayName stringByAppendingString:[NSString stringWithFormat:@"(%@楼)", self.position[@(item.replyID)]]];
        }
        cell.replyLablel.text = replayName;
    }
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
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLTopicPostModel *item = (DLTopicPostModel *)self.postItems[indexPath.row];
    NSDictionary *atrr = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0]};
    CGRect labelSize;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        labelSize = [item.content boundingRectWithSize:CGSizeMake(824, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:atrr context:nil];
    } else {
        labelSize = [item.content boundingRectWithSize:CGSizeMake(568, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:atrr context:nil];
    }
    return labelSize.size.height + 200;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.postItems.count - 1) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadMore];
        });
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLTopicPostModel *item = (DLTopicPostModel *)self.postItems[indexPath.row];
    if (item.attachments) {
     [self viewImageAtIndexPath:indexPath];
    }
}

- (void)loadMore
{
    NSArray *more = [self.postFetcher fetchMorePosts];
    
    [self performSelectorOnMainThread:@selector(appendTableWith:) withObject:more waitUntilDone:NO];
}

- (void)appendTableWith:(NSArray *)more
{
    for (DLTopicPostModel* obj in more) {
        [self.postItems addObject:obj];
        [self.replayName setObject:obj.author.userID forKey:@(obj.postID)];
    }
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc]initWithCapacity:10];
    for (int idx = 0; idx < more.count; idx++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.postItems indexOfObject:more[idx]] inSection:0];
        [insertIndexPaths addObject:indexPath];
    }
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - DLPostTableViewCellDelegate
- (void)replyPostAtIndexPath:(NSIndexPath *)indexPath
{
    DLTopicPostModel *item = self.postItems[indexPath.row];
    DLPostReplyViewController *vc = (DLPostReplyViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DLPostReplyViewController"];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    vc.item = item;
    vc.postOrReply = @"回帖";
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)viewImageAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *images = ((DLTopicPostModel *)self.postItems[indexPath.row]).attachments;
    DLMultipleImageViewController *vc = [[DLMultipleImageViewController alloc]init];
    vc.images = images;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
