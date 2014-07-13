//
//  DLBoardFetcher.m
//  SEUBBS
//
//  Created by li liew on 7/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLBoardFetcher.h"
#import "DLBBSAPIHelper.h"
#import "DLBoardTopicModel.h"

@interface DLBoardFetcher()
@property (nonatomic, strong)NSString *board;
@property (nonatomic, assign)NSInteger currentIndex;
@end

#define BATCH_FETCH 10

@implementation DLBoardFetcher
-(instancetype)initWithBoard:(NSString *)board
{
    if (self = [super init]) {
        _board = board;
    }
    
    return self;
}

- (void)reload
{
    self.currentIndex = 0;
}

-(NSArray *)fetchMoreBoardPosts
{
    NSMutableArray *more = [[NSMutableArray alloc]initWithCapacity:BATCH_FETCH];
    NSURL *url = [DLBBSAPIHelper boardWithName:self.board startAt:self.currentIndex withLimit:BATCH_FETCH];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error;
    NSDictionary *jsonDict = nil;
    if (data) {
        jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (!error) {
            NSArray *topics = jsonDict[@"topics"];
            for (NSDictionary *topic in topics) {
                DLBoardTopicModel *post = [[DLBoardTopicModel alloc] init];
                NSString *userID = topic[@"author"];
                if ([userID isEqualToString:@"Anonymous"]) {
                    post.author = [[DLUserModel alloc]initWithAnonymousUser];
                } else {
                    post.author = [[DLUserModel alloc]initWithUserID:userID];
                }
                
                NSTimeInterval timeInterval = [topic[@"time"] doubleValue];
                NSDate *time = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                post.time = time;
                post.postID = [topic[@"id"] integerValue];
                post.replyID = [topic[@"reid"] integerValue];
                post.board = topic[@"board"];
                post.title = topic[@"title"];
                post.read = [topic[@"read"] integerValue];
                post.top = [topic[@"top"] boolValue];
                
                NSLog(@"%@:%@", post.title,post.board);
                
                [more addObject:post];
            }
            
            self.currentIndex += more.count;
        }
    } else {
        return nil;
    }
    return more;
}
@end
