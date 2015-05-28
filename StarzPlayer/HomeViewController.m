//
//  HomeViewController.m
//  StarzPlayer
//
//  Created by Fernando Canon on 18/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "HomeViewController.h"
#import "SPPlayerViewController.h"
#import "PTSVideoItem.h"
#import <Gigya-iOS-SDK/Gigya.h>

typedef void (^Completion)(PTSVideoItem*);

@interface HomeViewController () <SPPlayerViewControllerDelegate,SPPlayerViewControllerViewDataSource>

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)presentVideo:(id)sender
{
    [self reloadWithURL:@"http://adunit.cdn.auditude.com/player/downloads/data/psdk-ios/data/content.plist" withCompletion:^(PTSVideoItem *video) {
        
        SPPlayerViewController* playerController = [[SPPlayerViewController alloc]initWithNibName:@"SPPlayerViewController" bundle:nil];
        
        [playerController setDataSource:self];
        [self presentViewController:playerController animated:YES completion:^{
            NSLog(@"Presented");
            
            [playerController playVideo:video];
        }];
    }];
 
}



//http://adunit.cdn.auditude.com/player/downloads/data/psdk-ios/data/content.plist
- (void ) reloadWithURL:(NSString*)surl withCompletion:(Completion) block
{
 
    
    dispatch_queue_t thread = dispatch_queue_create("LoadDictionary", NULL);
    dispatch_async(thread, ^{
        
        NSURLRequest* redirectRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:surl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        NSURLResponse* redirectResponse=nil;
        
        NSError* error=nil;
        
        
        
        NSData* data = [NSURLConnection sendSynchronousRequest:redirectRequest returningResponse:&redirectResponse error:&error];
        
        
        if (!error && data != nil)
        {
            
            NSString *errorDesc = nil;
            NSPropertyListFormat format;
            NSArray * array = (NSArray*)[NSPropertyListSerialization
                                         propertyListFromData:data
                                         mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                         format:&format
                                         errorDescription:&errorDesc];
            
            
            PTSVideoItem *item = [[PTSVideoItem alloc] initWithDictionary:array.firstObject];
        
            dispatch_async(dispatch_get_main_queue(), ^{
                   block(item);
            });
        }
        
    });
}



-(void) loginWithGigya
{
    NSString *sessionPath = [[NSBundle mainBundle] pathForResource:@"SessionData" ofType:@"plist"];
    
    NSDictionary *sessionData = [NSDictionary dictionaryWithContentsOfFile:sessionPath];
    
   // [Gigya initWithAPIKey:[] APIDomain:@"" ];

}

#pragma mark -
#pragma mark delegates and data source

-(UIView*) playerViewController:(SPPlayerViewController *)playerVC viewForEpisodeSelectorForVideoItem:(PTSVideoItem *)item {
    UIView *v =[[UIView alloc] init];
    [v setBackgroundColor:[UIColor blueColor]];
    return v;
}

-(UIView*) playerViewController:(SPPlayerViewController *)playerVC viewToDisplayAfterVideoPlayback:(PTSVideoItem *)item {

    UIView *v =[[UIView alloc] init];
    [v setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:1]];
    return v;
}



@end
