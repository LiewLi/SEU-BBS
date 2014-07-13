//
//  ELCAssetSelectionDelegate.h
//  ELCImagePickerDemo
//
//  Created by JN on 9/6/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ELCAsset;

@protocol ELCAssetSelectionDelegate <NSObject>

- (void)selectedAssets:(NSArray *)assets;
@optional
- (void)selectedAssets:(NSArray *)assets forAlbum:(NSString *)album;
- (void)cancelImagePicker;
- (NSInteger) currentTotalSelections;
- (void)preview;
-(NSArray *)imageArray:(NSArray *)assets;
@end
