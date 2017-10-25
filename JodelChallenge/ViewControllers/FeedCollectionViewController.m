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
    @property (nonatomic) BOOL isLoadingImages;
@end

@implementation FeedCollectionViewController {
    UIImageView *fullscreenImageView;
    UIImageView *originalImageView;
}

/**
 * Fetch images from Flickr API and put it in cache
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isLoadingImages = YES;
    
    [FlickrApi fetchPhotosWithCompletion:^(NSArray *photos, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            self.isLoadingImages = NO;
        });
        self.photos = photos;
        
        if (photos != nil || !error) {
            [self cacheImageWithArray:photos];
            self.isLoadingImages = NO;
        }
        NSLog(@"result %@ error %@", photos, error);
    }];
}

/**
 * Hide fullscreen when changing orientation
 * @param fromInterfaceOrientation Old device orientation
 */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self animationDone:self.view];
    [self.collectionView reloadData];
}

#pragma collectionView methods
/**
 * Set number of items in section (only one section here, so all items found)
 * @param collectionView Collection view
 * @return Number of items in section (all items found)
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.photos != nil) {
        return self.photos.count;
    } else {
        NSArray *imagePathArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"imagePathArray"];
        return imagePathArray.count;
    }
}

/**
 * Set image, title and activity indicator for cell in collectionView
 * @param collectionView Collection view
 * @param indexPath Index of image to set
 * @return Cell with correct image and title
 */
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    if (self.isLoadingImages) {
        [cell.activityIndicator startAnimating];
    } else {
        [cell.activityIndicator stopAnimating];
    }
    
    if (self.photos != nil) {
        [cell setupWithPhoto:self.photos[indexPath.row]];
        [cell setupWithTitle:self.photos[indexPath.row].lastPathComponent];
    } else {
        NSArray *imagePathArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"imagePathArray"];
        NSURL *imagePath = imagePathArray[indexPath.row];
        [cell setupWithPhoto:imagePath];
        [cell setupWithTitle:imagePath.lastPathComponent];
    }
    
    return cell;
}

/**
 * Set image size in collectionView
 * @param collectionView Collection view
 * @param collectionViewLayout Collection view layout
 * @param indexPath Index of image to resize
 * @return Image size
 */
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width, 256);
}

/**
 * Open fullscreen mode for image tapped
 * @param collectionView Collection view
 * @param indexPath index of image tapped
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    originalImageView = [cell imageView];
    fullscreenImageView = [[UIImageView alloc] init];
    [fullscreenImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    if (self.photos != nil) {
        fullscreenImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photos[indexPath.row]]];
    } else {
        NSArray *imagePathArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"imagePathArray"];
        fullscreenImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imagePathArray[indexPath.row]]];
    }
    
    CGRect tempPoint = CGRectMake(originalImageView.center.x, originalImageView.center.y, 0, 0);
    CGRect startingPoint = [self.view convertRect:tempPoint fromView:[self.collectionView cellForItemAtIndexPath:indexPath]];
    [fullscreenImageView setFrame:startingPoint];
    [fullscreenImageView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.9f]];
    
    [self.view addSubview:fullscreenImageView];
    [UIView animateWithDuration:0.4
                     animations:^{
                         [fullscreenImageView setFrame:CGRectMake(0,
                                                                  0,
                                                                  self.view.bounds.size.width,
                                                                  self.view.bounds.size.height)];
                     }];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenImageViewTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [fullscreenImageView addGestureRecognizer:singleTap];
    [fullscreenImageView setUserInteractionEnabled:YES];
}

#pragma specific methods
/**
 * Gesture recognizer when in fullscreen mode to return to collectionView
 * @param gestureRecognizer Gesture recognizer
 */
- (void)fullScreenImageViewTapped:(UIGestureRecognizer *)gestureRecognizer {
    CGRect point=[self.view convertRect:originalImageView.bounds fromView:originalImageView];
    
    gestureRecognizer.view.backgroundColor=[UIColor clearColor];
    [UIView animateWithDuration:0.5
                     animations:^{
                         [(UIImageView *)gestureRecognizer.view setFrame:point];
                     }];
    [self performSelector:@selector(animationDone:) withObject:[gestureRecognizer view] afterDelay:0.4];
}

/**
 * Hide and delete infos in fullscreen view
 * @param view Parent view
 */
-(void)animationDone:(UIView  *)view {
    [fullscreenImageView removeFromSuperview];
    fullscreenImageView = nil;
}

/**
 * Cache images within iPhone's NSPictureDirectory
 * @param photos Array of NSURL to grab pictures
 */
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
