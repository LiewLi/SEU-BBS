//
//  DLPostModel.h
//  SEUBBS
//
//  Created by li liew on 7/3/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLUserModel.h"

@interface DLPostModel : NSObject
@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)DLUserModel *author;
@property (nonatomic, strong)NSString *board;
@property (nonatomic, assign)NSInteger postID;
@property (nonatomic, strong)NSDate *time;
@property (nonatomic, assign)NSInteger replies;
@property (nonatomic, assign)NSInteger read;
@end
