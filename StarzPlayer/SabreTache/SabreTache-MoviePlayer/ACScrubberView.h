//
//  ScrubberView.h
//  Filmnet
//
//  Created by me on 25/04/14.
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACScrubberView;

@protocol ACScrubberViewDelegate

- (void)scrubberViewDidBeginScrubbing:(ACScrubberView *)scrubberView ;
- (void)scrubberView:(ACScrubberView *)scrubberView didEndScrubbingAtValue:(double)newValue;

-(void) scrubberView:(ACScrubberView *)scrubberView didChangeValue:(double)newValue;

@end

@interface ACScrubberView : UIView
//@property (assign) double current;
@property (nonatomic, retain) UIImage * remainingImage;
@property (nonatomic, retain) UIImage * elapsedImage;
@property (nonatomic, retain) UIImage * bufferedImage;
@property (nonatomic, retain) UIImage * thumbImage;
@property (nonatomic, retain) UIColor * remainingBGColor;
@property (nonatomic, retain) UIColor * elapsedBGColor;
@property (nonatomic, retain) UIColor * bufferedBGColor;
@property (nonatomic, retain) UIColor * thumbBGColor;
@property (assign) CGFloat sideMargin;
@property (assign) CGFloat scrubberHeight;
@property (assign) CGFloat bufferedHeight;
@property (nonatomic, assign) CGFloat thumbImageHeight;
@property (assign) BOOL bufferFromCurrentPosition;
@property (nonatomic) BOOL enabled;

@property (assign) double duration;
@property (assign) IBOutlet id <ACScrubberViewDelegate> delegate;
-(void) setValue:(long long)value animated:(BOOL)animated;
-(void) setValue: (long long)value buffered:(long long)buffered animated:(BOOL)animated;
-(long long)value;
-(long long)bufferedValue;
-(void)setValue:(long long)value;
@end
