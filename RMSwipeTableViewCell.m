//
//  RMSwipeTableViewCell.m
//  RMSwipeTableView
//
//  Created by Rune Madsen on 2012-11-24.
//  Copyright (c) 2012 The App Boutique. All rights reserved.
//

#import "RMSwipeTableViewCell.h"
#import "D2DropBounceBehavior.h"

#define BACK_VIEW_ACCESSORY_VIEW_WIDTH 30
#define BACK_VIEW_ACCESSORY_VIEW_HEIGHT 30

@interface RMSwipeTableViewCell () <UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate>
@property (nonatomic, strong) UIDynamicAnimator* animator;
@property (nonatomic) CGPoint resetPoint;
@property (nonatomic) CGPoint resetVelocity;
@end

@implementation RMSwipeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    // We need to set the contentView's background colour, otherwise the sides are clear on the swipe and animations
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [panGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:panGestureRecognizer];
    
    self.revealDirection = RMSwipeCellRevealDirectionBoth;
    self.animationType = RMSwipeCellAnimationTypeBounce;
    self.animationDuration = 0.3f;
	self.bounceWithDynamics = NO;
    self.shouldAnimateCellReset = YES;
    self.backViewbackgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
    self.panElasticity = YES;
    self.panElasticityFactor = 0.55f;
    self.panElasticityStartingPoint = 0.0f;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.frame];
    backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView = backgroundView;
}

-(void)prepareForReuse {
    [super prepareForReuse];
	[self clearAllAnimationBehaviorResetContentViewFrame:YES];
	
	if (_backView)
	{
		self.backView.backgroundColor = self.backViewbackgroundColor;
	}
	
	if (_backViewAccessoryView)
	{
		[_backViewAccessoryView removeFromSuperview];
		_backViewAccessoryView = nil;
	}
	
    self.shouldAnimateCellReset = YES;
}

- (UIView *)actualContentView
{
	return self.customContentView;
}

#pragma mark - Gesture recognizer delegate

-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    // We only want to deal with the gesture of it's a pan gesture
    if ([panGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && self.revealDirection != RMSwipeCellRevealDirectionNone) {
        CGPoint translation = [panGestureRecognizer translationInView:[self superview]];
		CGFloat xOverYTranslation = fabs(translation.x) / fabs(translation.y);
		// Even infinity (y == 0) gives us > 1
		BOOL shouldBegin = (xOverYTranslation > 1);
		
		if (shouldBegin)
		{
			if (self.revealDirection == RMSwipeCellRevealDirectionLeft && translation.x < 0)
				shouldBegin = NO;
			else if (self.revealDirection == RMSwipeCellRevealDirectionRight && translation.x > 1)
				shouldBegin = NO;
		}
			
        return shouldBegin;
    } else {
        return NO;
    }
}

-(void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    CGFloat panOffset = translation.x;
    if (self.panElasticity) {
        if (ABS(translation.x) > self.panElasticityStartingPoint) {
            CGFloat width = CGRectGetWidth(self.frame);
            CGFloat offset = abs(translation.x);
            panOffset = (offset * self.panElasticityFactor * width) / (offset * self.panElasticityFactor + width);
            panOffset *= translation.x < 0 ? -1.0f : 1.0f;
            if (self.panElasticityStartingPoint > 0) {
                panOffset = translation.x > 0 ? panOffset + self.panElasticityStartingPoint / 2 : panOffset - self.panElasticityStartingPoint / 2;
            }
        }
    }
    CGPoint actualTranslation = CGPointMake(panOffset, translation.y);
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan && [panGestureRecognizer numberOfTouches] > 0) {
        [self didStartSwiping];
        [self animateContentViewForPoint:actualTranslation velocity:velocity];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged && [panGestureRecognizer numberOfTouches] > 0) {
        [self animateContentViewForPoint:actualTranslation velocity:velocity];
	} else {
		[self resetCellFromPoint:actualTranslation  velocity:velocity];
	}
}

