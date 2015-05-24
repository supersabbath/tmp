#import "FileUtils.h"

@implementation FileUtils
+ (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+(NSString *) pathToFileInDocumentsDirectoryWithName: (NSString *) fileName
{
    return [ FileUtils pathToFileInDocumentsDirectoryWithName: fileName inFolder: nil ];
}

+(NSString *) pathToFileInDocumentsDirectoryWithName: (NSString *) fileName inFolder: (NSString*) folder
{
    NSString *documentsPath = [ FileUtils applicationDocumentsDirectory ];
    
    if( folder )
    {
        documentsPath = [ documentsPath stringByAppendingFormat:@"/%@/", folder ];
    }
    
    NSString *returnValue = nil;
    
    if( documentsPath )
    {
        returnValue = [ documentsPath stringByAppendingString: fileName ];
    }
    
    return returnValue;
    
}

+(NSString *) pathToFolderInDocumentsDirectoryWithName: (NSString *) folderName
{
    NSString *documentsPath = [ FileUtils applicationDocumentsDirectory ];
    
    return  [ documentsPath stringByAppendingFormat:@"/%@", folderName ];
}
@end
