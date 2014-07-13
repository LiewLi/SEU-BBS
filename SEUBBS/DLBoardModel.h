//
//  DLBoardModel.h
//  SEUBBS
//
//  Created by li liew on 7/10/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLBoardModel : NSObject
-(instancetype)initWithInfo:(NSDictionary *)board;
@property (nonatomic, strong, readonly)NSArray *boards;
@property (nonatomic, strong, readonly)NSString *name;
@property (nonatomic, strong, readonly)NSString *description;
@property (nonatomic, assign, readonly)NSInteger count;
@property (nonatomic, assign, readonly)BOOL leaf;
@property (nonatomic,assign, readonly)NSArray *bm;
@property (nonatomic, assign, readonly)NSInteger users;

@end
