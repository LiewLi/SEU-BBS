//
//  DLUserModel.m
//  SEUBBS
//
//  Created by li liew on 7/2/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLUserModel.h"
#import "DLBBSAPIHelper.h"

@implementation DLUserModel
- (instancetype)initWithUserID:(NSString *)userID
{
    _userID = userID;
    if (self = [super init]) {
        [DLBBSAPIHelper fetchUserInfo:userID complete:^(NSDictionary *userInfo, NSError *error) {
            if (!error) {
                if (userInfo[@"avatar"] == [NSNull null]) {
                    _avatar = nil;
                } else {
                    _avatar = userInfo[@"avatar"];
                }
                _gender = userInfo[@"gender"];
                _experience = userInfo[@"experience"];
                _name = userInfo[@"name"];
            }
        }];
    }
    
    return self;
}

- (instancetype)initWithAnonymousUser
{
    if (self = [super init]) {
        _userID = @"Anonymous";
    }
    
    return self;
}
@end
