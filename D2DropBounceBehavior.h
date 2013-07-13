//
//  D2DropBounceBehavior.h
//  Due2
//
//  Created by Lin Junjie on 12/7/13.
//  Copyright (c) 2013 Lin Junjie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface D2DropBounceBehavior : UIDynamicBehavior

- (instancetype)initWithItems:(NSArray *)items;

#pragma mark -

@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *dynamicItemBehavior;

@end
