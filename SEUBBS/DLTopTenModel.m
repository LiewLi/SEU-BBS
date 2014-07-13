//
//  DLTopTenModel.m
//  SEUBBS
//
//  Created by li liew on 7/3/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLTopTenModel.h"
#import "DLBBSAPIHelper.h"


@implementation DLTopTenModel
- (instancetype)init
{
    _topTen = [[NSMutableArray alloc] init];
    if (self = [super init]) {
        [DLBBSAPIHelper fetchTopTenWithCallback:^(NSDictionary *jsonDict, NSError *error) {
            if (! error) {
                NSArray *topics = jsonDict[@"topics"];
                for (NSDictionary *topic in topics) {
                    DLPostModel *post = [[DLPostModel alloc]init];
                    post.title = topic[@"title"];
                    post.board = topic[@"board"];
                    post.time = [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)topic[@"time"] doubleValue]];
                    post.postID = [(NSNumber *)topic[@"id"] integerValue];
                    post.read = [(NSNumber *)topic[@"read"] integerValue];
                    post.replies = [(NSNumber *)topic[@"replies"] integerValue];
                    if ([(NSString *)topic[@"author"] compare:@"Anonymous"] == NSOrderedSame) {
                        post.author = [[DLUserModel alloc]initWithAnonymousUser];
                    } else {
                        post.author = [[DLUserModel alloc] initWithUserID:topic[@"author"]];
                    }

                    [(NSMutableArray*)_topTen addObject:post];
                   // NSLog(@"\n%@\n%@\n%f\n%ld\n%ld\n%ld\n", post.title, post.board, post.time, post.postID, post.read, post.replies);
                }
            }
        }];
    }
    return self;
}
@end
