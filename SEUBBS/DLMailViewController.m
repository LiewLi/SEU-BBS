//
//  DLMailViewController.m
//  SEUBBS
//
//  Created by li liew on 7/15/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLMailViewController.h"
#import "DLMailTitleTableViewCell.h"
#import "DLMailContentTableViewCell.h"
#import "DLBBSAPIHelper.h"

@interface DLMailViewController ()
@property (nonatomic, strong)NSString *content;
@end

@implementation DLMailViewController

-  (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [DLBBSAPIHelper mailContentForID:self.mailID ofMailboxType:self.mailType complete:^(BOOL success, NSString * content) {
        if (success) {
            self.content = content;
            [self.tableView reloadData];
        }
    }];
    
    UIBarButtonItem *reply = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"reply"] style:UIBarButtonItemStyleDone target:self action:@selector(reply:)];
    self.navigationItem.rightBarButtonItem = reply;
}

- (void)reply:(id)sender
{
    //TODO: reply message
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DLMailTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DLMailTitleCell" forIndexPath:indexPath];
        cell.timeLabel.text = self.time;
        cell.titleLabel.text = self.title;
        cell.authorLabel.text = self.author;
        return cell;
    } else {
        DLMailContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DLMailContentCell" forIndexPath:indexPath];
        cell.contentLabel.text = self.content;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSDictionary *atrr = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0]};
        CGRect labelSize;
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            labelSize = [self.title boundingRectWithSize:CGSizeMake(768, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:atrr context:nil];
        } else {
            labelSize = [self.title boundingRectWithSize:CGSizeMake(1024, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:atrr context:nil];
        }
        return labelSize.size.height + 50;
    } else {
        NSDictionary *atrr = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0]};
        CGRect labelSize;
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            labelSize = [self.content boundingRectWithSize:CGSizeMake(1024, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:atrr context:nil];
        } else {
            labelSize = [self.content boundingRectWithSize:CGSizeMake(768, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:atrr context:nil];
        }
        return labelSize.size.height + 10;
    }
  
}
@end
