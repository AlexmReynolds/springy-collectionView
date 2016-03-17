//
//  ARFlowLayout.m
//  message
//
//  Created by Alex Reynolds on 3/17/16.
//  Copyright © 2016 Alex Reynolds. All rights reserved.
//

#import "ARFlowLayout.h"

@implementation ARFlowLayout{
    UIDynamicAnimator *_dynamicAnimator;
}
- (void)prepareLayout
{
    [super prepareLayout];
    if (!_dynamicAnimator){
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
        CGSize contentSize = self.collectionViewContentSize;
        NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];
        
        for (UICollectionViewLayoutAttributes *item in items){
            UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:[item center]];
            spring.length = 0;
            spring.damping = 0.5;
            spring.frequency = 1.1;
            
            [_dynamicAnimator addBehavior:spring];
        }
    }
}
- (CGSize)itemSize
{
    return CGSizeMake(self.collectionView.bounds.size.width, 80);
}
- (CGFloat)minimumLineSpacing
{
    return 6;
}
- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [_dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    UIScrollView *scrollView = self.collectionView;
    CGFloat scrollDelta = newBounds.origin.y - scrollView.bounds.origin.y;
    
    CGPoint touchLocation = [scrollView.panGestureRecognizer locationInView:scrollView];
    
    for (UIAttachmentBehavior *spring in _dynamicAnimator.behaviors){
        CGPoint anchorPoint = spring.anchorPoint;
        CGFloat distanceFromTouch = fabs(touchLocation.y - anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / 500;
        
        UICollectionViewLayoutAttributes *item = (UICollectionViewLayoutAttributes*)[spring.items firstObject];
        CGPoint center = item.center;
        if (scrollDelta > 0){
            center.y += MIN(scrollDelta, scrollDelta * scrollResistance);

        }else {
            center.y += MAX(scrollDelta, scrollDelta * scrollResistance);

        }
        item.center = center;
        
        [_dynamicAnimator updateItemUsingCurrentState:item];
    }

    return YES;
}
@end
