//
//  Place.h
//  PlacesAround
//
//  Created by Patalakh Vadim on 3/2/18.
//  Copyright © 2018 Patalakh Vadim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject

@property (atomic, strong)   NSURL       *image;
@property (atomic, strong)   NSString    *name;
@property (atomic, strong)   NSString    *address;
@property (atomic, strong)   NSString    *location;

@end
