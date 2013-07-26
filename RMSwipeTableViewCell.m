//
//  RMSwipeTableViewCell.m
//  RMSwipeTableView
//
//  Created by Rune Madsen on 2012-11-24.
//  Copyright (c) 2012 The App Boutique. All rights reserved.
//

#import "RMSwipeTableViewCell.h"
#import "D2DropBounceBehavior.h"

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
    
    self.revealDirection = RMSwipeTableViewCellRevealDirectionBoth;
    self.animationType = RMSwipeTableViewCellAnimationTypeBounce;
    self.animationDuration = 0.2f;
    self.shouldAnimateCellReset = YES;
    self.backViewbackgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
    self.panElasticity = YES;
    self.panElasticityStartingPoint = 0;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.frame];
    backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView = backgroundView;
}

-(void)prepareForReuse {
    [super prepareForReuse];
	[self clearAllAnimationBehaviorResetContentViewFrame:YES];
	if (_backView)
		self.backView.backgroundColor = self.backViewbackgroundColor;
    self.shouldAnimateCellReset = YES;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - Gesture recognizer delegate

-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    // We only want to deal with the gesture of it's a pan gesture
    if ([panGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && self.revealDirection != RMSwipeTableViewCellRevealDirectionNone) {
        CGPoint translation = [panGestureRecognizer translationInView:[self superview]];
		CGFloat xOverYTranslation = fabs(translation.x) / fabs(translation.y);
		// Even infinity (y == 0) gives us > 1
		BOOL shouldBegin = (xOverYTranslation > 1);
		
		if (shouldBegin)
		{
			if (self.revealDirection == RMSwipeTableViewCellRevealDirectionLeft && translation.x < 0)
				shouldBegin = NO;
			else if (self.revealDirection == RMSwipeTableViewCellRevealDirectionRight && translation.x > 1)
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
            panOffset = (offset * 0.55f * width) / (offset * 0.55f + width);
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
	} else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
		[self resetCellFromPoint:actualTranslation  velocity:velocity];
	}
}

-(void)didStartSwiping {
    if ([self.delegate respondsToSelector:@selector(swipeTableViewCellDidStartSwiping:)]) {
        [self.delegate swipeTableViewCellDidStartSwiping:self];
    }
	
	[self clearAllAnimationBehaviorResetContentViewFrame:NO];

    [self.backgroundView addSubview:self.backView];
    [self.backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
}

#pragma mark - Gesture animations

-(void)animateContentViewForPoint:(CGPoint)point velocity:(CGPoint)velocity {
    if ((point.x > 0 && self.revealDirection == RMSwipeTableViewCellRevealDirectionLeft) || (point.x < 0 && self.revealDirection == RMSwipeTableViewCellRevealDirectionRight) || self.revealDirection == RMSwipeTableViewCellRevealDirectionBoth) {
        self.customContentView.frame = CGRectOffset(self.customContentView.bounds, point.x, 0);
        if ([self.delegate respondsToSelector:@selector(swipeTableViewCell:didSwipeToPoint:velocity:)]) {
            [self.delegate swipeTableViewCell:self didSwipeToPoint:point velocity:velocity];
        }
    } else if ((point.x > 0 && self.revealDirection == RMSwipeTableViewCellRevealDirectionRight) || (point.x < 0 && self.revealDirection == RMSwipeTableViewCellRevealDirectionLeft)) {
        self.customContentView.frame = CGRectOffset(self.customContentView.bounds, 0, 0);
    }
}

-(void)resetCellFromPoint:(CGPoint)point velocity:(CGPoint)velocity
{
	self.resetPoint = point;
	self.resetVelocity = velocity;
	
    if ([self.delegate respondsToSelector:@selector(swipeTableViewCellWillResetState:fromPoint:animation:velocity:)]) {
        [self.delegate swipeTableViewCellWillResetState:self fromPoint:point animation:self.animationType velocity:velocity];
    }
    if (self.shouldAnimateCellReset == NO) {
        return;
    }
    if ((self.revealDirection == RMSwipeTableViewCellRevealDirectionLeft && point.x < 0) || (self.revealDirection == RMSwipeTableViewCellRevealDirectionRight && point.x > 0)) {
        return;
    }
    if (self.animationType == RMSwipeTableViewCellAnimationTypeBounce)
	{
		[self bounceBackContentView:self.customContentView];
    }
	else
	{
        [UIView animateWithDuration:self.animationDuration
                              delay:0
                            options:(UIViewAnimationOptions) self.animationType
                         animations:^{
                             self.customContentView.frame = CGRectOffset(self.customContentView.bounds, 0, 0);
                         }
                         completion:^(BOOL finished) {
                             [self cleanupBackView];
                             if ([self.delegate respondsToSelector:@selector(swipeTableViewCellDidResetState:fromPoint:animation:velocity:)]) {
                                 [self.delegate swipeTableViewCellDidResetState:self fromPoint:point animation:self.animationType velocity:velocity];
                             }
                         }
         ];
    }
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
		self.customContentView.frame = CGRectOffset(self.customContentView.bounds, 0, 0);
		self.customContentView.hidden = NO;
	}
}

- (void)bounceBackContentView:(UIView*)view
{
	BOOL contentViewIsDraggedLeft = (view.frame.origin.x < 0);

	CGFloat gravityX = 2.0;
	UIEdgeInsets collisionInsets;
	
	if (contentViewIsDraggedLeft)
	{
		// Top/left/bottom/right
		// To bounce back towards the right, inset by 1 so we can go back to x=0
		// -320 allowance on left because content view already dragged leftwards
		collisionInsets = UIEdgeInsetsMake(0, -view.bounds.size.width, 0, 1);
	}
	
	else
	{
		gravityX = gravityX * -1;
		// Top/left/bottom/right
		// To bounce back towards the left, inset by 1 so we can go back to x=0
		collisionInsets = UIEdgeInsetsMake(0, 1, 0, -view.bounds.size.width);
	}

	D2DropBounceBehavior *slideBounceBehavior = [[D2DropBounceBehavior alloc] initWithItems:@[view]];
	[slideBounceBehavior.gravityBehavior setXComponent:gravityX yComponent:0];
	[slideBounceBehavior.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:collisionInsets];
	[slideBounceBehavior.collisionBehavior setCollisionDelegate:self];
	[slideBounceBehavior.dynamicItemBehavior setElasticity:1.0];
	
	if ([self.delegate respondsToSelector:@selector(swipeTableViewCell:isResettingStateAtPoint:)])
	{
		[slideBounceBehavior setAction:^{
			[self.delegate swipeTableViewCell:self
					  isResettingStateAtPoint:view.frame.origin];
		}];
	}

	[self.animator addBehavior:slideBounceBehavior];
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator
{
	if (self.animator.behaviors.count)
	{
		[self clearAllAnimationBehaviorResetContentViewFrame:NO];
		
		[self cleanupBackView];
		if ([self.delegate respondsToSelector:@selector(swipeTableViewCellDidResetState:fromPoint:animation:velocity:)]) {
			[self.delegate swipeTableViewCellDidResetState:self fromPoint:self.resetPoint animation:self.animationType velocity:self.resetVelocity];
		}

//		DDLogInfo(@"All behaviors removed for item because dynamicAnimatorDidPause");
	}
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier
{
//	DDLogInfo(@"Finished collision");
}

@end
