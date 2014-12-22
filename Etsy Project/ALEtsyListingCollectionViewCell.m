//
//  ALEtsyListingCollectionViewCell.m
//  Etsy Project
//
//  Created by Austin Lange on 12/21/14.
//  Copyright (c) 2014 Austin Lange. All rights reserved.
//

#import "ALEtsyListingCollectionViewCell.h"

@implementation ALEtsyListingCollectionViewCell

@synthesize titleLabel = _titleLabel;
@synthesize imageView = _imageView;

+ (NSString *)identifier;
{
    static NSString *idenfitier;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        idenfitier = @"ALEtsyListingCollectionViewCell";
    });
    
    return idenfitier;
}

+ (CGSize)cellSize;
{
    static CGSize cellSize;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cellSize = CGSizeMake(145., 200.);
    });
    
    return cellSize;
}

- (UILabel *)titleLabel;
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        _titleLabel.contentMode = UIViewContentModeTop;
        _titleLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UIImageView *)imageView;
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        
        [self.contentView addSubview:_imageView];
    }
    
    return _imageView;
}

- (void)layoutSubviews;
{
    CGSize cellSize = [[self class] cellSize];
    CGRect imageFrame = CGRectMake(0, 0, cellSize.width, cellSize.width);
    CGRect titleFrame = CGRectMake(5, CGRectGetMaxY(imageFrame) + 5, cellSize.width - 10, cellSize.height - CGRectGetMaxY(imageFrame) - 10);
    
    _imageView.frame = imageFrame;
    _titleLabel.frame = titleFrame;
}

- (void)prepareForReuse;
{
    _titleLabel.text = @"";
    _imageView.image = nil;
    self.contentView.backgroundColor = [UIColor clearColor];
}

@end
