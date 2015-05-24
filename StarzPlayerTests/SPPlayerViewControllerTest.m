//
//  SPPlayerViewControllerTest.m
//  StarzPlayer
//
//  Created by Fernando Canon on 19/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

//
#import "SPPlayerViewController.h"
#import "SPPlayerControlView.h"
//colaborator
#define EXP_SHORTHAND
#import <Expecta.h>
#import <OCMock/OCMock.h>


@interface SPPlayerViewControllerTest : XCTestCase {
    
    SPPlayerViewController *sut;
}

@end

@implementation SPPlayerViewControllerTest

- (void)setUp {
 
    [super setUp];
    sut = [[SPPlayerViewController alloc] init];
 
}

- (void)tearDown {
    
    [super tearDown];
}

- (void)testControlViewShouldBeConnected
{
    [sut view];

    expect(sut.controlView).toNot.beNil();
}

- (void)testControlViewDelegateShouldBeConnected
{
    [sut view];
    expect(sut.controlView.delegate).to.beIdenticalTo(sut);
}

#pragma mark Play Button
- (void)testPlayAndPauseButtonAction
{
    [sut view];
    
    expect([sut.controlView.playButton actionsForTarget:sut.controlView forControlEvent:UIControlEventTouchUpInside]).to.contain(@"playTouch:");

}

-(void) testPauseButtonCallback
{
    id protocolMock = OCMPartialMock(sut);
    
    [sut view];
    
    [sut.controlView setDelegate:protocolMock];
    [sut.controlView.playButton setSelected:YES];
    [sut.controlView.playButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    OCMVerify([protocolMock view:[OCMArg any] didReceivePauseTouch:[OCMArg any]]);
}

-(void) testPlayButtonCallback
{
    id protocolMock = OCMPartialMock(sut);
    
    [sut view];
    
    [sut.controlView setDelegate:protocolMock];
    [sut.controlView.playButton setSelected:NO];
    [sut.controlView.playButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    OCMVerify([protocolMock view:[OCMArg any] didReceivePlayTouch:[OCMArg any]]);
}

#pragma mark Slider control

- (void)testSliderShouldBeConnected
{
    [sut view];
    
    expect(sut.controlView.scrubber).toNot.beNil();
}



- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - LANG

- (void)testLANGButtonShouldBeConnected
{

    id protocolMock = OCMPartialMock(sut);
    
    [sut view];
    
    [sut.controlView setDelegate:protocolMock];
    UIButton *lang = (UIButton *)[sut.controlView viewWithTag:543];  // tag added just for testing
    [lang sendActionsForControlEvents:UIControlEventTouchUpInside];
    OCMVerify([protocolMock view:[OCMArg any] didReceiveLANGButtonTouch:[OCMArg any]]);

}


#pragma mark - VOLUME

- (void)testVolumenButtonDShouldBeConnected
{
    
    id protocolMock = OCMPartialMock(sut);
    
    [sut view];
    
    [sut.controlView setDelegate:protocolMock];
    UIButton *lang = (UIButton *)[sut.controlView viewWithTag:545];  // tag added just for testing
    [lang sendActionsForControlEvents:UIControlEventTouchUpInside];
    OCMVerify([protocolMock view:[OCMArg any] didReceiveVolumenButtonTouch:[OCMArg any]]);
    
}


@end
