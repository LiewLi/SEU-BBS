//
//  DLHotTenViewController.m
//  SEUBBS
//
//  Created by li liew on 7/2/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLHotTenViewController.h"
#import "DLHotTenTableViewCell.h"
#import "DLTopTenModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "DLTimer.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "DLTopicPostFetcher.h"
#import "DLPostViewController.h"
#import "UIViewController+JASidePanel.h"

@interface DLHotTenViewController()
@property (nonatomic, assign) CATransform3D initialTransformation;
@property (nonatomic, strong)DLTopTenModel *topTen;
@property (nonatomic, strong)NSCache *cache;
@property (nonatomic, assign)NSInteger refreshCount;
@property (nonatomic, strong)DLTimer *timer;
@property (nonatomic, strong)NSShadow *shadow;
@property (nonatomic, strong)NSMutableSet *shownIndex;
@property (nonatomic, strong)NSDateFormatter *dateFormatter;
@property (nonatomic, strong)DLTopTenModel *previousFetch;
@end
@implementation DLHotTenViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat rotationAngleDegrees = -15;
    CGFloat rotationAngleRadians = rotationAngleDegrees * (M_PI / 180);
    CGPoint offsetPosition = CGPointMake(-20, -20);
    
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, rotationAngleRadians, 0.0, 0.0, 1.0);
    transform = CATransform3DTranslate(transform, offsetPosition.x, offsetPosition.y, 0.0);
    _initialTransformation = transform;
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(loadHotTen) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"刷新..."];
    
    self.topTen = [[DLTopTenModel alloc]init];
    self.cache = [[NSCache alloc]init];
    self.shownIndex = [[NSMutableSet alloc]init];
    __weak DLHotTenViewController *weakSelf = self;
    self.timer = [DLTimer repeatingTimerWithTimerInterval:1 block:^{
        [weakSelf loadData];
        [weakSelf.tableView reloadData];
        [weakSelf.timer invalidate];
    }];

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.13 green:0.36 blue:0.62 alpha:1.0];
  //  [self.sidePanelController showLeftPanelAnimated:YES];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.title = @"今日十大";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refreshIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(refresh:)];
    self.navigationItem.rightBarButtonItem = item;
    
    self.shadow = [[NSShadow alloc] init];
    [self.shadow setShadowColor:[UIColor colorWithRed:0.053 green:0.088 blue:0.205 alpha:1.000]];
    [self.shadow setShadowBlurRadius:4.0];
    [self.shadow setShadowOffset:CGSizeMake(2, 2)];
    
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setDateFormat:@"MMM dd, yyyy-h:mm"];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.sidePanelController.state != JASidePanelLeftVisible) {
        [self.sidePanelController showLeftPanelAnimated:NO];
    }

}

- (void)refresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    CGPoint size = self.tableView.contentOffset;
    [UIView animateWithDuration:0.5f animations:^{
        [self.tableView setContentOffset:CGPointMake(0.0, -200.0f)];
        [self loadHotTen];
    } completion:^(BOOL finished) {
       [self.tableView setContentOffset:size];
        [self.refreshControl endRefreshing];
    }];
}

-(void)loadData
{
    self.refreshCount++;
    self.refreshCount %= 3;
    if (self.refreshCount == 2) {
        self.previousFetch = self.topTen;
        self.topTen = [[DLTopTenModel alloc]init];
    }
}



- (void)loadHotTen
{
    
    [self.refreshControl beginRefreshing];
    __weak DLHotTenViewController *weakSelf = self;
    self.timer = [DLTimer repeatingTimerWithTimerInterval:1 block:^{
        [weakSelf loadData];
        [weakSelf.tableView reloadData];
        [weakSelf.timer invalidate];
        [weakSelf.refreshControl endRefreshing];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return MAX(self.topTen.topTen.count, self.previousFetch.topTen.count);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLHotTenTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HotTen" forIndexPath:indexPath];
    DLPostModel *item;
    if (self.topTen.topTen.count) {
        item = (DLPostModel *)self.topTen.topTen[indexPath.row];
    } else {
        item = (DLPostModel *)self.previousFetch.topTen[indexPath.row];
    }

    NSMutableAttributedString *attrUserID = [[NSMutableAttributedString alloc]initWithString:item.author.userID];
    [attrUserID addAttribute:NSShadowAttributeName value:self.shadow range:NSMakeRange(0, attrUserID.length)];
    [cell.userNameLabel setAttributedText:attrUserID];
    
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
    cell.titleLabel.text = item.title;
    NSString *timeDescription = [self.dateFormatter stringFromDate:item.time];
    cell.pubDateLabel.text = timeDescription;
    cell.replyCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", item.replies, item.read];
    cell.boardLabel.text = item.board;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sidePanelController.state == JASidePanelLeftVisible) {
        [self.sidePanelController toggleLeftPanel:self];
    }
    DLPostViewController *postVC = (DLPostViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PostViewController"];
    DLPostModel *item = (DLPostModel *)self.topTen.topTen[indexPath.row];
    DLTopicPostFetcher *postFetcher = [[DLTopicPostFetcher alloc]initWithTopicID:item.postID atBoard:item.board];
 //   NSLog(@"view detail %@ : %ld", item.board, item.postID);
    postVC.postFetcher = postFetcher;
    postVC.title = item.title;
    [self.navigationController pushViewController:postVC animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DLPostModel *item = self.topTen.topTen.count?self.topTen.topTen[indexPath.row]:self.previousFetch.topTen[indexPath.row];
    NSDictionary *atrr = @{NSFontAttributeName:[UIFont systemFontOfSize:20.0]};
    CGRect labelSize;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        labelSize = [item.title boundingRectWithSize:CGSizeMake(700.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:atrr context:nil];
    } else {
        labelSize = [item.title boundingRectWithSize:CGSizeMake(450, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:atrr context:nil];
    }
    return labelSize.size.height + 200;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.shownIndex containsObject:indexPath]) {
        [self.shownIndex addObject:indexPath];
        UIView *card = [(DLHotTenTableViewCell *) cell masterView];
        card.layer.transform = self.initialTransformation;
        card.layer.opacity = 0.5;
        
        [UIView animateWithDuration:0.4 animations:^{
            
            card.layer.transform = CATransform3DIdentity;
            card.layer.opacity = 1.0;
        }];

    }
}
@end