-(void)didStartSwiping {
    if ([self.delegate respondsToSelector:@selector(swipeCellDidStartSwiping:)]) {
        [self.delegate swipeCellDidStartSwiping:self];
    }
	
	[self clearAllAnimationBehaviorResetContentViewFrame:NO];

    [self.backgroundView addSubview:self.backView];
    [self.backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
}

#pragma mark - Gesture animations

-(void)animateContentViewForPoint:(CGPoint)point velocity:(CGPoint)velocity {
    if ((point.x > 0 && self.revealDirection == RMSwipeCellRevealDirectionLeft) || (point.x < 0 && self.revealDirection == RMSwipeCellRevealDirectionRight) || self.revealDirection == RMSwipeCellRevealDirectionBoth) {
        self.actualContentView.frame = CGRectOffset(self.actualContentView.bounds, point.x, 0);
        if ([self.delegate respondsToSelector:@selector(swipeCell:didSwipeToPoint:velocity:)]) {
            [self.delegate swipeCell:self didSwipeToPoint:point velocity:velocity];
        }
    } else if ((point.x > 0 && self.revealDirection == RMSwipeCellRevealDirectionRight) || (point.x < 0 && self.revealDirection == RMSwipeCellRevealDirectionLeft)) {
        self.actualContentView.frame = CGRectOffset(self.actualContentView.bounds, 0, 0);
    }
}

-(void)resetCellFromPoint:(CGPoint)point velocity:(CGPoint)velocity
{
	self.resetPoint = point;
	self.resetVelocity = velocity;
	
    if ([self.delegate respondsToSelector:@selector(swipeCellWillResetState:fromPoint:animation:velocity:)]) {
        [self.delegate swipeCellWillResetState:self fromPoint:point animation:self.animationType velocity:velocity];
    }
    if (self.shouldAnimateCellReset == NO) {
        return;
    }
    if ((self.revealDirection == RMSwipeCellRevealDirectionLeft && point.x < 0) || (self.revealDirection == RMSwipeCellRevealDirectionRight && point.x > 0)) {
        return;
    }
    if (self.animationType == RMSwipeCellAnimationTypeBounce)
	{
		[self bounceBackContentView:self.actualContentView fromPoint:point velocity:velocity];
    }
	else
	{
        [UIView animateWithDuration:self.animationDuration
                              delay:0
                            options:(UIViewAnimationOptions) self.animationType
                         animations:^{
                             self.actualContentView.frame = CGRectOffset(self.actualContentView.bounds, 0, 0);
                         }
                         completion:^(BOOL finished) {
                             [self cleanupBackView];
                             if ([self.delegate respondsToSelector:@selector(swipeCellDidResetState:fromPoint:animation:velocity:)]) {
                                 [self.delegate swipeCellDidResetState:self fromPoint:point animation:self.animationType velocity:velocity];
                             }
                         }
         ];
    }
}

- (UIImageView *)backViewAccessoryView
{
	if (!_backViewAccessoryView)
	{
		CGRect backViewFrame =
		CGRectMake(self.backView.frame.size.width - BACK_VIEW_ACCESSORY_VIEW_WIDTH - 10,
				   (self.backView.frame.size.height - BACK_VIEW_ACCESSORY_VIEW_HEIGHT) / 2,
				   BACK_VIEW_ACCESSORY_VIEW_WIDTH,
				   BACK_VIEW_ACCESSORY_VIEW_HEIGHT);
		
		_backViewAccessoryView = [[UIImageView alloc] initWithFrame:CGRectIntegral(backViewFrame)];
		[self.backView addSubview:_backViewAccessoryView];
	}
	
	return _backViewAccessoryView;
}

-(UIView*)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:self.backgroundView.bounds];
        _backView.backgroundColor = self.backViewbackgroundColor;
    }
    return _backView;
}

-(void)cleanupBackView {
    [_backView removeFromSuperview];
    _backView = nil;
	
	if (_backViewAccessoryView)
	{
		[_backViewAccessoryView removeFromSuperview];
		_backViewAccessoryView = nil;
	}
}

