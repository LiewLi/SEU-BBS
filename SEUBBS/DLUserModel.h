//
//  DLUserModel.h
//  SEUBBS
//
//  Created by li liew on 7/2/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLUserModel : NSObject
-(instancetype)initWithUserID:(NSString *)userID;
-(instancetype)initWithAnonymousUser;
@property (nonatomic, strong)NSString *userID;
@property (nonatomic, strong)NSString *gender;
@property (nonatomic, strong)NSString *avatar;
@property (nonatomic, strong)NSString *experience;
@property (nonatomic, strong)NSString *name;
@end
