//
//  DLBBSAPIHelper.m
//  SEUBBS
//
//  Created by li liew on 7/1/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLBBSAPIHelper.h"
#import <AFNetworking/AFNetworking.h>
static NSString *rootURL = @"http://bbs.seu.edu.cn/api/";
#import "DLUserModel.h"

@interface DLBBSAPIHelper()
@property (nonatomic, strong)NSURLSession *session;
@end

@implementation DLBBSAPIHelper


+ (void)addFriend:(NSString *)userID withComplete:(void (^)(BOOL, NSError *))block
{
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"TOKEN"];
    NSString *urlStr = [NSString stringWithFormat:@"http://bbs.seu.edu.cn/api/friends/add.json?token=%@&id=%@", token, userID];
    NSURL *url = [NSURL URLWithString:urlStr];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url]];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonDict = (NSDictionary *)responseObject;
        BOOL success = [jsonDict[@"success"] boolValue];
        if (block) {
            block(success, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(NO, error);
        }
    }];
    [operation start];
}

+ (void)deleteFriend:(NSString *)userID withComplete:(void (^)(BOOL, NSError *))block
{
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"TOKEN"];
    NSString *urlStr = [NSString stringWithFormat:@"http://bbs.seu.edu.cn/api/friends/delete.json?token=%@&id=%@", token, userID];
    NSURL *url = [NSURL URLWithString:urlStr];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:[NSURLRequest requestWithURL:url]];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonDict = (NSDictionary *)responseObject;
        BOOL success = [jsonDict[@"success"] boolValue];
        if (block) {
            block(success, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(NO, error);
        }
    }];
    [operation start];
}

+ (void)fetchFriendsWithComplete:(void (^)(NSArray *, NSError *))block
{
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"TOKEN"];
    NSString *urlStr = [NSString stringWithFormat:@"http://bbs.seu.edu.cn/api/friends/all.json?token=%@", token];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:[NSURLRequest requestWithURL:url]];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonDict = (NSDictionary *)responseObject;
        NSMutableArray *friends = [[NSMutableArray alloc]init];
        if ([jsonDict[@"success"] boolValue]) {
            NSArray *array = jsonDict[@"friends"];
            for (NSDictionary *friend in array) {
                DLUserModel *user = [[DLUserModel alloc]init];
                user.userID = friend[@"id"];
                user.name = friend[@"name"];
                NSString *imageLoc = friend[@"avatar"];
                imageLoc = [imageLoc stringByReplacingOccurrencesOfString:@"wForum" withString:@"nForum"];
                if ([imageLoc isEqualToString:@"http://bbs.seu.edu.cn/nForum/"]) {
                    imageLoc = nil;
                }
                else {
                    user.avatar = imageLoc;
                }
                [friends addObject:user];
            }
            if (block) {
                block(friends, nil);
            }
        } else {
            if (block) {
                block(friends, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
    [operation start];
    
}

+ (NSURL *)topicPosWithID:(NSInteger)ID atBoard:(NSString *)board startAt:(NSInteger)start withLimit:(NSInteger)limit
{
    NSString *urlStr = [NSString stringWithFormat:@"http://bbs.seu.edu.cn/api/topic/%@/%ld.json?&start=%ld&limit=%ld",board, ID, start, limit];
  //  NSLog(@"%@\n", urlStr);
    return [NSURL URLWithString:urlStr];
}

+ (NSURL *)boardWithName:(NSString *)board startAt:(NSInteger)start withLimit:(NSInteger)limit
{
    NSString *urlStr = [NSString stringWithFormat:@"http://bbs.seu.edu.cn/api/board/%@.json?mode=1&start=%ld&limit=%ld",board, start, limit];
    return [NSURL URLWithString:urlStr];
}

+ (NSURL *)rootURL
{
    return [NSURL URLWithString:rootURL];
}

+ (void)loginForUser:(NSString *)userID WithPass:(NSString *)pass complete:(void (^)(NSString *, NSError *))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"user":userID, @"pass":pass};
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:@"http://bbs.seu.edu.cn/api/token.json" parameters:params constructingBodyWithBlock:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *jsonDict = (NSDictionary *)responseObject;
              if (jsonDict[@"success"]) {
                  if (block) {
                      block(jsonDict[@"token"], nil);
                  }
              } else {
                  if (block) {
                      block(nil, nil);
                  }
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (block) {
                  block(nil, error);
              }
              NSLog(@"fetch token faield");
          }];
}

