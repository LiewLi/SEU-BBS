//
//  DLTimer.h
//  SEUBBS
//
//  Created by li liew on 7/3/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLTimer : NSObject
+ (DLTimer *)repeatingTimerWithTimerInterval:(NSTimeInterval)seconds block:(dispatch_block_t)block;
-(void)invalidate;
@end
