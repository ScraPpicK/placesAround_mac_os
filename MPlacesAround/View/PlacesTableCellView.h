//
//  PlacesTableCellView.h
//  MPlacesAround
//
//  Created by Patalakh Vadim on 3/4/18.
//  Copyright © 2018 Patalakh Vadim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PVAsyncImageView.h"

@interface PlacesTableCellView : NSTableCellView

@property (weak) IBOutlet PVAsyncImageView  *iconImageView;
@property (weak) IBOutlet NSTextField       *nameTextField;
@property (weak) IBOutlet NSTextField       *addressTextField;
@property (weak) IBOutlet NSTextField       *coordinatesTextField;

@end