+ (void)fetchProfileImageForUser:(NSString *)userID complete:(void(^)(NSURL * , NSError *))block
{
    NSLog(@"starting fetching profile image for user: %@", userID);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"user/%@.json", userID] relativeToURL:[self rootURL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    __block NSURL * imageUrl;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"fetch user meta data succeed");
        NSDictionary *jsonDict = (NSDictionary *)responseObject;
        NSString* imageLoc = (jsonDict[@"user"])[@"avatar"];
        imageLoc = [imageLoc stringByReplacingOccurrencesOfString:@"wForum" withString:@"nForum"];
        imageLoc = [imageLoc stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        imageUrl = [NSURL URLWithString:imageLoc];
        NSLog(@"user profile image url: %@", imageUrl);
        if (block) {
            block(imageUrl, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fetch user profile image url failed: %@", [error localizedDescription]);
        if (block) {
            block(nil, error);
        }
    }];
    [operation start];
}

+ (void)fetchUserInfo:(NSString *)userID complete:(void (^)(NSDictionary *, NSError *))block
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"user/%@.json", userID] relativeToURL:[self rootURL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonDict = (NSDictionary *)responseObject;
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        NSString* imageLoc = (jsonDict[@"user"])[@"avatar"];
        imageLoc = [imageLoc stringByReplacingOccurrencesOfString:@"wForum" withString:@"nForum"];
        if ([imageLoc compare:@"http://bbs.edu.edu.cn/nForum"] == NSOrderedSame) {
            [userInfo setObject:[NSNull null] forKey:@"avatar"];
        } else {
            [userInfo setObject:imageLoc forKey:@"avatar"];
        }
        if (jsonDict[@"user"][@"gender"]) {
            [userInfo setObject:jsonDict[@"user"][@"gender"] forKey:@"gender"];
        } else {
            [userInfo setObject:@"U" forKey:@"gender"];
        }

        NSInteger exp = [(NSNumber *) jsonDict[@"user"][@"experience"] integerValue];
        NSString *expStr = [NSString stringWithFormat:@"%ld", exp];
        [userInfo setObject:expStr forKey:@"experience"];
       // NSLog(@"%@ : %@ : %@\n", userInfo[@"avatar"], userInfo[@"gender"], userInfo[@"experience"]);
        if (block) {
            block(userInfo, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fectch user info faild: %@", [error localizedDescription]);
        if (block) {
            block(nil, error);
        }
    }];
    [operation start];
   
}

+ (void)fetchRepliesCountForPost:(NSString *)postID atTopic:(NSString *)topic complete:(void (^)(NSString *, NSError *error))block
{
    NSString *urlStr = [NSString stringWithFormat:@"http://bbs.seu.edu.cn/api/topic/%@/%@.json", topic, postID];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonDiction = (NSDictionary *)responseObject;
        NSInteger replies = ((NSArray *)jsonDiction[@"topics"]).count;
      //  NSLog(@"%ld\n", replies);
        if (block) {
            block([NSString stringWithFormat:@"%ld", replies], nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"fetch replies %@:%@ failed: %@", topic, postID, [error localizedDescription]);
        if (block) {
            block(nil, error);
        }
    }];
    [operation start];

}

+ (void)fetchTopTenWithCallback:(void (^)(NSDictionary *, NSError *))block
{
    NSURL *url = [NSURL URLWithString:@"http://bbs.seu.edu.cn/api/hot/topten.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonDict = (NSDictionary *)responseObject;
        if (block) {
            block(jsonDict, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"faield to fetch top ten: %@, %@", [error localizedDescription], error.domain);
        if (block) {
            block(nil, error);
        }
    }];
    
    [operation start];

}

// fetch topTen based on rss
+ (void)fetchHotTenWithCallBack:(void (^)(NSXMLParser *, NSError *))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:@"http://bbs.seu.edu.cn/nForum/rss/topten"];
        NSData *data = [[NSData alloc]initWithContentsOfURL:url];
        NSData *xmlData = [data subdataWithRange:NSMakeRange(0, 40)];
        NSString *xmlString = [[NSString alloc]initWithData:xmlData encoding:NSUTF8StringEncoding];
        
        if ([xmlString rangeOfString:xmlString options:NSCaseInsensitiveSearch].location != NSNotFound) {
            NSLog(@"GB2312 encoding found");
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *utf8Str = [[NSString alloc] initWithData:data encoding:enc];
           utf8Str = [utf8Str stringByReplacingOccurrencesOfString:@"\"gb2312\"" withString:@"\"utf8\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 40)];
            data = [utf8Str dataUsingEncoding:NSUTF8StringEncoding];
        }
        NSXMLParser *xmlParser = [[NSXMLParser alloc]initWithData:data];
        if (block) {
            block(xmlParser, nil);
        }
    });
}

