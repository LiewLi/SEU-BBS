//
//  DLBoardFetcher.h
//  SEUBBS
//
//  Created by li liew on 7/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLBoardFetcher : NSObject
- (instancetype)initWithBoard:(NSString *)board;
- (NSArray *)fetchMoreBoardPosts;

-(void)reload;
@end
