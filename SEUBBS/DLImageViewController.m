//
//  DLImageViewController.m
//  SEUBBS
//
//  Created by li liew on 7/5/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLImageViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "DLAttachmentModel.h"

@interface DLImageViewController()
@end

@implementation DLImageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)loadView
{
    ImageScrollView *scrollView = [[ImageScrollView alloc] init];
    
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    NSURL *url = [NSURL URLWithString:self.image.fileURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:[NSURLRequest requestWithURL:url]];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        scrollView.image = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error %@", [error localizedDescription]);
    }];
    
    [operation start];

    self.view = scrollView;
}


@end
