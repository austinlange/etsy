//
//  ViewController.m
//  Etsy Project
//
//  Created by Austin Lange on 12/20/14.
//  Copyright (c) 2014 Austin Lange. All rights reserved.
//

#import "ALEtsyViewController.h"
#import "ALEtsyAPIClient.h"
#import "ALEtsyListingCollectionViewCell.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@class ALEtsyListingsAPI;

@interface ALEtsyViewController ()

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

@property (nonatomic, strong) ALEtsyListingsAPI *listingsAPI;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation ALEtsyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search for something!";
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [self.view addSubview:self.searchBar];

    self.navigationItem.titleView = self.searchBar;
    
    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewLayout.itemSize = [ALEtsyListingCollectionViewCell cellSize];
    self.collectionViewLayout.footerReferenceSize = CGSizeMake(0, 100);
    self.collectionViewLayout.minimumLineSpacing = 10.0;
    self.collectionViewLayout.minimumInteritemSpacing = 10.0;
    self.collectionViewLayout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.900 alpha:1.000];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.scrollsToTop = YES;
    
    [self.collectionView registerClass:[ALEtsyListingCollectionViewCell class] forCellWithReuseIdentifier:[ALEtsyListingCollectionViewCell identifier]];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.view addSubview:self.collectionView];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.indicatorView sizeToFit];
    self.indicatorView.hidesWhenStopped = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // kill the listings API's stored results cache
    
}

- (void)viewDidLayoutSubviews;
{
    self.collectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.collectionView.backgroundView.frame = self.collectionView.bounds;
}

- (ALEtsyListingsAPI *)listingsAPI;
{
    if (!_listingsAPI) {
        _listingsAPI = [ALEtsyListingsAPI listingsAPI];
        _listingsAPI.delegate = self;
    }
    
    return _listingsAPI;
}

#pragma mark UISearchBarDelegate
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
{
    NSString *searchText = searchBar.text;
    
    if ([searchText length] < 3) return;
    
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
    
    self.listingsAPI.keywords = searchText;
}

#pragma mark ALEtsyListingsAPIDelegate
- (void)listingsAPILoadedItemsAtIndexPaths:(NSArray *)indexPaths;
{
    [self.collectionView reloadData];
}

- (void)listingsAPIError:(NSError *)error;
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Bzzt!" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)listingsAPIDidStartLoading;
{
    [self.indicatorView startAnimating];
}

- (void)listingsAPIDidEndLoading;
{
    [self.indicatorView stopAnimating];
}

#pragma mark UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return [self.listingsAPI count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ALEtsyListingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ALEtsyListingCollectionViewCell identifier] forIndexPath:indexPath];

    ALEtsyListing *listing = [self.listingsAPI listingAtIndex:indexPath.item];
    
    if (listing) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.titleLabel.text = listing.title;
        [cell.imageView setImageWithURL:listing.image];
        [cell setNeedsLayout];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
{
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Footer" forIndexPath:indexPath];
    
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        if ([view.subviews count] == 0) {
            self.indicatorView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
            [view addSubview:self.indicatorView];
        }
    }
    
    return view;
}

#pragma mark UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.searchBar resignFirstResponder];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView;
{
    return YES;
}

@end
