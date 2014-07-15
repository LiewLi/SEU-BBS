//
//  DLBBSAPIHelper.h
//  SEUBBS
//
//  Created by li liew on 7/1/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLBBSAPIHelper : NSObject

+ (void)fetchProfileImageForUser:(NSString *)userID complete:(void(^)(NSURL *, NSError *))block;
+ (void)loginForUser:(NSString *)userID WithPass:(NSString *)pass complete:(void (^)(NSString *, NSError *))block;
+ (void)fetchUserInfo:(NSString *)userID complete:(void(^)(NSDictionary *, NSError *))block;
+ (void)fetchHotTenWithCallBack:(void(^)(NSXMLParser *, NSError *))block __attribute__((deprecated("use fetchTopTenWithCallbck: instead")));
+ (void)fetchTopTenWithCallback:(void(^)(NSDictionary *, NSError *)) block;
+ (void)fetchRepliesCountForPost:(NSString *)postID atTopic:(NSString *)topic complete:(void (^)(NSString *, NSError *))block;

+ (NSURL *)topicPosWithID:(NSInteger)ID atBoard:(NSString *)board startAt:(NSInteger)start withLimit:(NSInteger)limit;

+ (void)postTopicAtBoard:(NSString *)board WithTitle:(NSString *)title Content:(NSString *)content Reid:(NSInteger)reid token:(NSString *)token complete:(void(^)(BOOL, NSString * board, NSInteger postID,  NSError*))block;
+ (void)postImage:(NSString *)imageFileName Image:(UIImage *)image toURL:(NSString *)url complete:(void(^)(BOOL success,NSError *error))block;
+ (void) fetchSectionsInfoWithComplete:(void (^)(NSArray *sections, NSError *error)) block;

+ (NSURL *)boardWithName:(NSString *)board startAt:(NSInteger)start withLimit:(NSInteger)limit;

+ (void)fetchFriendsWithComplete:(void(^)(NSArray *friends, NSError *error))block;
+ (void)deleteFriend:(NSString *)userID withComplete:(void(^)(BOOL success, NSError *error))block;
+ (void)addFriend:(NSString *)userID withComplete:(void(^)(BOOL success, NSError *error))block;
+ (NSURL *)mailboxURLForType:(NSInteger)type start:(NSInteger)start limit:(NSInteger)limit;
+ (void) mailContentForID:(NSInteger)mailID ofMailboxType:(NSInteger)type complete:(void (^)(BOOL, NSString *))block;
+ (void)sendMessageTo:(NSString *)userID reid:(NSInteger)reid title:(NSString *)title content:(NSString *)content complete:(void(^)(BOOL success))block;
+ (void)deleteMailFor:(NSInteger)mailID type:(NSInteger)mailboxType complete:(void(^)(BOOL))block;
@end
