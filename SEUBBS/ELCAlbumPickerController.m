//
//  AlbumPickerController.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "ELCAssetTablePicker.h"
#import "MultiPhotoViewController.h"

@interface ELCAlbumPickerController ()

@property (nonatomic, strong) ALAssetsLibrary *library;
@property (nonatomic, strong)NSMutableDictionary *selectedAssets;
@property (nonatomic, strong)NSMutableDictionary *pickers;
@end

@implementation ELCAlbumPickerController

//Using auto synthesizers

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pickers = [[NSMutableDictionary alloc] init];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
	[self.navigationItem setTitle:@"Loading..."];

    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self.parent  action:@selector(cancelImagePicker)];
	[self.navigationItem setRightBarButtonItem:cancelButtonItem];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.assetGroups = tempArray;
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    self.library = assetLibrary;
    
    self.selectedAssets = [[NSMutableDictionary alloc]init];

    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^
    {
        @autoreleasepool {
        
        // Group enumerator Block
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
            {
                if (group == nil) {
                    return;
                }
                
                // added fix for camera albums order
                NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                 NSInteger gCount = [group numberOfAssets];

                if ([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"] && nType == ALAssetsGroupSavedPhotos) {
                    if (gCount) {
                         [self.assetGroups insertObject:group atIndex:0];
                    }
                }
                else {
                    if (gCount) {
                        [self.assetGroups addObject:group];
                    }
                }

                // Reload albums
                [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
            };
            
            // Group Enumerator Failure Block
            void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
                NSLog(@"A problem occured %@", [error description]);	                                 
            };	
                    
            // Enumerate Albums
            [self.library enumerateGroupsWithTypes:ALAssetsGroupAll
                                   usingBlock:assetGroupEnumerator 
                                 failureBlock:assetGroupEnumberatorFailure];
        
        }
    });    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
    [UIApplication sharedApplication].delegate.window.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
}


- (void)reloadTableView
{
	[self.tableView reloadData];
	[self.navigationItem setTitle:@"相册"];
}

-(void)preview
{
    NSArray *images = [_parent imageArray:[self totalAssets]];
    MultiPhotoViewController *vc = [[MultiPhotoViewController alloc]initWithImages:images];
    vc.parent = self;
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)doneAction:(id)sender
{
    [_parent selectedAssets:[self totalAssets]];
}

- (NSInteger)currentTotalSelections
{
    NSInteger total = 0;
    NSArray *keys = [self.selectedAssets allKeys];

    for (NSString *key in keys) {
        total += ((NSArray *)self.selectedAssets[key]).count;
    }
    
    return total;
}

- (void)selectedAssets:(NSArray *)assets forAlbum:(NSString *)album
{
    self.selectedAssets[album] = assets;
}

- (NSArray *)totalAssets
{
    NSMutableArray *totalAssets = [[NSMutableArray alloc]init];
    NSArray *keys = [self.selectedAssets allKeys];
    for (NSString *key in keys) {
        NSArray *arr = (NSArray *)self.selectedAssets[key];
        [totalAssets addObjectsFromArray:arr];
    }
    return totalAssets;
}

- (void)selectedAssets:(NSArray*)assets
{
	[_parent selectedAssets:[self totalAssets]];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.assetGroups count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get count
    ALAssetsGroup *g = (ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row];
    [g setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSInteger gCount = [g numberOfAssets];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)",[g valueForProperty:ALAssetsGroupPropertyName], (long)gCount];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row] posterImage]]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	

    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetsGroup *g = (ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row];
    [g setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSString *title = [g valueForProperty:ALAssetsGroupPropertyName];
    
    ELCAssetTablePicker *picker = [self.pickers objectForKey:title];
    if (picker == nil) {
         picker= [[ELCAssetTablePicker alloc] initWithNibName: nil bundle: nil];
        [self.pickers setObject:picker forKey:title];
    }
	picker.parent = self;
    picker.title = title;
    picker.assetGroup = [self.assetGroups objectAtIndex:indexPath.row];
    [picker.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];

	
	[self.navigationController pushViewController:picker animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 57;
}

@end

