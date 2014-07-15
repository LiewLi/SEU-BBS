//
//  DLMailboxFetcher.h
//  SEUBBS
//
//  Created by li liew on 7/15/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DLMailboxType) {
    DLMailboxTypeInbox,
    DLMailboxTypeOutbox,
    DLMailboxTypeDeleted,
};

@interface DLMailboxFetcher : NSObject
- (NSArray *)fetchMore;
- (void)reload;
@property (nonatomic, assign)DLMailboxType type;
@end
