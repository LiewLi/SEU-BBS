//
//  DLBoardModel.m
//  SEUBBS
//
//  Created by li liew on 7/10/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLBoardModel.h"

@interface DLBoardModel()
@property (nonatomic, strong)NSDictionary *board;
@end

@implementation DLBoardModel

- (instancetype)initWithInfo:(NSDictionary *)board
{
    if (self = [super init]) {
        _board = board;
    }
    
    return self;
}

- (NSArray *)boards
{
    return self.board[@"boards"];
}

- (NSString *)name
{
    return self.board[@"name"];
}

-(NSString *)description
{
    return self.board[@"description"];
}

-(NSInteger)count
{
    return [self.board[@"count"] integerValue];
}

-(BOOL)leaf
{
    return [self.board[@"leaf"] boolValue];
}

- (NSArray *)bm
{
    return self.board[@"bm"];
}

- (NSInteger)users
{
    return [self.board[@"users"] integerValue];
}
@end
