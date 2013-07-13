//
//  D2DropBounceBehavior.m
//  Due2
//
//  Created by Lin Junjie on 12/7/13.
//  Copyright (c) 2013 Lin Junjie. All rights reserved.
//

#import "D2DropBounceBehavior.h"

@implementation D2DropBounceBehavior

- (instancetype)initWithItems:(NSArray *)items
{
	self = [super init];
	
	if (self)
	{
		UIGravityBehavior *gravityBehavior =
		[[UIGravityBehavior alloc] initWithItems:items];
		
		[gravityBehavior setXComponent:0 yComponent:1.0];
		
		_gravityBehavior = gravityBehavior;
		
		UICollisionBehavior *collisionBehavior =
		[[UICollisionBehavior alloc] initWithItems:items];
		
		[collisionBehavior setTranslatesReferenceBoundsIntoBoundary:YES];
		
		_collisionBehavior = collisionBehavior;
		
		UIDynamicItemBehavior *dynamicItemBehavior =
		[[UIDynamicItemBehavior alloc] initWithItems:items];
		
		dynamicItemBehavior.elasticity = 0.5;
		dynamicItemBehavior.resistance = 0;
		dynamicItemBehavior.angularResistance = 0;
		dynamicItemBehavior.allowsRotation = NO;
		
		[self addChildBehavior:gravityBehavior];
		[self addChildBehavior:collisionBehavior];
		[self addChildBehavior:dynamicItemBehavior];
	}
	
	return self;
}

@end