+ (void)postTopicAtBoard:(NSString *)board WithTitle:(NSString *)title Content:(NSString *)content Reid:(NSInteger )reid token:(NSString *)token complete:(void (^)(BOOL,NSString*, NSInteger, NSError *))block
{
    NSMutableString * baseurl = [@"http://bbs.seu.edu.cn/api/topic/post.json?" mutableCopy];
    [baseurl appendFormat:@"token=%@",token];
    [baseurl appendFormat:@"&board=%@",board];
    [baseurl appendFormat:@"&title=%@",title];
    [baseurl appendFormat:@"&content=%@",content];
    [baseurl appendFormat:@"&reid=%ld",reid];
    [baseurl appendFormat:@"&type=%i",3];
    NSString * urlStr = [baseurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
   [request setHTTPMethod:@"POST"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonDict = (NSDictionary *)responseObject;
        BOOL success = [jsonDict[@"success"] boolValue];
        if (!success) {
            NSLog(@"post not succeed:%@", (NSString *)jsonDict[@"error"]);
            if (block) {
                block(success, nil, 0, nil);
            }
        } else {
            if (block) {
                NSInteger postID = [jsonDict[@"topic"][@"id"] integerValue];
                NSString *board = jsonDict[@"topic"][@"board"];
//                NSLog(@"board:%@ id:%@", jsonDict[@"topic"][@"board"], jsonDict[@"topic"][@"id"]);
                block(success, board, postID, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error %@", [error localizedDescription]);
        if (block) {
            block(NO, nil, 0, error);
        }
    }];
    
    [operation start];
}

+ (void)postImage:(NSString *)imageFileName Image:(UIImage *)image toURL:(NSString *)url complete:(void (^)(BOOL, NSError *))block
{
    static int count = 0; // in case imagefile name with different ext cause upload fail;
    count++;
    imageFileName = [NSString stringWithFormat:@"IMG_%i_%@", count, imageFileName];
    NSString *fileExt = [imageFileName pathExtension];
    NSString *file = [imageFileName stringByReplacingOccurrencesOfString:fileExt withString:@""];
    NSData *imgData = nil;
    NSString *mimeType = @"image/png"; // default
    if (([fileExt compare:@"jpg" options: NSCaseInsensitiveSearch] == NSOrderedSame) || ([fileExt compare:@"JPEG" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
        imgData = UIImageJPEGRepresentation(image, 0.5);
        mimeType = @"image/jpeg";
        file = [file stringByAppendingString:@"jpg"];
    } else if (([fileExt compare:@"png" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
        imgData = UIImagePNGRepresentation(image);
        file = [file stringByAppendingString:@"png"];
    } else {
        imgData = UIImagePNGRepresentation(image);
        file = [file stringByAppendingString:@"png"];
    }
    if (imgData) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"file": imageFileName};
        [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imgData name:@"file" fileName:file mimeType:mimeType];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *jsonDict = (NSDictionary *)responseObject;
            BOOL success = [jsonDict[@"success"] boolValue];
            if (block) {
                if (!success) {
                    NSLog(@"error %@", jsonDict[@"error"]);
                }
                block(success, nil);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error to post image %@\n", [error localizedDescription]);
            if (block) {
                block(NO, error);
            }
        }];
    }
//    NSLog(@"%@", fileExt);
}

+ (void)fetchSectionsInfoWithComplete:(void (^)(NSArray *, NSError *))block
{
    NSURL *url = [NSURL URLWithString:@"http://bbs.seu.edu.cn/api/sections.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonDict = (NSDictionary *)responseObject;
        NSArray *boards = jsonDict[@"boards"];
        if (block) {
            block(boards, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fetch sections error %@", [error localizedDescription]);
        if (block) {
            block(nil, error);
        }
    }];
    [operation start];
}
@end
