//
//  AccedoSubtitleProvider.h
//  Filmnet
//
//  Created by Csaba Tűz on 2014.04.29..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `SubtitleRef` can be used as a reference to an online subtitle for a movie.
 */
@interface SubtitleRef : NSObject

/** The text to be shown when subtitle selection is needed. */
@property (retain, nonatomic) NSString * title;
/** The locale which tells the subtitle language. */
@property (retain, nonatomic) NSLocale * locale;
/** The url where the subtitle is downloadable from. */
@property (retain, nonatomic) NSURL * url;

@end

@interface SubtitleEntry : NSObject

@property (assign, nonatomic) NSTimeInterval timeToNext;
@property (retain, nonatomic) NSString * sub;

@end

extern NSString * const SubtitleProviderDidSelectSubtitleNotification;


@protocol SubtitleProviderDelegate;

@protocol SubtitleProvider <NSObject>

@property (assign) id<SubtitleProviderDelegate> delegate;

- (NSString *)defaultSubtitle;

- (NSArray *)availableSubtitles;
- (SubtitleRef *)currentSubtitle;

- (SubtitleEntry *)subtitleForTime:(NSTimeInterval)time;

- (void)selectSubtitle:(SubtitleRef *)item;

- (void)selectSubtitleWithLocale:(NSString *)locale;

@end


@protocol SubtitleProviderDelegate <NSObject>

- (void)subtitleProvider:(id<SubtitleProvider>)subtitleProvider didChangeSubtitle:(SubtitleRef *)newSubtitle;

@end