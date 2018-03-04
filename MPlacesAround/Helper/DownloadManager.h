//
//  DownloadManager.h
//  PlacesAround
//
//  Created by Patalakh Vadim on 3/3/18.
//  Copyright © 2018 Patalakh Vadim. All rights reserved.
//

#import <Foundation/Foundation.h>

enum DownloadError
{
    notValidUrl = 0,
    couldNotDownloadData,
    couldNotParseData
};

@protocol DownloadManagerDelegate

- (void)didFinishLoadingPlaces:(NSArray *)places;
- (void)couldNotDownloadPlaces:(NSInteger)error;

@end

@interface DownloadManager : NSObject

@property (nonatomic, weak) NSObject<DownloadManagerDelegate>   *delegate;

+ (instancetype)shared;

- (void)downloadPlacesForLocation:(NSString *)string;

@end
