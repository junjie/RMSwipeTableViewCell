//
//  RMPanGestureRecognizer.h
//  Due
//
//  Created by Lin Junjie on 9/4/21.
//  Copyright © 2021 Lin Junjie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMSwipeCellDefines.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RMPanGestureRecognizerPurpose) {
    RMPanGestureRecognizerPurposeCellPanning, /*!< To pan a single cell. Attached to a single cell. */
    RMPanGestureRecognizerPurposeDisableMultitouch, /*!< To disable multitouch. Attached to table or collection view */
    RMPanGestureRecognizerPurposeDisableSubsequentTouches, /*!< To disable subsequent touches that are added after multitouch gesture fails. Attached to table or collection view */
};

@interface RMPanGestureRecognizer: UIPanGestureRecognizer
@property (nonatomic, readonly) RMPanGestureRecognizerPurpose purpose;

+ (instancetype)cellPanningRecognizerWithTarget:(id)target action:(SEL)action revealDirectionProvider:(RMSwipeCellRevealDirection (^)(RMPanGestureRecognizer *gestureRecognizer))revealDirectionProvider;
+ (instancetype)disableMultiTouchRecognizer;
+ (instancetype)disableMultipleSingleTouchRecognizer;

#pragma mark - Disable Other Initializers & Unavailable Properties

+ (instancetype)new __attribute__((unavailable("Use class factory method to init")));
- (instancetype)init __attribute__((unavailable("Use class factory method to init")));
- (instancetype)initWithTarget:(nullable id)target action:(nullable SEL)action __attribute__((unavailable("Use class factory method to init")));
- (void)setDelegate:(nullable id<UIGestureRecognizerDelegate>)delegate __attribute__((unavailable("Use class factory method to set delegate")));

@end

//@interface RMPanGestureRecognizerDeconflictor: NSObject <UIGestureRecognizerDelegate>
//@end

NS_ASSUME_NONNULL_END
