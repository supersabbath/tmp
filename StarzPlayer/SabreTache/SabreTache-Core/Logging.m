//
//  Logging.m
//  Pods
//
//  Created by Tüz Csaba on 10/03/15.
//
//
#import <Foundation/Foundation.h>
#import "Logging.h"

#define _TLog(fmt, l) NSLogv([@"[TRACE] " stringByAppendingString:fmt], l)
#define _DLog(fmt, l) NSLogv([@"[DEBUG] " stringByAppendingString:fmt], l)
#define _ILog(fmt, l) NSLogv([@"[INFO] " stringByAppendingString:fmt], l)
#define _WLog(fmt, l) NSLogv([@"[WARN] " stringByAppendingString:fmt], l)
#define _ELog(fmt, l) NSLogv([@"[ERROR] " stringByAppendingString:fmt], l)
#define _ULog(fmt, l) NSLogv([@"[UNIQUE ******************************************************************** TRACE ] \n " stringByAppendingString:fmt], l)

extern const int AppLogLevel;

void TLog(NSString * fmt, ...)
{

   if (AppLogLevel >= 5)
   {
       va_list argptr;
       va_start(argptr,fmt);
       _TLog(fmt, argptr);
       va_end(argptr);
   }
}


void ILog(NSString * fmt, ...)
{
    if (AppLogLevel >= 3)
    {
        va_list argptr;
        va_start(argptr,fmt);
        _ILog(fmt, argptr);
        va_end(argptr);
    }
}

void ULog(NSString * fmt, ...)
{
    if (AppLogLevel == -1)
    {
        va_list argptr;
        va_start(argptr,fmt);
        _ULog(fmt, argptr);
        va_end(argptr);
    }
}
/*
    NSLog overide.. ONLY for DEBUG Mode
 */

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...)
{
    // Type to hold information about variable arguments.
    va_list ap;
    
    // Initialize a variable argument list.
    va_start (ap, format);
    
    // NSLog only adds a newline to the end of the NSLog format if
    // one is not already there.
    // Here we are utilizing this feature of NSLog()
    if (![format hasSuffix: @"\n"])
    {
        format = [format stringByAppendingString: @"\n"];
    }
    
    NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];

    NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
    // End using variable argument list.
    NSString *log =[NSString stringWithFormat:@"(%s) (%s:%d) %@",functionName, [fileName UTF8String],
                    lineNumber, body];

    NSLogv(log,ap);
    va_end (ap);

}

/*
 [ DEBUG ]
 */
void D_ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...) {

    
    if (AppLogLevel >= 4){
        va_list ap;
        va_start (ap, format);
        if (![format hasSuffix: @"\n"])
        {
            format = [format stringByAppendingString: @"\n"];
        }
        
        NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
        
        NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
        // End using variable argument list.
        NSString *log =[NSString stringWithFormat:@"(%s) (%s:%d) %@",functionName, [fileName UTF8String],
                        lineNumber, body];
        
        _DLog(log,ap);
        va_end (ap);
    }
}

/*
 [ WARNING ]
 */
void W_ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...) {
    
    
    if (AppLogLevel >= 2){
        
        va_list ap;
        va_start (ap, format);
        if (![format hasSuffix: @"\n"])
        {
            format = [format stringByAppendingString: @"\n"];
        }
        
        NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
        
        NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
        // End using variable argument list.
        NSString *log =[NSString stringWithFormat:@"(%s) (%s:%d) %@",functionName, [fileName UTF8String],
                        lineNumber, body ];
        
        _WLog(log,ap);
        
        
        va_end (ap);
    }
}

/*
 [ ERROR ]
 */
void E_ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...) {
    
    
    if (AppLogLevel >= 1){
        
        va_list ap;
        va_start (ap, format);
        if (![format hasSuffix: @"\n"])
        {
            format = [format stringByAppendingString: @"\n"];
        }
        
        NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
        
        NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
        // End using variable argument list.
        NSString *log =[NSString stringWithFormat:@"(%s) (%s:%d) %@",functionName, [fileName UTF8String],
                        lineNumber, body ];
        
        _ELog(log,ap);
        
    
        va_end (ap);
    }
}




