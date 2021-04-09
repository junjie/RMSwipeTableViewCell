//
//  RMPanGestureRecognizer.m
//  Due
//
//  Created by Lin Junjie on 9/4/21.
//  Copyright © 2021 Lin Junjie. All rights reserved.
//

#import "RMPanGestureRecognizer.h"

@interface RMPanGestureRecognizer () <UIGestureRecognizerDelegate>
@property (nonatomic, copy) RMSwipeCellRevealDirection (^revealDirectionProvider)(RMPanGestureRecognizer *gestureRecognizer);
- (void)setActualDelegate:(nullable id<UIGestureRecognizerDelegate>)delegate;
@end

@implementation RMPanGestureRecognizer

+ (instancetype)cellPanningRecognizerWithTarget:(id)target action:(SEL)action revealDirectionProvider:(RMSwipeCellRevealDirection (^)(RMPanGestureRecognizer *gestureRecognizer))revealDirectionProvider
{
    RMPanGestureRecognizer *recognizer = [[self alloc] initWithTarget:target action:action purpose:RMPanGestureRecognizerPurposeCellPanning];
    recognizer.revealDirectionProvider = revealDirectionProvider;
    [recognizer setActualDelegate:recognizer];
    return recognizer;
}

+ (instancetype)disableMultiTouchRecognizer
{
    RMPanGestureRecognizer *recognizer = [[self alloc] initWithTarget:nil action:nil purpose:RMPanGestureRecognizerPurposeDisableMultitouch];
    [recognizer setActualDelegate:recognizer];
    return recognizer;
}

+ (instancetype)disableMultipleSingleTouchRecognizer
{
    RMPanGestureRecognizer *recognizer = [[self alloc] initWithTarget:nil action:nil purpose:RMPanGestureRecognizerPurposeDisableSubsequentTouches];
    [recognizer setActualDelegate:recognizer];
    return recognizer;
}

- (instancetype)initWithTarget:(nullable id)target action:(nullable SEL)action purpose:(RMPanGestureRecognizerPurpose)purpose
{
    self = [super initWithTarget:target action:action];
    if (self)
    {
        _purpose = purpose;
    }
    return self;
}

- (void)setDelegate:(id<UIGestureRecognizerDelegate>)delegate
{
    [NSException raise:NSGenericException format:@"Attempting to set delegate separately. Set delegate with class factory method."];
}

- (void)setActualDelegate:(id<UIGestureRecognizerDelegate>)delegate
{
    super.delegate = delegate;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(RMPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[RMPanGestureRecognizer class]] == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Unexpected gesture recognizer: %@", gestureRecognizer];
        return YES;
    }
    
    switch (gestureRecognizer.purpose) {
        case RMPanGestureRecognizerPurposeCellPanning: {
            RMSwipeCellRevealDirection revealDirection = gestureRecognizer.revealDirectionProvider(gestureRecognizer);
            if (revealDirection == RMSwipeCellRevealDirectionNone) {
                return NO;
            }
            
            UIView *view = gestureRecognizer.view;
            
            CGPoint translation = [gestureRecognizer translationInView:view.superview];
            CGFloat xOverYTranslation = fabs(translation.x) / fabs(translation.y);
            // Even infinity (y == 0) gives us > 1
            BOOL shouldBegin = (xOverYTranslation > 1);
            
            if (shouldBegin)
            {
                if (revealDirection == RMSwipeCellRevealDirectionLeft && translation.x < 0)
                    shouldBegin = NO;
                else if (revealDirection == RMSwipeCellRevealDirectionRight && translation.x > 1)
                    shouldBegin = NO;
            }
                
            return shouldBegin;
            break;
        }
            
        case RMPanGestureRecognizerPurposeDisableMultitouch:
            return gestureRecognizer.numberOfTouches > 1;
            break;
            
        case RMPanGestureRecognizerPurposeDisableSubsequentTouches:
            return YES;
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Unexpected gesture recognizer: %@", gestureRecognizer];
            break;
    }

    return NO;
}

// Only allow cell panning can only proceed if multitouch gesture on superview fails
- (BOOL)gestureRecognizer:(RMPanGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[RMPanGestureRecognizer class]] == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Unexpected gesture recognizer: %@", gestureRecognizer];
        return NO;
    }

    if (gestureRecognizer.purpose != RMPanGestureRecognizerPurposeCellPanning) {
        return NO;
    }
    
    if ([otherGestureRecognizer isKindOfClass:[RMPanGestureRecognizer class]]) {
        RMPanGestureRecognizer *otherRecognizer = (RMPanGestureRecognizer *)otherGestureRecognizer;
        
        // Always depend on the failure of that
        return otherRecognizer.purpose == RMPanGestureRecognizerPurposeDisableMultitouch;
    }

    return NO;
}

- (BOOL)gestureRecognizer:(RMPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[RMPanGestureRecognizer class]] == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Unexpected gesture recognizer: %@", gestureRecognizer];
        return YES;
    }

    if ([otherGestureRecognizer isKindOfClass:[RMPanGestureRecognizer class]] == NO) {
        // Gestures meant to disable multitouch and multiple single touches do not have other functions and should allow all other kinds of gestures, system or otherwise, to proceed
        switch (gestureRecognizer.purpose) {
            case RMPanGestureRecognizerPurposeDisableMultitouch:
            case RMPanGestureRecognizerPurposeDisableSubsequentTouches:
                return YES;
            default:
                return NO;
        }
    }

    RMPanGestureRecognizer *otherRecognizer = (RMPanGestureRecognizer *)otherGestureRecognizer;
    
    switch (gestureRecognizer.purpose) {
        case RMPanGestureRecognizerPurposeCellPanning:
            switch (otherRecognizer.purpose) {
                case RMPanGestureRecognizerPurposeDisableMultitouch:
                    return NO;
                    break;
                    
                case RMPanGestureRecognizerPurposeDisableSubsequentTouches:
                    switch (otherRecognizer.state) {
                        case UIGestureRecognizerStatePossible:
                        case UIGestureRecognizerStateBegan:
                            // Allow cell to pan because this is the first cell panning
                            return YES;
                            break;
                            
                        default:
                            // Disallow cell to pan because this is not the first cell panning
                            return NO;
                            break;
                    }
                    break;
                    
                default:
                    return NO;
                    break;
            }
            break;
            
        case RMPanGestureRecognizerPurposeDisableMultitouch:
            return NO;
            break;

        case RMPanGestureRecognizerPurposeDisableSubsequentTouches:
            if (otherRecognizer.purpose == RMPanGestureRecognizerPurposeCellPanning) {
                switch (gestureRecognizer.state) {
                    case UIGestureRecognizerStatePossible:
                    case UIGestureRecognizerStateBegan:
                        return YES;
                        break;
                        
                    default:
                        return NO;
                        break;
                }
            }
            
            // Allow simultaneous recognition with gesture for multitouch, else multitouch gesture would fail to work
            return YES;
            break;

        default:
            break;
    }
    
    return NO;
}


@end
