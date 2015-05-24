//
//  Logging.h
//  Appcelerator
//
//  Created by Tüz Csaba on 14/02/15.
//  Copyright (c) 2015 Accedo Broadband AB. All rights reserved.
//
#import <Foundation/Foundation.h>
#ifdef DEBUG

#define NSLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#define DLog(args...) D_ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#define ELog(args...) E_ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#define WLog(args...) W_ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
#define NSLog(x...)
#define DLog(args...) D_ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#define ELog(args...) E_ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#define WLog(args...) W_ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#endif 


extern void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);

extern void TLog(NSString * fmt, ...);
//extern void DLog(NSString * fmt, ...);
extern void ILog(NSString * fmt, ...);
//extern void WLog(NSString * fmt, ...);
//extern void ELog(NSString * fmt, ...);
extern void ULog(NSString * fmt, ...);


void D_ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);
void W_ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);
void E_ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);
