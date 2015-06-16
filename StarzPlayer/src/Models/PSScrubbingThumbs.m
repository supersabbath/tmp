//
//  PSScrubbingThumbs.m
//  StarzPlayer
//
//  Created by Fernando Canon on 21/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "PSScrubbingThumbs.h"

@implementation PSScrubbingThumbs


-(void) fetchThumbsWithCompletion:(PSScrubbingCompletion) callback {
    
    if (! self.url) {
        NSLog(@"NO URL HAS BEEN SET FOR SCRUBBING THUMBNAILS");
        callback (NO);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
        
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
        
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad; // this will make sure the request always returns the cached image
        request.HTTPShouldHandleCookies = NO;
        request.HTTPShouldUsePipelining = YES;
        
        NSURLResponse *response = nil;
        NSError *connectionError = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
        
        if (connectionError || !data || ((NSHTTPURLResponse*)response).statusCode >= 400) {
            callback (NO);
            return ;
        }
        
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
        self.height = [[parsedObject objectForKey:@"height"] intValue];
        self.width = [[parsedObject objectForKey:@"width"] intValue];
        self.startTime = [[parsedObject objectForKey:@"startTime"] intValue];
        self.endTime = [[parsedObject objectForKey:@"endTime"] intValue];
        self.imageCount = [[parsedObject objectForKey:@"imageCount"] intValue];
        
        NSMutableArray *tmp = [@[] mutableCopy];
        NSArray *thumbs  = [parsedObject objectForKey:@"thumbnails"];
        
        [thumbs enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
            
          
            if (idx %4 ==0 ) {
                PSScrubbingThumbModel *model = [PSScrubbingThumbModel new];
                model.data = obj;
                [tmp addObject:model];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.thumbnails = [tmp copy];
            callback(YES);
        });
        
    }); // end dispatchAsych
}




@end

@interface PSScrubbingThumbModel()
{
    UIImage * _image;
}

@end

@implementation PSScrubbingThumbModel

- (void)dealloc
{
    _image = nil;
}


- (UIImage *)image
{
    if (_image == nil)
    {
        @synchronized(self)
        {
            if (_image == nil)
            {
                NSArray * parts = [self.data componentsSeparatedByString:@","];
                NSString * base64 = parts[1];
                
                NSData * imageData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
                
                _image = [UIImage imageWithData:imageData];
            }
        }
    }
    return _image;
}

@end