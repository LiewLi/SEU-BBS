//
//  DLTopicPostFetcher.h
//  SEUBBS
//
//  Created by li liew on 7/4/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLTopicPostFetcher : NSObject
- (instancetype)initWithTopicID:(NSInteger)ID atBoard:(NSString *)board;
-(NSArray *)fetchMorePosts;
- (void)reload;
@end
