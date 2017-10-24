//
//  FeedCollectionViewController.m
//  Coon
//
//  Created by Michal Ciurus on 12/05/17.
//  Copyright © 2017 CoonAndFriends. All rights reserved.
//

#import "FeedCollectionViewController.h"
#import "FlickrApi.h"
#import "CollectionCell.h"

@interface FeedCollectionViewController ()
@property (nonatomic) NSArray <NSURL *> *photos;
@end

@implementation FeedCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [FlickrApi fetchPhotosWithCompletion:^(NSArray *photos, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
        self.photos = photos;
        
        if (photos != nil || !error) {
            [self cacheImageWithArray:photos];
        }
        NSLog(@"result %@ error %@", photos, error);
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    if (self.photos != nil) {
        [cell setupWithPhoto:self.photos[indexPath.row]];
    } else {
        NSArray *imagePathArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"imagePathArray"];
        [cell setupWithPhoto:imagePathArray[indexPath.row]];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width, 256);
}

- (void) cacheImageWithArray:(NSArray*)photos {
    NSMutableArray *imagePathArray = [[NSMutableArray alloc] init];
    
    for (NSURL *url in photos) {
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",@"cached"]];
        
        if (![imageData writeToFile:imagePath atomically:NO])
        {
            NSLog(@"Failed to cache image data to disk");
        }
        else
        {
            [imagePathArray addObject:imagePath];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:imagePathArray forKey:@"imagePathArray"];
}


@end