- (void)rm_completeBounceAnimationFromPoint:(CGPoint)point velocity:(CGPoint)velocity
{
	BOOL shouldCleanupBackView = YES;
	if ([self.delegate respondsToSelector:@selector(swipeCellShouldCleanupBackView:)]) {
		shouldCleanupBackView = [self.delegate swipeCellShouldCleanupBackView:self];
	}
	if (shouldCleanupBackView) {
		[self cleanupBackView];
	}
	
	if ([self.delegate respondsToSelector:@selector(swipeCellDidResetState:fromPoint:animation:velocity:)]) {
		[self.delegate swipeCellDidResetState:self fromPoint:point animation:self.animationType velocity:velocity];
	}
}

#pragma mark - Bouncing

- (void)bounceBackContentView:(UIView*)view fromPoint:(CGPoint)point velocity:(CGPoint)velocity
{
	if (self.bounceWithDynamics)
	{
		[self rm_bounceWithDynamicsBackContentView:view];
	}
	else
	{
		[self rm_bounceWithSpringAnimationBackContentView:view fromPoint:point velocity:velocity];
	}
}

- (void)rm_bounceWithDynamicsBackContentView:(UIView*)view
{
	BOOL contentViewIsDraggedLeft = (view.frame.origin.x < 0);
	
	CGFloat gravityX = 2.0;
	UIEdgeInsets collisionInsets;
	
	if (contentViewIsDraggedLeft)
	{
		// Top/left/bottom/right
		// To bounce back towards the right, to collide and stop at x=0
		// -320 allowance on left because content view already dragged leftwards
		collisionInsets = UIEdgeInsetsMake(0, -view.bounds.size.width, 0, 0);
	}
	
	else
	{
		gravityX = gravityX * -1;
		// Top/left/bottom/right
		// To bounce back towards the left, inset by 1 so we can go back to x=0
		collisionInsets = UIEdgeInsetsMake(0, 1, 0, -view.bounds.size.width);
	}
	
	D2DropBounceBehavior *slideBounceBehavior = [[D2DropBounceBehavior alloc] initWithItems:@[view]];
	[slideBounceBehavior.gravityBehavior setGravityDirection:CGVectorMake(gravityX, 0)];
	[slideBounceBehavior.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:collisionInsets];
	[slideBounceBehavior.collisionBehavior setCollisionDelegate:self];
	[slideBounceBehavior.dynamicItemBehavior setElasticity:1.0];
	
	if ([self.delegate respondsToSelector:@selector(swipeCell:isResettingStateAtPoint:)])
	{
		[slideBounceBehavior setAction:^{
			[self.delegate swipeCell:self
					  isResettingStateAtPoint:view.frame.origin];
		}];
	}
	
	[self.animator addBehavior:slideBounceBehavior];
}

- (void)rm_bounceWithSpringAnimationBackContentView:(UIView *)view fromPoint:(CGPoint)point velocity:(CGPoint)velocity
{
	__typeof(self) __weak weakSelf = self;
	void (^completionBlock)(BOOL) = ^(BOOL finished) {
		[weakSelf rm_completeBounceAnimationFromPoint:point velocity:point];
	};
	
	[UIView animateWithDuration:self.animationDuration
						  delay:0
		 usingSpringWithDamping:0.6
		  initialSpringVelocity:point.x / 5
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 view.frame = view.bounds;
					 }
					 completion:completionBlock];
}

#pragma mark - Dynamics

- (UIDynamicAnimator *)animator
{
	if (!_animator)
	{
		_animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
		[_animator setDelegate:self];
	}
	
	return _animator;
}

- (void)clearAllAnimationBehaviorResetContentViewFrame:(BOOL)resetFrame
{
	if (self.animator.behaviors.count)
	{
		[self.animator removeAllBehaviors];
	}
	
	if (resetFrame)
	{
		self.actualContentView.frame = CGRectOffset(self.actualContentView.bounds, 0, 0);
		self.actualContentView.hidden = NO;
	}
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator
{
	if (self.animator.behaviors.count)
	{
		[self clearAllAnimationBehaviorResetContentViewFrame:NO];
		[self rm_completeBounceAnimationFromPoint:self.resetPoint velocity:self.resetVelocity];
	}
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier
{
	// Finished collision
	
}

@end
