//
//  DLPostReplyViewController.h
//  SEUBBS
//
//  Created by li liew on 7/7/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLTopicPostModel.h"

@class DLPostReplyViewController;

@interface DLPostReplyViewController : UIViewController<UITextViewDelegate>
- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)sendButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *postReplyTitleLabel;
@property(nonatomic, strong)NSString *postOrReply;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *replyTextView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
- (IBAction)uploadFileButtonTapped:(id)sender;
- (IBAction)cameraButtonTapped:(id)sender;
@property (nonatomic, strong)DLTopicPostModel *item;
@end
