//
//  UITableViewCell+TableView.m
//  SEUBBS
//
//  Created by li liew on 7/3/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "UITableViewCell+TableView.h"

@implementation UITableViewCell (TableView)
- (id<UITableViewDelegate>)tableViewController
{
    UIView *view = self;
    while (!(view == nil || [view isKindOfClass:[UITableView class]])) {
        view = view.superview;
    }
    
    return ((UITableView *)view).delegate;
}

@end
