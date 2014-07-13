//
//  DLBoardFlowLayout.m
//  SEUBBS
//
//  Created by li liew on 7/11/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLBoardFlowLayout.h"

@interface DLBoardFlowLayout()
@property (nonatomic, strong)UIDynamicAnimator *animator;
@end

@implementation DLBoardFlowLayout
- (instancetype)init
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (self = [super init]) {
        self.minimumInteritemSpacing = 5;
        self.minimumLineSpacing = 10;
        self.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
        self.animator = [[UIDynamicAnimator alloc]initWithCollectionViewLayout:self];
    }
    
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (self = [super initWithCoder:aDecoder]) {
        self.minimumInteritemSpacing = 5;
        self.minimumLineSpacing = 10;
        self.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
        
        self.animator = [[UIDynamicAnimator alloc]initWithCollectionViewLayout:self];
    }
    
    return self;

}

-(void)prepareLayout
{
    [super prepareLayout];
    CGSize contentSize = self.collectionView.contentSize;
    NSLog(@"%f:%f", contentSize.width, contentSize.height);
    NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];
    NSLog(@"%ld", (long)items.count);
    if (self.animator.behaviors.count != items.count) {
        [self.animator removeAllBehaviors];
        [items enumerateObjectsUsingBlock:^(id<UIDynamicItem> obj, NSUInteger idx, BOOL *stop) {
            UIAttachmentBehavior *behavior = [[UIAttachmentBehavior alloc] initWithItem:obj attachedToAnchor:obj.center];
            behavior.length = 0.0f;
            behavior.damping = 0.8;
            behavior.frequency = 1.0f;
            
            [self.animator addBehavior:behavior];
        }];
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.animator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.animator layoutAttributesForCellAtIndexPath:indexPath];
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    UIScrollView *scrollView = self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [self.animator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        CGFloat yDistanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat xDistanceFromTouch = fabsf(touchLocation.x - springBehaviour.anchorPoint.x);
        CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0f;
        
        UICollectionViewLayoutAttributes *item = springBehaviour.items.firstObject;
        CGPoint center = item.center;
        if (delta < 0) {
            center.y += MAX(delta, delta*scrollResistance);
        }
        else {
            center.y += MIN(delta, delta*scrollResistance);
        }
        item.center = center;
        
        [self.animator updateItemUsingCurrentState:item];
    }];
    
    return NO;
}

@end
