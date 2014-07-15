//
//  DLMailboxFetcher.m
//  SEUBBS
//
//  Created by li liew on 7/15/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLMailboxFetcher.h"
#import "DLBBSAPIHelper.h"
#import "DLMailboxModel.h"

@interface DLMailboxFetcher()
@property (nonatomic, assign)NSInteger currentIndex;
@end

@implementation DLMailboxFetcher

- (void)setType:(DLMailboxType)type
{
    if (self.type != type) {
        _type = type;
        [self reload];
    }
}


#define BATCH_FETCH 10
- (NSArray *)fetchMore
{
    NSMutableArray *more = [[NSMutableArray alloc]initWithCapacity:BATCH_FETCH];
    NSURL *url = [DLBBSAPIHelper mailboxURLForType:self.type start:self.currentIndex limit:BATCH_FETCH];
    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    NSError *error;
    NSDictionary *jsonDict = nil;
    if (jsonData) {
        jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        if (!error) {
            BOOL success = [jsonDict[@"success"] boolValue];
            if (success) {
                NSArray *mails = jsonDict[@"mails"];
                for (NSDictionary *mail in mails) {
                    DLMailboxModel *item = [[DLMailboxModel alloc]init];
                    item.author = mail[@"author"];
                    item.mailID = [mail[@"id"] integerValue];
                    item.title = mail[@"title"];
                    item.unread = [mail[@"unread"] boolValue];
                    NSTimeInterval interval = [mail[@"time"] floatValue];
                    NSDate *time = [NSDate dateWithTimeIntervalSince1970:interval];
                    item.time = time;
                    [more addObject:item];
                }
                
                self.currentIndex += more.count;
            } else {
                return nil;
            }
        }
    } else {
        return nil;
    }
    return more;
}

- (void)reload
{
    self.currentIndex = 0;
}
@end
