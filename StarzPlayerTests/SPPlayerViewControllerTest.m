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

- (void)testcontrolsContainerViewShouldBeConnected
{
    [sut view];

    expect(sut.controlsContainerView).toNot.beNil();
}

- (void)testControlViewDelegateShouldBeConnected
{
    [sut view];
    expect(sut.controlsContainerView.delegate).to.beIdenticalTo(sut);
}

#pragma mark Play Button
- (void)testPlayAndPauseButtonAction
{
    [sut view];
    
    expect([sut.controlsContainerView.playButton actionsForTarget:sut.controlsContainerView forControlEvent:UIControlEventTouchUpInside]).to.contain(@"playTouch:");

}

-(void) testPauseButtonCallback
{
    id protocolMock = OCMPartialMock(sut);
    
    [sut view];
    
    [sut.controlsContainerView setDelegate:protocolMock];
    [sut.controlsContainerView.playButton setSelected:YES];
    [sut.controlsContainerView.playButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    OCMVerify([protocolMock view:[OCMArg any] didReceivePauseTouch:[OCMArg any]]);
}

-(void) testPlayButtonCallback
{
    id protocolMock = OCMPartialMock(sut);
    
    [sut view];
    
    [sut.controlsContainerView setDelegate:protocolMock];
    [sut.controlsContainerView.playButton setSelected:NO];
    [sut.controlsContainerView.playButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    OCMVerify([protocolMock view:[OCMArg any] didReceivePlayTouch:[OCMArg any]]);
}

#pragma mark Slider control

- (void)testSliderShouldBeConnected
{
    [sut view];
    
    expect(sut.controlsContainerView.scrubber).toNot.beNil();
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
    
    [sut.controlsContainerView setDelegate:protocolMock];
    UIButton *lang = (UIButton *)[sut.controlsContainerView viewWithTag:543];  // tag added just for testing
    [lang sendActionsForControlEvents:UIControlEventTouchUpInside];
    OCMVerify([protocolMock view:[OCMArg any] didReceiveLANGButtonTouch:[OCMArg any]]);

}


#pragma mark - VOLUME

- (void)testVolumenButtonDShouldBeConnected
{
    
    id protocolMock = OCMPartialMock(sut);
    
    [sut view];
    
    [sut.controlsContainerView setDelegate:protocolMock];
    UIButton *lang = (UIButton *)[sut.controlsContainerView viewWithTag:545];  // tag added just for testing
    [lang sendActionsForControlEvents:UIControlEventTouchUpInside];
    OCMVerify([protocolMock view:[OCMArg any] didReceiveVolumenButtonTouch:[OCMArg any]]);
    
}


@end
