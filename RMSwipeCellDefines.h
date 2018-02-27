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

@protocol RMSwipeCellDelegate;

@protocol RMSwipeCell <NSObject>

- (UIView *)backView;
- (void)setBackView:(UIView *)backView;

- (UIImageView *)backViewAccessoryView;
- (void)setBackViewAccessoryView:(UIImageView *)backViewAccessoryView;

- (RMSwipeCellRevealDirection)revealDirection;
- (void)setRevealDirection:(RMSwipeCellRevealDirection)revealDirection;

- (RMSwipeCellAnimationType)animationType;
- (void)setAnimationType:(RMSwipeCellAnimationType)animationType;

- (CGFloat)animationDuration;
- (void)setAnimationDuration:(CGFloat)animationDuration;

- (BOOL)bounceWithDynamics;
- (void)setBounceWithDynamics:(BOOL)bounceWithDynamics;

- (BOOL)shouldAnimateCellReset;
- (void)setShouldAnimateCellReset:(BOOL)shouldAnimateCellReset;

- (BOOL)panElasticity;
- (void)setPanElasticity:(BOOL)panElasticity;

- (CGFloat)panElasticityFactor;
- (void)setPanElasticityFactor:(CGFloat)panElasticityFactor;

- (CGFloat)panElasticityStartingPoint;
- (void)setPanElasticityStartingPoint:(CGFloat)panElasticityStartingPoint;

- (UIColor *)backViewbackgroundColor;
- (void)setBackViewbackgroundColor:(UIColor *)backViewbackgroundColor;

- (UIView *)actualContentView;

- (id <RMSwipeCellDelegate>)delegate;
- (void)setDelegate:(id <RMSwipeCellDelegate>)delegate;

@end

@protocol RMSwipeCellDelegate <NSObject>

@optional
-(void)swipeCellDidStartSwiping:(id <RMSwipeCell>)swipeCell;
-(void)swipeCell:(id <RMSwipeCell>)swipeCell didSwipeToPoint:(CGPoint)point fromPoint:(CGPoint)fromPoint velocity:(CGPoint)velocity;
-(void)swipeCell:(id <RMSwipeCell>)swipeCell isResettingStateAtPoint:(CGPoint)point;
-(void)swipeCellWillResetState:(id <RMSwipeCell>)swipeCell fromPoint:(CGPoint)point animation:(RMSwipeCellAnimationType)animation velocity:(CGPoint)velocity;
-(void)swipeCellDidResetState:(id <RMSwipeCell>)swipeCell fromPoint:(CGPoint)point animation:(RMSwipeCellAnimationType)animation velocity:(CGPoint)velocity;

/**
 Defaults to YES (the backView is recreated everytime the state is about to reset)
 */
-(BOOL)swipeCellShouldCleanupBackView:(UIView *)swipeCell;

@end
