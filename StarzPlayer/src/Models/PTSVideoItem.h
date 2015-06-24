
typedef NS_ENUM(NSInteger, PTSContentType)
{
    PTSMovieContent,
    PTSEpisodeContent,
    PTSTrailerContent
};

@class PTABRControlParameters;
@class PSPlayFilmObject;

@interface PTSVideoItem : NSObject
{
    NSString *url;
    NSString *title;
    NSString *mediaId;
    NSString *streamType;
    NSString *description;
    NSString *drmToken;
    NSString *drmUserName;
    NSString *drmUserPassword;
    NSString *thumbnail;
    
    PTABRControlParameters * abrControl;
    PSPlayFilmObject *starzAsset;  // this will keep a reference to whatever object the app uses for configuration: Check PSPlayFilmObject
    NSTimeInterval initialPosition;
    
}

 
@property (nonatomic, readonly) NSTimeInterval initialPosition;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *mediaId;
@property (nonatomic, strong) NSString *streamType;
@property (nonatomic, strong) NSString *contentDescription;
@property (nonatomic, strong) NSString *drmToken;
@property (nonatomic, strong) NSString *drmUserName;
@property (nonatomic, strong) NSString *drmUserPassword;
@property (nonatomic, strong) NSString *thumbnail;
@property (nonatomic, strong) NSString * stripContentUrl;
@property (nonatomic, strong) PTABRControlParameters * abrControl;
@property (nonatomic, assign) PTSContentType contentType;
@property (nonatomic,strong) PSPlayFilmObject *starzAsset;


- (id)initWithDictionary:(NSDictionary *)info;

-(void) setInitialPosition:(NSTimeInterval)initialPosition;
@end
