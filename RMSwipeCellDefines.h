//
//  RMSwipeCellHelper.h
//  Due2
//
//  Created by Lin Junjie on 9/8/14.
//  Copyright (c) 2014 Lin Junjie. All rights reserved.
//

typedef NS_ENUM(NSUInteger, RMSwipeCellRevealDirection) {
    RMSwipeCellRevealDirectionNone = -1, // disables panning
    RMSwipeCellRevealDirectionBoth = 0,
    RMSwipeCellRevealDirectionRight = 1,
    RMSwipeCellRevealDirectionLeft = 2,
};

typedef NS_ENUM(NSUInteger, RMSwipeCellAnimationType) {
    RMSwipeCellAnimationTypeEaseInOut            = 0 << 16,
    RMSwipeCellAnimationTypeEaseIn               = 1 << 16,
    RMSwipeCellAnimationTypeEaseOut              = 2 << 16,
    RMSwipeCellAnimationTypeEaseLinear           = 3 << 16,
    RMSwipeCellAnimationTypeBounce               = 4 << 16, // default
};

@protocol RMSwipeCellDelegate <NSObject>

@optional
-(void)swipeCellDidStartSwiping:(UIView *)swipeCell;
-(void)swipeCell:(UIView *)swipeCell didSwipeToPoint:(CGPoint)point velocity:(CGPoint)velocity;
-(void)swipeCell:(UIView *)swipeCell isResettingStateAtPoint:(CGPoint)point;
-(void)swipeCellWillResetState:(UIView *)swipeCell fromPoint:(CGPoint)point animation:(RMSwipeCellAnimationType)animation velocity:(CGPoint)velocity;
-(void)swipeCellDidResetState:(UIView *)swipeCell fromPoint:(CGPoint)point animation:(RMSwipeCellAnimationType)animation velocity:(CGPoint)velocity;

/**
 Defaults to YES (the backView is recreated everytime the state is about to reset)
 */
-(BOOL)swipeCellShouldCleanupBackView:(UIView *)swipeCell;

@end