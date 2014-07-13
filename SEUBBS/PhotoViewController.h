

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController


- (instancetype)initWithImage:(UIImage *)image;
@property (nonatomic, readonly, strong) UIImage *image;

@end
