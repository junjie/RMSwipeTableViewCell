// Copyright (c) 2008 Loren Brichter
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
//  ABTableViewCell.m
//
//  Created by Loren Brichter
//  Copyright 2008 Loren Brichter. All rights reserved.
//

#import "ABTableViewCell.h"

@interface ABTableViewCellView : UIView
@property (nonatomic, weak) ABTableViewCell *cell;
@end

@implementation ABTableViewCellView

- (id)initWithFrame:(CGRect)frame
{
	NSAssert(0, @"Use initWithFrame:cell: to initialise a ABTableViewCellView");
	return nil;
}

- (id)initWithFrame:(CGRect)frame cell:(ABTableViewCell *)cell
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_cell = cell;
		self.opaque = YES;
		self.contentMode = UIViewContentModeLeft;
		self.autoresizingMask = UIViewAutoresizingNone;
	}
	return self;
}

- (void)drawRect:(CGRect)r
{
	BOOL highlight = self.cell.isHighlighted || self.cell.isSelected;
	[self.cell drawContentView:r highlighted:highlight];
}

@end

@implementation ABTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self)
	{
		_customContentView = [[ABTableViewCellView alloc] initWithFrame:CGRectZero cell:self];
		[self.contentView addSubview:_customContentView];
    }
    return self;
}

- (void)setNeedsDisplay
{
	[super setNeedsDisplay];
	[self.customContentView setNeedsDisplay];
}

- (void)drawContentView:(CGRect)r highlighted:(BOOL)highlighted
{
	// subclasses should implement this
}

@end
