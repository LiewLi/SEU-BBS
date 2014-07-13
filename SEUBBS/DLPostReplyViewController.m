//
//  DLPostReplyViewController.m
//  SEUBBS
//
//  Created by li liew on 7/7/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLPostReplyViewController.h"
#import "DLBBSAPIHelper.h"
#import <Toast/Toast+UIView.h>
#import "ELCImagePickerController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface DLPostReplyViewController() <ELCImagePickerControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong)NSMutableArray *info;
@end

@implementation DLPostReplyViewController 
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleTextField.text = self.item.title;
    [self.replyTextView becomeFirstResponder];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
    self.replyTextView.delegate = self;
    self.replyTextView.text = @"说点什么吧...";
    self.replyTextView.textColor = [UIColor lightGrayColor];
    self.sendButton.enabled = NO;
    
    self.info = [[NSMutableArray alloc]init];
    
    self.postReplyTitleLabel.text = self.postOrReply;
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendButtonTapped:(id)sender
{
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"TOKEN"];
    [DLBBSAPIHelper postTopicAtBoard:self.item.board WithTitle:self.titleTextField.text Content:self.replyTextView.text Reid:self.item.postID token:token complete:^(BOOL success, NSString *board, NSInteger postID, NSError *error) {
        if (!error && success) {
            if (self.info && self.info.count) {
                [self uploadFilWith:self.info atBoard:board postID:postID];
            } else {
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            [self.view makeToast:@"回帖失败" duration:1.0 position:@"center"];
        }
        
    }];

}

- (void)uploadFilWith:(NSArray *)info atBoard:(NSString *) board postID:(NSInteger)postID
{
    if (info.count) {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.mode = MBProgressHUDModeDeterminate;
        HUD.progress = 0.0f;
        HUD.labelText = @"Uploading...";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = 0; i < info.count; i++) {
                NSString *imageFile = info[i][kELCImagePickerControllerName];
                UIImage *image = info[i][UIImagePickerControllerOriginalImage];
                NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"TOKEN"];
                NSString *urlString = [NSString stringWithFormat:@"http://bbs.seu.edu.cn/api/attachment/add.js?token=%@&board=%@&id=%ld", token, board, postID];
                [DLBBSAPIHelper postImage:imageFile Image:image toURL:urlString complete:^(BOOL success, NSError *error) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        if ([NSThread isMainThread]) {
                            NSLog(@"main thread");
                        }
                        if (success) {
                            NSLog(@"upload image succeed");
                            HUD.progress += (1.0f/(float)info.count);
                            NSLog(@"progress: %f", HUD.progress);
                            if (HUD.progress >= 1.0f - FLT_EPSILON) {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    sleep(1);
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
                                        HUD.customView = image;
                                        HUD.mode = MBProgressHUDModeCustomView;
                                        HUD.labelText = @"Completed";
                                        NSLog(@"all images uploaded");
                                    });
                                    sleep(1);
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [HUD removeFromSuperview];
                                        //[self.replyTextView becomeFirstResponder];
                                        [self.info removeAllObjects];
                                        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                    });

                                });
                                
                            }
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crossmark"]];
                                HUD.customView = image;
                                HUD.mode = MBProgressHUDModeCustomView;
                                HUD.labelText = @"Failed";
                                NSLog(@"upload image failed");
                            });
                            sleep(2);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [HUD removeFromSuperview];
                                //[self.replyTextView becomeFirstResponder];
                                [self.info removeAllObjects];
                                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                            });
                            
                        }
                        
                    });
                }];
            }
        });
        [HUD show:YES];
    } else {
        [self.replyTextView becomeFirstResponder];
    }

}

-(void)keyboardShow:(NSNotification *)notification
{
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newFrame = [self.view convertRect:frame fromView:[UIApplication sharedApplication].delegate.window];
   // NSLog(@"%f", (newFrame.origin.y - CGRectGetHeight(self.view.frame)));
    self.bottomConstraint.constant = CGRectGetHeight(self.view.frame) - newFrame.origin.y;
    [self.view layoutIfNeeded];
}

-(void)keyboardHidden:(NSNotification *)notification
{
    self.bottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (self.replyTextView.textColor == [UIColor lightGrayColor]) {
        self.replyTextView.selectedRange = NSMakeRange(0, 0);
    }
}

-(void) textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        textView.textColor = [UIColor lightGrayColor];
        textView.text = @"说点什么吧...";
        textView.selectedRange = NSMakeRange(0, 0);
        self.sendButton.enabled = NO;

    } else {
        self.sendButton.enabled = YES;
    }
    
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(([text isEqualToString:@"\n"] || [text isEqualToString:@""]) && textView.textColor == [UIColor lightGrayColor]) {
        return NO;
    }
    
    if (textView.textColor == [UIColor lightGrayColor]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }

    return YES;
}


- (IBAction)uploadFileButtonTapped:(id)sender
{
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:elcPicker animated:YES completion:nil];}

- (IBAction)cameraButtonTapped:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:^{
        }];

    }

}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSMutableDictionary *information = [[NSMutableDictionary alloc]init];
    [information setObject:@"Image.jpeg" forKey:kELCImagePickerControllerName];
    [information setObject:info[UIImagePickerControllerOriginalImage] forKey:UIImagePickerControllerOriginalImage];
    [self.info addObject:information];
    NSLog(@"images count:%ld", (long)self.info.count);
    [self.replyTextView becomeFirstResponder];
    
}

#pragma mark - ELCImagePickerControllerDelegate
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.info addObjectsFromArray:info];
    NSLog(@"images count:%ld", (long)self.info.count);
}


-(void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.replyTextView becomeFirstResponder];
}
@end
