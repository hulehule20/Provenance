//
//  ServiceProvider.m
//  TopShelf
//
//  Created by Marc Clascà on 12/10/15.
//  Copyright © 2015 James Addyman. All rights reserved.
//

#import "ServiceProvider.h"
#import "PVAppDelegate.h"
#import "PVGameImporter.h"
#import "PVGameLibraryViewController.h"
#import "PVGameLibraryCollectionViewCell.h"
#import "PVEmulatorViewController.h"
#import "UIView+FrameAdditions.h"
#import "PVDirectoryWatcher.h"
#import "PVGame.h"
#import "PVRecentGame.h"
#import "PVMediaCache.h"
#import "UIAlertView+BlockAdditions.h"
#import "UIActionSheet+BlockAdditions.h"
#import "PVEmulatorConfiguration.h"
#if !TARGET_OS_TV
#import <AssetsLibrary/AssetsLibrary.h>
#import "PVSettingsViewController.h"
#endif
#import "UIImage+Scaling.h"
#import "PVGameLibrarySectionHeaderView.h"
#import "MBProgressHUD.h"
#import "NSData+Hashing.h"
#import "PVSettingsModel.h"
#import "PVConflictViewController.h"
#import "PVWebServer.h"
#import "Reachability.h"
#import "PVControllerManager.h"

@interface ServiceProvider ()


@end

@implementation ServiceProvider


- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - TVTopShelfProvider protocol

- (TVTopShelfContentStyle)topShelfStyle {
    // Return desired Top Shelf style.
    return TVTopShelfContentStyleInset;
}

- (NSArray *)topShelfItems {

    
    //Fetch the games
    RLMRealmConfiguration *config = [[RLMRealmConfiguration alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    [config setPath:[[paths firstObject] stringByAppendingPathComponent:@"default.realm"]];
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm refresh];
    NSMutableArray *itemSections = [NSMutableArray array];
    NSMutableDictionary *tempSections = [NSMutableDictionary dictionary];
    
    for (PVGame *game in [[PVGame allObjects] sortedResultsUsingProperty:@"title" ascending:YES])
    {
        NSLog(@"Found game: %@", game.title);
        NSString *systemID = [game systemIdentifier];
        NSMutableArray *games = [[tempSections objectForKey:systemID] mutableCopy];
        if (!games)
        {
            games = [NSMutableArray array];
        }
        
        //Convert the game to a contentItem
        TVContentItem *contentItem = [self contentItemWithGameItem:game];
        
        [games addObject:contentItem];
        [tempSections setObject:games forKey:systemID];
    }
    
    
    for(NSString *key in tempSections) {
        TVContentIdentifier *identifier = [[TVContentIdentifier alloc] initWithIdentifier:key container:nil];
        TVContentItem *currentSection = [[TVContentItem alloc] initWithContentIdentifier:identifier];
        currentSection.title = key;
        currentSection.topShelfItems = [tempSections objectForKey:key];
        
        [itemSections addObject:currentSection];
    }
    
    //return the array
    return itemSections;
}

-(TVContentItem *)contentItemWithGameItem:(PVGame *)game {
    TVContentIdentifier *identifier = [[TVContentIdentifier alloc] initWithIdentifier:game.md5Hash container:nil];
    
    TVContentItem *contentItem = [[TVContentItem alloc] initWithContentIdentifier:identifier];
    contentItem.title = game.title;
    contentItem.displayURL = [NSURL URLWithString:game.romPath];
    contentItem.imageURL = [NSURL URLWithString:game.originalArtworkURL];
    contentItem.imageShape = TVContentItemImageShapeWide;
    
    return contentItem;
}

@end
