//
//  RMSwipeCollectionViewCell.h
//  Due2
//
//  Created by Lin Junjie on 9/8/14.
//  Copyright (c) 2014 Lin Junjie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMSwipeCellDefines.h"
#import "RMPanGestureRecognizer.h"

@interface RMSwipeCollectionViewCell : UICollectionViewCell <RMSwipeCell, UIGestureRecognizerDelegate>

/**
 
 Customizable subview that is revealed when the user pans
 
 */

@property (nonatomic, strong) UIView *backView;

/**
 
 An accessory image view that is added on top of the back view
 
 */
@property (nonatomic, strong) UIImageView *backViewAccessoryView;

/**
 Determines the direction that swiping is enabled for.
 
 Default is RMSwipeCellRevealDirectionBoth
 */
@property (nonatomic, readwrite) RMSwipeCellRevealDirection revealDirection;

/**
 Determines the animation that occurs when panning ends.
 
 Default is RMSwipeCellAnimationTypeBounce.
 */
@property (nonatomic, readwrite) RMSwipeCellAnimationType animationType;

/**
 Determines the animation duration when the cell's contentView animates back.
 
 Default is 0.2f
 */
@property (nonatomic, readwrite) CGFloat animationDuration;

/**
 When using RMSwipeCellAnimationTypeBounce, whether we use UIDynamic to bounce the cell back
 
 Default is YES
 */
@property (nonatomic, readwrite) BOOL bounceWithDynamics;

/**
 Override this property at any point to stop the cell contentView from animation back into place on touch ended. Default is YES.
 
 This is useful in the swipeCellWillResetState:fromLocation: delegate method.
 
 Note: it will reset to YES in prepareForReuse
 */
@property (nonatomic, readwrite) BOOL shouldAnimateCellReset;

/**
 When panning/swiping the cell's location is set to exponentially decay. The elasticity (also know as rubber banding) matches that of a UIScrollView/UITableView.
 
 Default is YES
 */
@property (nonatomic, readwrite) BOOL panElasticity;

/**
 This determines the exponential decay of the pan. By default it matches that of UIScrollView.
 
 Default is 0.55f
 */
@property (nonatomic, readwrite) CGFloat panElasticityFactor;

/**
 When using panElasticity this property allows you to control at which point elasticitykicks in.
 
 Default is 0.0f
 */
@property (nonatomic, readwrite) CGFloat panElasticityStartingPoint;

/**
 Default is [UIColor colorWithWhite:0.92 alpha:1]
 */
@property (nonatomic, strong) UIColor *backViewbackgroundColor;

/**
 The actual content view that we should be shifting. Override to shift
 another content view instead
 
 Default: self.contentView
 */
@property (nonatomic, readonly) UIView *actualContentView;

@property (nonatomic, assign) id <RMSwipeCellDelegate> delegate;

// exposed class methods for easy subclassing
-(void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer;
-(void)didStartSwiping;
-(void)animateContentViewForPoint:(CGPoint)point velocity:(CGPoint)velocity;
-(void)resetCellFromPoint:(CGPoint)point velocity:(CGPoint)velocity;
-(UIView *)backView;
-(void)cleanupBackView;

@end
