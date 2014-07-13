
#import "PhotoViewController.h"
#import "ImageScrollView.h"

@interface PhotoViewController ()
@property (nonatomic, strong, readwrite)UIImage *image;
@end

@implementation PhotoViewController


- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init]) {
        _image = image;
    }
    
    return self;
}



- (void)loadView
{
    ImageScrollView *scrollView = [[ImageScrollView alloc] init];
    scrollView.image = self.image;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = scrollView;
}

// (this can also be defined in Info.plist via UISupportedInterfaceOrientations)
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
