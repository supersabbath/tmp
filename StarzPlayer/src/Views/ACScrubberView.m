//
//  ScrubberView.m
//  Filmnet
//
//  Created by me on 25/04/14.
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import "ACScrubberView.h"


#define CURRENT_POSITION_TAG 7778800
#define REMAINING_IMAGE_TAG 7778801
#define ELAPSED_IMAGE_TAG 7778802
#define BUFFERED_IMAGE_TAG 7778803
#define BUTTON_IMAGE_TAG 7778804
#define SCRUBBER_IMAGE_TAG 7778805



@interface ACScrubberView () {
    BOOL constraintSetup;
    BOOL inited;
}
@property (retain) UIImageView * scrubberImageView;
@property (retain) UIImageView * elapsedTimeImageView;
@property (retain) UIImageView * remainingTimeImageView;
@property (retain) NSLayoutConstraint* scrubberButtonPositionConstant;
@property (retain) UIImageView* bufferedImageView;
@property (retain) NSLayoutConstraint* bufferedImageViewWidthConstraint;
@property (retain) UIView * currentPositionView;

@property (assign) BOOL seeking;
@property (assign) long long lastposition;

@property (assign) long long current;
@property (assign) long long lastbuffered;
@end

@implementation ACScrubberView
@synthesize enabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        // Initialization code
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void) initialize
{
    if (!inited)
    {
        inited = YES;
        _sideMargin = 0;
        _scrubberHeight = 48;
        _bufferedHeight = 48;
        _thumbImageHeight = 20;
        enabled = YES;
        _bufferFromCurrentPosition = YES;

        _remainingBGColor = [UIColor whiteColor];
        _elapsedBGColor = [UIColor blueColor];
        _bufferedBGColor = [UIColor grayColor];
        _thumbBGColor = [UIColor blackColor];
    }
    
    
    
}

CGRect prevFrame;
-(void)setValue: (long long)value buffered:(long long)buffered force: ( BOOL) force {
    if (self.seeking && !force){
        return;
    }
    if (!force && value==self.lastposition && buffered == self.lastbuffered && CGRectEqualToRect(prevFrame, self.frame)){
        
        return;
    }
    prevFrame = self.frame;
    if (!force){
        self.lastposition = value;
    }
    self.lastbuffered = buffered;
    self.current = value;
    double progress = 0;
    double buffer = 0;
    if (self.duration>0){
        progress = value / self.duration;
        buffer = buffered / self.duration;
    }
    float maxwidth = MAX(0,self.frame.size.width - 2*self.sideMargin);
    float cx = MIN(MAX( maxwidth *progress, 10), maxwidth - 10) + self.sideMargin;
    float bw = MAX(0, MIN( maxwidth *buffer, maxwidth) - (self.bufferFromCurrentPosition ? MAX(self.sideMargin , cx - self.sideMargin) : self.sideMargin)) ;
    self.scrubberButtonPositionConstant.constant = cx ;
    self.bufferedImageViewWidthConstraint.constant = bw;
    [self.scrubberImageView setNeedsUpdateConstraints];
    [self.bufferedImageView setNeedsUpdateConstraints];
    [self setNeedsLayout];
    
   
}


-(void) layoutSubviews {
    [super layoutSubviews];
    //[self update:self.current buffered:self.lastbuffered animated:NO];
   

}


-(void) setValue: (long long)value animated:(BOOL)animated {

    [self setValue:value buffered:0 animated:animated];
}

-(void) setValue: (long long)value buffered:(long long)buffered animated:(BOOL)animated {
    if (animated)
    {
        [UIView animateWithDuration:0.1 animations:^{
            [self setValue:value buffered:buffered force:NO];
        }];
    }
    else
    {
        [self setValue:value buffered:buffered force:NO];
    }
}

-(void)setValue:(long long)value
{
    [self setValue:value animated:NO];
}

-(long long)value
{
    return self.current;
}

-(long long)bufferedValue {
    return self.lastbuffered;
}

