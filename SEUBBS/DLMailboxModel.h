//
//  DLMailboxModel.h
//  SEUBBS
//
//  Created by li liew on 7/15/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLMailboxModel : NSObject
@property (nonatomic, strong)NSString *author;
@property (nonatomic, assign)NSInteger mailID;
@property (nonatomic, strong)NSDate *time;
@property (nonatomic, strong)NSString *title;
@property (nonatomic, assign)BOOL unread;
@end
