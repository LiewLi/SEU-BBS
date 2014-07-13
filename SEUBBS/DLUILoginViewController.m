//
//  DLUILoginViewController.m
//  SEUBBS
//
//  Created by li liew on 7/1/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLUILoginViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import <Toast/Toast+UIView.h>
#import "DLBBSAPIHelper.h"
#import "DLAppDelegate.h"
#import "JASidePanelController.h"
#import "DLHotTenViewController.h"

@implementation DLUILoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 3.0f;
    self.profileImageView.layer.borderColor = [UIColor grayColor].CGColor;
    
    self.userTextField.delegate = self;
    self.pwdTextField.delegate = self;

    
    self.userTextField.backgroundColor = [UIColor clearColor];
    self.pwdTextField.backgroundColor = [UIColor clearColor];
    self.userTextField.borderStyle = UITextBorderStyleNone;
    self.pwdTextField.borderStyle = UITextBorderStyleNone;
    self.pwdTextField.secureTextEntry = YES;
    self.userTextField.textColor = [UIColor whiteColor];
    self.pwdTextField.textColor = [UIColor whiteColor];
    self.userTextField.placeholder = @"用户ID";
    self.pwdTextField.placeholder = @"密码";
    
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"defaultLoginBackgroundHorizontal.jpg"]];
    
    self.loginAccountImageView.image = [UIImage imageNamed:@"loginAccountIcon"];
    self.loginPasswordIcon.image = [UIImage imageNamed:@"loginPasswordIcon"];
    
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImageView.image = [UIImage imageNamed:@"loginDefaultUser"];
    
}


- (IBAction)loginButtonTapped:(id)sender
{
    if (self.userTextField.text.length == 0){
        [self.view makeToast:@"用户ID不能为空哟" duration:2.0 position:@"center"];
        return;
    }
    else if (self.pwdTextField.text.length == 0) {
        [self.view makeToast:@"密码不能为空哟" duration:2.0 position:@"center"];
        return;
    }
    
    [self.loginButton setTitle:@"正在登录..." forState:UIControlStateNormal];
    [DLBBSAPIHelper loginForUser:self.userTextField.text WithPass:self.pwdTextField.text complete:^(NSString * token, NSError * error) {
        if (!error && token) {
            NSLog(@"login succeed");
            NSUserDefaults *userDefaults =  [NSUserDefaults standardUserDefaults];
            [userDefaults setValue:self.userTextField.text forKey:@"USER"];
            [userDefaults setValue:self.pwdTextField.text forKey:@"PWD"];
            [userDefaults setValue:token forKey:@"TOKEN"];
            [userDefaults synchronize];
            
            JASidePanelController *rootViewController = [[JASidePanelController alloc] init];
            UIViewController *navigationPanel = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NavigationPanel"];
            rootViewController.leftPanel = navigationPanel;
            DLHotTenViewController *hotten = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HotTenViewController"];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:hotten];
            rootViewController.centerPanel = nav;
            rootViewController.rightPanel = nil;
            rootViewController.leftFixedWidth = 100;


            DLAppDelegate *appDelegate = (DLAppDelegate *)[[UIApplication sharedApplication]delegate];
            [appDelegate.window setRootViewController:rootViewController];
            
        } else {
            [self.view makeToast:@"用户ID与密码不匹配" duration:2.0 position:@"center"];
        }
    }];
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
}

- (void)tryFetchProfileImageFor:(NSString *)user
{
    [DLBBSAPIHelper fetchProfileImageForUser:user complete:^(NSURL *imageURL, NSError *error) {
        if (!error) {
            NSData *data = [[NSData alloc]initWithContentsOfURL:imageURL];
            if (data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.profileImageView.image = [UIImage imageWithData:data];
                    NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"/avatar.jpg"];
                    [data writeToFile:imagePath atomically:YES];
                });
            } else {
                self.profileImageView.image = [UIImage imageNamed:@"loginDefaultUser"];
            }
            
        }
    }];

}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length == 0) {
        self.profileImageView.image = [UIImage imageNamed:@"loginDefaultUser"];
        return YES;
    };
    NSLog(@"return button tapped");
    if (textField == self.userTextField) {
        NSLog(@"user id entered: %@", textField.text);
        [self tryFetchProfileImageFor:textField.text];
    } else {
        [self loginButtonTapped:nil];
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.userTextField) {
        [self tryFetchProfileImageFor:textField.text];
    }
}

@end