-(void) setup {
    [self initialize];
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = self.frame.size.height / 2;
    
 
    
    self.remainingTimeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 3, self.scrubberHeight)];
    self.remainingTimeImageView.tag = REMAINING_IMAGE_TAG;
    if (self.remainingImage)
    {
        [self.remainingTimeImageView setImage:self.remainingImage];
        [self.remainingTimeImageView setBackgroundColor:[UIColor clearColor]];
    }
    else
    {
        [self.remainingTimeImageView setBackgroundColor:self.remainingBGColor];
    }
    [self.remainingTimeImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.remainingTimeImageView];
    

    self.bufferedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 3, self.bufferedHeight)];
    self.bufferedImageView.tag = BUFFERED_IMAGE_TAG;
    if (self.bufferedImage)
    {
        [self.bufferedImageView setImage:self.bufferedImage];
        [self.bufferedImageView setBackgroundColor:[UIColor clearColor]];
    }
    else
    {
        [self.bufferedImageView setBackgroundColor:self.bufferedBGColor];
    }
    
    [self.bufferedImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.bufferedImageView];

    
    self.elapsedTimeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 3, self.scrubberHeight)];
    self.elapsedTimeImageView.tag = ELAPSED_IMAGE_TAG;
    if (self.elapsedImage)
    {
        [self.elapsedTimeImageView setImage:self.elapsedImage];
        [self.elapsedTimeImageView setBackgroundColor:[UIColor clearColor]];
    }
    else
    {
        [self.elapsedTimeImageView setBackgroundColor:self.elapsedBGColor];
    }
    
    [self.elapsedTimeImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.elapsedTimeImageView];

    self.currentPositionView = [[UIView alloc] initWithFrame:CGRectMake(self.sideMargin, 0, 0, 1)];
    self.currentPositionView.tag = CURRENT_POSITION_TAG;
    [self.currentPositionView setTranslatesAutoresizingMaskIntoConstraints:NO];
     [self addSubview:self.currentPositionView];
    
    self.scrubberImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.thumbImageHeight, self.thumbImageHeight)];
    self.scrubberImageView.tag = SCRUBBER_IMAGE_TAG;
    if (self.thumbImage)
    {
        self.scrubberImageView.image = self.thumbImage;
        [self.scrubberImageView setBackgroundColor:[UIColor clearColor]];
        
    }
    else
    {
        [self.scrubberImageView setBackgroundColor:self.thumbBGColor];
    }
    
    [self addSubview:self.scrubberImageView];
    
    [self.scrubberImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.scrubberImageView.hidden = !self.enabled;
}

- (void)clearViews
{
    [[self viewWithTag:SCRUBBER_IMAGE_TAG] removeFromSuperview];
    [[self viewWithTag:BUTTON_IMAGE_TAG] removeFromSuperview];
    [[self viewWithTag:REMAINING_IMAGE_TAG] removeFromSuperview];
    [[self viewWithTag:BUFFERED_IMAGE_TAG] removeFromSuperview];
    [[self viewWithTag:ELAPSED_IMAGE_TAG] removeFromSuperview];
    [[self viewWithTag:CURRENT_POSITION_TAG] removeFromSuperview];
      constraintSetup = NO;
    
}

- (void) reinint
{
    [self clearViews];
    [self setup];
    [self updateConstraints];
}

- (void) updateConstraints {
    if (!constraintSetup) {
        constraintSetup = YES;
        NSDictionary* views = @{@"elapsed": self.elapsedTimeImageView,
                                @"button": self.scrubberImageView,
                                @"remaining": self.remainingTimeImageView,
                                @"buffered": self.bufferedImageView,
                                @"current": self.currentPositionView};
        
        NSDictionary* metrics = @{@"side": @(self.sideMargin)};
        
        [self addConstraint:  [NSLayoutConstraint constraintWithItem:self.currentPositionView
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:0]];
        [self addConstraint:  [NSLayoutConstraint constraintWithItem:self.currentPositionView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:0]];
        
        [self addConstraint:  [NSLayoutConstraint constraintWithItem:self.scrubberImageView
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.currentPositionView
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier:1.0
                                                            constant:0]];
        
        [self addConstraint:  [NSLayoutConstraint constraintWithItem:self.elapsedTimeImageView
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:0]];
        [self addConstraint:  [NSLayoutConstraint constraintWithItem:self.elapsedTimeImageView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:self.scrubberHeight]];
        
        [self addConstraint:  [NSLayoutConstraint constraintWithItem:self.scrubberImageView
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:0]];
        [self addConstraint:  [NSLayoutConstraint constraintWithItem:self.scrubberImageView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:self.thumbImageHeight]];
        [self addConstraint:  [NSLayoutConstraint constraintWithItem:self.scrubberImageView
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:self.thumbImageHeight]];
        [self addConstraint:  [NSLayoutConstraint constraintWithItem:self.remainingTimeImageView
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:0]];
        [self addConstraint:  [NSLayoutConstraint constraintWithItem:self.remainingTimeImageView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:self.scrubberHeight]];
        
        [self addConstraint:  [NSLayoutConstraint constraintWithItem:self.bufferedImageView
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:0]];
        [self addConstraint:  [NSLayoutConstraint constraintWithItem:self.bufferedImageView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier: 1.0
                                                            constant:self.bufferedHeight]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrubberImageView
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.currentPositionView
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                          constant:0]];
        
        self.scrubberButtonPositionConstant = [NSLayoutConstraint constraintWithItem:self.currentPositionView
                                                                          attribute:NSLayoutAttributeCenterX
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1.0
                                                                           constant:10];
        [self.scrubberButtonPositionConstant setPriority:UILayoutPriorityRequired];
        [self addConstraint:self.scrubberButtonPositionConstant];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(side)-[elapsed]-(0)-[current(0)]-(0)-[remaining]-(side)-|"
                                                                     options:NSLayoutFormatDirectionLeftToRight
                                                                     metrics:metrics
                                                                       views:views]];
        if (self.bufferFromCurrentPosition)
        {
            [self addConstraint:  [NSLayoutConstraint constraintWithItem:self.bufferedImageView
                                                           attribute:NSLayoutAttributeLeft
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.currentPositionView
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier: 1.0
                                                            constant:0]];
        }
        else
        {
            [self addConstraint:  [NSLayoutConstraint constraintWithItem:self.bufferedImageView
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier: 1.0
                                                                constant:self.sideMargin]];
        }
        self.bufferedImageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.bufferedImageView
                                                                             attribute:NSLayoutAttributeWidth
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:nil
                                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                                            multiplier:1.0
                                                                              constant:0];
        
        [self.bufferedImageViewWidthConstraint setPriority:UILayoutPriorityRequired];
        [self addConstraint:self.bufferedImageViewWidthConstraint];
    }
    [super updateConstraints];
}

