//
//  DLTopicPostModel.h
//  SEUBBS
//
//  Created by li liew on 7/4/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLUserModel.h"
#import "DLAttachmentModel.h"
@interface DLTopicPostModel : NSObject
@property (nonatomic, strong)DLUserModel *author;
@property (nonatomic, strong)NSString *content;
@property (nonatomic, strong)NSDate *time;
@property (nonatomic, assign)NSInteger postID;
@property (nonatomic, assign)NSInteger replyID;
@property (nonatomic, strong)NSArray *attachments;
@property (nonatomic, strong)NSString *board;
@property (nonatomic, strong)NSString *title;
@end
