//
//  CollectionCell.m
//  FlickrTest
//
//  Created by Dmitry on 14/03/2017.
//  Copyright © 2017 company. All rights reserved.
//

#import "CollectionCell.h"
#import "UIImageView+AFNetworking.h"

@interface CollectionCell()

@end

@implementation CollectionCell

- (void)setupWithPhoto:(NSURL *)url {
    [self.imageView setImageWithURL:url];
}

- (void)setupWithTitle:(NSString *)title {
    [self.titleLabel setText:title];
}

@end
