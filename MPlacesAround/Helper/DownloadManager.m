//
//  DownloadManager.m
//  PlacesAround
//
//  Created by Patalakh Vadim on 3/3/18.
//  Copyright © 2018 Patalakh Vadim. All rights reserved.
//

#import "DownloadManager.h"
#import "Place.h"
#import "NSString_stripHtml.h"

#define kUrlScheme          @"https"
#define kUrlHost            @"places.demo.api.here.com/places/v1/discover/around"
#define kUrlGeoString       @"Geolocation=geo:"
#define kAppIdAndCodeForUrl @"&app_id=DemoAppId01082013GAL&app_code=AJKnXv84fjrb0KIHawS0Tg#"

#define kJsonResultKey      @"results"
#define kJsonItemsKey       @"items"
#define kJsonTitleKey       @"title"
#define kJsonPositionKey    @"position"
#define kJsonAddressKey     @"vicinity"
#define kJsonIconKey        @"icon"

static DownloadManager*   sharedManager = nil;
@interface DownloadManager ()

@property (nonatomic, strong)   NSURLComponents   *urlComponents;

@end

@implementation DownloadManager

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [DownloadManager new];
    });
    
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.urlComponents = [[NSURLComponents alloc] init];
        self.urlComponents.scheme = kUrlScheme;
        self.urlComponents.host = kUrlHost;
    }
    
    return self;
}

- (void)downloadPlacesForLocation:(NSString *)string
{
    NSString *query = [kUrlGeoString stringByAppendingString:string];
    query = [query stringByAppendingString:kAppIdAndCodeForUrl];
    self.urlComponents.query = query;
    
    NSString *urlString = [self.urlComponents.string stringByRemovingPercentEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (!url)
    {
        [self.delegate couldNotDownloadPlaces:notValidUrl];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        
        if (!urlData)
        {
            [self.delegate couldNotDownloadPlaces:couldNotDownloadData];
            return;
        }
        
        NSError *error = nil;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:urlData options:kNilOptions error:&error];
        
        if (error)
        {
            [self.delegate couldNotDownloadPlaces:couldNotParseData];
            return;
        }
        
        [self parseJsonDictionary:jsonData];
    });
}

- (void)parseJsonDictionary:(NSDictionary *)dictionary
{
    NSDictionary *resultDictionary = [dictionary objectForKey:kJsonResultKey];
    NSArray *items = [resultDictionary objectForKey:kJsonItemsKey];
    NSMutableArray *placesArray = [NSMutableArray new];
    
    //TODO: check if key is not present
    [items enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Place *place = [Place new];
        place.name = [obj objectForKey:kJsonTitleKey];
        place.address = [((NSString *)[obj objectForKey:kJsonAddressKey]) stripHtml];
        place.image = [NSURL URLWithString:[obj objectForKey:kJsonIconKey]];
        NSArray *address = [obj objectForKey:kJsonPositionKey];
        place.location = [NSString stringWithFormat:@"%@,%@", address[0], address[1]];
        
        [placesArray addObject:place];
    }];
    
    [self.delegate didFinishLoadingPlaces:placesArray];
}

@end
