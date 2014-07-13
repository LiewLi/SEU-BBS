//
//  DLTopicPostFetcher.m
//  SEUBBS
//
//  Created by li liew on 7/4/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLTopicPostFetcher.h"
#import "DLBBSAPIHelper.h"
#import "DLTopicPostModel.h"

#define BATCH_FETCH 10

@interface DLTopicPostFetcher()
@property (nonatomic, assign)NSInteger currentIndex;
@property (nonatomic, assign)NSInteger postID;
@property (nonatomic, assign)NSString *board;
@end

@implementation DLTopicPostFetcher
- (instancetype)initWithTopicID:(NSInteger)ID atBoard:(NSString *)board
{
    if (self = [super init]) {
        _postID = ID;
        _board = board;
        _currentIndex = 0;
    }
    
    return self;
}

- (void)reload
{
    self.currentIndex = 0;
}
- (NSArray *)fetchMorePosts
{
    NSMutableArray *more = [[NSMutableArray alloc]initWithCapacity:BATCH_FETCH];
    NSURL *url = [DLBBSAPIHelper topicPosWithID:self.postID atBoard:self.board startAt:self.currentIndex withLimit:BATCH_FETCH];
    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    NSError *error;
    NSDictionary *jsonDict = nil;
    if (jsonData) {
        jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        if (!error) {
            NSArray *topics = jsonDict[@"topics"];
            for (NSDictionary *topic in topics) {
                DLTopicPostModel *post = [[DLTopicPostModel alloc] init];
                NSString *userID = topic[@"author"];
        //        NSLog(@"%@ post", userID);
                if ([userID compare:@"Anonymous"] == NSOrderedSame) {
                    post.author = [[DLUserModel alloc]initWithAnonymousUser];
                } else {
                    post.author = [[DLUserModel alloc]initWithUserID:userID];
                }
                post.content = topic[@"content"];
                NSTimeInterval timeInterval = [(NSNumber *)topic[@"time"] doubleValue];
                NSDate *time = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                post.time = time;
                post.postID = [(NSNumber *)topic[@"id"] integerValue];
                post.replyID = [(NSNumber *)topic[@"reid"] integerValue];
                post.board = topic[@"board"];
                post.title = topic[@"title"];
     //           NSLog(@"%ld %ld\n", post.postID, post.replyID);
                
                NSArray *attachments = topic[@"attachments"];
                NSMutableArray *attachFiles = [[NSMutableArray alloc]init];
                for (NSDictionary *attach in attachments) {
                    DLAttachmentModel *file = [[DLAttachmentModel alloc]init];
                    file.fileName = attach[@"filename"];
                    file.fileURL = attach[@"url"];
                    [attachFiles addObject:file];
                    
       //            NSLog(@"attach file: %@ : %@", file.fileName, file.fileURL);
                }
                
                if (attachments.count == 0) {
                    post.attachments = nil;
                } else {
                    post.attachments = attachFiles;
                }
                
                [more addObject:post];
            }
            self.currentIndex += more.count;
        }else {
            return nil;
        }
    }
 //   NSLog(@"current post index: %ld\n",self.currentIndex);
    return more;
}

@end
