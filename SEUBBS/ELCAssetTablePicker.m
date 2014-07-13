//
//  ELCAssetTablePicker.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"

@interface ELCAssetTablePicker ()

@property (nonatomic, assign) int columns;
@property (nonatomic, strong)UIBarButtonItem *doneBarButton;
@end

@implementation ELCAssetTablePicker

//Using auto synthesizers

- (id)init
{
    self = [super init];
    if (self) {
        //Sets a reasonable default bigger then 0 for columns
        //So that we don't have a divide by 0 scenario
        self.columns = 4;
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.tableView setAllowsSelection:NO];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;



    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:((ELCAlbumPickerController *)self.parent).parent  action:@selector(cancelImagePicker)];
    
    [self.navigationItem setRightBarButtonItem:cancelButtonItem];


	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    UIBarButtonItem *preview = [[UIBarButtonItem alloc] initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(preview:)];
    self.doneBarButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[preview, flexibleSpace, self.doneBarButton];
    [self.navigationController setToolbarHidden:NO];
    
}


- (void)preview:(id)sender
{
    [self.parent preview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.columns = self.view.bounds.size.width / 80;
    [self.navigationController setToolbarHidden:NO];
    NSInteger total = [self.parent currentTotalSelections];
    if (total) {
        self.doneBarButton.title = [NSString stringWithFormat:@"完成(%ld)", (long)total];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.columns = self.view.bounds.size.width / 80;
    [self.tableView reloadData];
}

- (void)preparePhotos
{
    @autoreleasepool {

        [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if (result == nil) {
                return;
            }

            ELCAsset *elcAsset = [[ELCAsset alloc] initWithAsset:result];
            [elcAsset setParent:self];
            
            [self.elcAssets addObject:elcAsset];

         }];

        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            // scroll to bottom
            long section = [self numberOfSectionsInTableView:self.tableView] - 1;
            long row = [self tableView:self.tableView numberOfRowsInSection:section] - 1;
            if (section >= 0 && row >= 0) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:row
                                                     inSection:section];
                        [self.tableView scrollToRowAtIndexPath:ip
                                              atScrollPosition:UITableViewScrollPositionBottom
                                                      animated:NO];
            }
        });
    }
}

- (void)doneAction:(id)sender
{	
    [self.parent selectedAssets:nil];
}





- (void)assetSelected:(ELCAsset *)asset
{
    NSMutableArray *selectedAssetsImages = [[NSMutableArray alloc] init];
	for (ELCAsset *elcAsset in self.elcAssets) {
		if ([elcAsset selected]) {
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
    [self.parent selectedAssets:selectedAssetsImages forAlbum:self.title];
    NSInteger total = [self.parent currentTotalSelections];
    if (total) {
        self.doneBarButton.title = [NSString stringWithFormat:@"完成(%ld)", (long)total];
    } else {
        self.doneBarButton.title = @"完成";
    }
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.columns <= 0) { //Sometimes called before we know how many columns we have
        self.columns = 4;
    }
    NSInteger numRows = ceil([self.elcAssets count] / (float)self.columns);
    return numRows;
}

- (NSArray *)assetsForIndexPath:(NSIndexPath *)path
{
    long index = path.row * self.columns;
    long length = MIN(self.columns, [self.elcAssets count] - index);
    return [self.elcAssets subarrayWithRange:NSMakeRange(index, length)];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
        
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {		        
        cell = [[ELCAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setAssets:[self assetsForIndexPath:indexPath]];
    
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView;
    
    if (footerView != nil)
        return footerView;
    
    NSString *footerText = [NSString stringWithFormat:@"共%ld张照片", (long)self.elcAssets.count];
    float footerWidth = 150.0f;
    float padding = 10.0f;
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, footerWidth, 44.0f)];
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, footerWidth - 2.0f * padding, 44.0f)];
    footerLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.text = footerText;
    footerLabel.textColor = [UIColor lightGrayColor];
    
    [footerView addSubview:footerLabel];
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 79;
}

- (int)totalSelectedAssets
{
    int count = 0;
    
    for (ELCAsset *asset in self.elcAssets) {
		if (asset.selected) {
            count++;	
		}
	}
    
    return count;
}


@end
