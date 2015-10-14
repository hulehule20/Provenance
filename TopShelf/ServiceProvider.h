//
//  ServiceProvider.h
//  TopShelf
//
//  Created by Marc Clascà on 12/10/15.
//  Copyright © 2015 James Addyman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TVServices/TVServices.h>
#import "PVGame.h"
#import <Realm/Realm.h>


@interface ServiceProvider : NSObject <TVTopShelfProvider>

- (TVContentItem *)contentItemWithGameItem:(PVGame *)game;

@end

