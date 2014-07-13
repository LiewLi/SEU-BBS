//
//  DLTimer.m
//  SEUBBS
//
//  Created by li liew on 7/3/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLTimer.h"

@interface DLTimer()
@property (nonatomic, strong)dispatch_block_t block;
@property (nonatomic, strong)dispatch_source_t source;
@end

@implementation DLTimer
+(DLTimer *)repeatingTimerWithTimerInterval:(NSTimeInterval)seconds block:(dispatch_block_t)block
{
    DLTimer *timer = [[DLTimer alloc]init];
    timer.block = block;
    timer.source  =dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    uint64_t nsec = (uint64_t)(seconds * NSEC_PER_SEC);
    dispatch_source_set_timer(timer.source, dispatch_time(DISPATCH_TIME_NOW, nsec), nsec, 0);
    dispatch_source_set_event_handler(timer.source, block);
    dispatch_resume(timer.source);
    return timer;
    
}

-(void)invalidate
{
    if (self.source) {
        dispatch_source_cancel(self.source);
        self.source = nil;
    }
    self.block = nil;
}

- (void)dealloc
{
    [self invalidate];
}
@end
