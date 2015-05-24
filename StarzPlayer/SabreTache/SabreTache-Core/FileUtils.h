#import <Foundation/Foundation.h>
/**
 *  Utility class that declares convenience methods to wrtie and read files to and from disk
 */
@interface FileUtils : NSObject
/**
 *  Get the path to the application documents directory
 *
 *  @return the path tot he documents directory
 */
+(NSString *) applicationDocumentsDirectory;
/**
 *  Get the path to a particular file in the documents directory
 *
 *  @param fileName the name of the file
 *
 *  @return a path containing the filename
 */
+(NSString *) pathToFileInDocumentsDirectoryWithName: (NSString *) fileName;
/**
 *  Get the path to a particular file in a subfolder of the documents directory
 *
 *  @param fileName the name of the file
 *  @param folder   the name of the subfolder
 *
 *  @return the full path to the file, including filename
 */
+(NSString *) pathToFileInDocumentsDirectoryWithName: (NSString *) fileName inFolder: (NSString*) folder;
/**
 *  Gt the path to a folder in the documets directory
 *
 *  @param folderName the name of the folder
 *
 *  @return the full path to the folderVEE
 */
+(NSString *) pathToFolderInDocumentsDirectoryWithName: (NSString *) folderName;
@end
