//
//  DLBoardTopicModel.h
//  SEUBBS
//
//  Created by li liew on 7/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLUserModel.h"
@interface DLBoardTopicModel : NSObject
@property (nonatomic, strong)DLUserModel *author;
@property (nonatomic, strong)NSString *board;
@property (nonatomic, assign)NSInteger postID;
@property (nonatomic, assign)NSInteger replyID;
@property (nonatomic, strong)NSDate *time;
@property (nonatomic, strong)NSString *title;
@property (nonatomic, assign)BOOL top;
@property (nonatomic, assign)NSInteger read;
@end