-(double) seek: (float)x {

    double progress = 0 ;
    if (x > self.sideMargin){
        double xinrange = x - self.sideMargin;
        double range = self.frame.size.width - 2*self.sideMargin;
        progress = MIN(xinrange/range,1.0);
    }
    return self.duration * progress;
    
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.enabled)
    {
      
        UITouch *touch  = [touches anyObject];
        if (touch) {
            self.seeking = YES;
            
            [self.delegate scrubberViewDidBeginScrubbing:self];
            CGPoint location = [touch locationInView:self];
            double time = [self seek:location.x];
            [self.delegate scrubberView:self didChangeValue:time];
            [self setValue:time buffered:(self.bufferFromCurrentPosition ? 0 : self.lastbuffered) force:YES];
        }
    }
        [super touchesBegan:touches withEvent:event];
    
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled)
    {
        self.seeking = NO;
    
        [self.delegate scrubberView:self didEndScrubbingAtValue:self.current];
    }
    [super touchesCancelled:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.enabled)
    {
        UITouch *touch  = [touches anyObject];
        if (touch) {
            
            self.seeking = YES;
            CGPoint location = [touch locationInView:self];
            double time = [self seek:location.x];
            [self.delegate scrubberView:self didChangeValue:time];
            [self setValue:time buffered:(self.bufferFromCurrentPosition ? 0 : self.lastbuffered) force:YES];
        }
    }
    [super touchesMoved:touches withEvent:event];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled)
    {
        self.seeking = NO;
    
        [self.delegate scrubberView:self didEndScrubbingAtValue:self.current];
    }
    [super touchesEnded:touches withEvent:event];
}


-(void)setBufferedBGColor:(UIColor *)bufferedBGColor
{
    _bufferedBGColor = bufferedBGColor;
    [self reinint];
}

-(void)setBufferedImage:(UIImage *)bufferedImage
{
    _bufferedImage = bufferedImage;
    [self reinint];
}

-(void)setThumbBGColor:(UIColor *)thumbBGColor
{
    _thumbBGColor = thumbBGColor;
    [self reinint];
}

-(void)setThumbImage:(UIImage *)thumbImage
{
    _thumbImage = thumbImage;
    [self reinint];
}

- (void)setThumbImageHeight:(CGFloat)thumbImageHeight
{
    _thumbImageHeight = thumbImageHeight;
    
    UIImageView * img = (UIImageView *)[self viewWithTag:SCRUBBER_IMAGE_TAG];
    
    CGRect f = img.frame;
    f.size = CGSizeMake(thumbImageHeight, thumbImageHeight);
    img.frame = f;
    
    [img setNeedsUpdateConstraints];
    
    [self.scrubberImageView setNeedsLayout];
    [self layoutIfNeeded];
}

-(void)setElapsedBGColor:(UIColor *)elapsedBGColor
{
    _elapsedBGColor = elapsedBGColor;
    [self reinint];
}

-(void)setElapsedImage:(UIImage *)elapsedImage
{
    _elapsedImage = elapsedImage;
    [self reinint];
}

-(void)setRemainingBGColor:(UIColor *)remainingBGColor
{
    _remainingBGColor = remainingBGColor;
    [self reinint];
}

-(void)setRemainingImage:(UIImage *)remainingImage
{
    _remainingImage = remainingImage;
    [self reinint];
}

-(void)setEnabled:(BOOL)enable
{
    enabled = enable;
    [self reinint];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
