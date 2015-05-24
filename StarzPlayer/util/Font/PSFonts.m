//
//  FNFonts.m
//  Filmnet
//
//  Created by Csaba Tűz on 2014.03.05..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import "PSFonts.h"

const CGFloat PSFontXXXS = 10;
const CGFloat PSFontXXS  = 12;
const CGFloat PSFontXS   = 14;
const CGFloat PSFontS    = 16;
const CGFloat PSFontM    = 18;
const CGFloat PSFontL    = 24;
const CGFloat PSFontXL   = 28;
const CGFloat PSFontXXL  = 32;

NSString * const PSFontPDR = @"PlayfairDisplay-Regular";
NSString * const PSFontPDB = @"PlayfairDisplay-Bold";
NSString * const PSFontPDI = @"PlayfairDisplay-Italic";

NSString * const PSFontPNR = @"ProximaNova-Regular";
NSString * const PSFontPNB = @"ProximaNova-Bold";

FONT_ID_DECLARE(PSFontPDRXXXS);
FONT_ID_DECLARE(PSFontPDRXXS);
FONT_ID_DECLARE(PSFontPDRXS);
FONT_ID_DECLARE(PSFontPDRS);
FONT_ID_DECLARE(PSFontPDRM);
FONT_ID_DECLARE(PSFontPDRL);
FONT_ID_DECLARE(PSFontPDRXL);
FONT_ID_DECLARE(PSFontPDRXXL);

FONT_ID_DECLARE(PSFontPDBXXXS);
FONT_ID_DECLARE(PSFontPDBXXS);
FONT_ID_DECLARE(PSFontPDBXS);
FONT_ID_DECLARE(PSFontPDBS);
FONT_ID_DECLARE(PSFontPDBM);
FONT_ID_DECLARE(PSFontPDBL);
FONT_ID_DECLARE(PSFontPDBXL);
FONT_ID_DECLARE(PSFontPDBXXL);

FONT_ID_DECLARE(PSFontPDIXXXS);
FONT_ID_DECLARE(PSFontPDIXXS);
FONT_ID_DECLARE(PSFontPDIXS);
FONT_ID_DECLARE(PSFontPDIS);
FONT_ID_DECLARE(PSFontPDIM);
FONT_ID_DECLARE(PSFontPDIL);
FONT_ID_DECLARE(PSFontPDIXL);
FONT_ID_DECLARE(PSFontPDIXXL);

FONT_ID_DECLARE(PSFontPNRXXXS);
FONT_ID_DECLARE(PSFontPNRXXS);
FONT_ID_DECLARE(PSFontPNRXS);
FONT_ID_DECLARE(PSFontPNRS);
FONT_ID_DECLARE(PSFontPNRM);
FONT_ID_DECLARE(PSFontPNRL);
FONT_ID_DECLARE(PSFontPNRXL);
FONT_ID_DECLARE(PSFontPNRXXL);

FONT_ID_DECLARE(PSFontPNBXXXS);
FONT_ID_DECLARE(PSFontPNBXXS);
FONT_ID_DECLARE(PSFontPNBXS);
FONT_ID_DECLARE(PSFontPNBS);
FONT_ID_DECLARE(PSFontPNBM);
FONT_ID_DECLARE(PSFontPNBL);
FONT_ID_DECLARE(PSFontPNBXL);
FONT_ID_DECLARE(PSFontPNBXXL);

@implementation PSFonts

+ (void)initialize
{
    NSArray * fontNames = @[PSFontPDR, PSFontPDB, PSFontPDI, PSFontPNR, PSFontPNB];
    CGFloat fontSizes[] = {PSFontXXXS, PSFontXXS, PSFontXS, PSFontS, PSFontM, PSFontL, PSFontXL, PSFontXXL};
    
    NSArray * fontKeys = @[
        PSFontPDRXXXS, PSFontPDRXXS, PSFontPDRXS, PSFontPDRS, PSFontPDRM, PSFontPDRL, PSFontPDRXL, PSFontPDRXXL,
        PSFontPDBXXXS, PSFontPDBXXS, PSFontPDBXS, PSFontPDBS, PSFontPDBM, PSFontPDBL, PSFontPDBXL, PSFontPDBXXL,
        PSFontPDIXXXS, PSFontPDIXXS, PSFontPDIXS, PSFontPDIS, PSFontPDIM, PSFontPDIL, PSFontPDIXL, PSFontPDIXXL,
        PSFontPNRXXXS, PSFontPNRXXS, PSFontPNRXS, PSFontPNRS, PSFontPNRM, PSFontPNRL, PSFontPNRXL, PSFontPNRXXL,
        PSFontPNBXXXS, PSFontPNBXXS, PSFontPNBXS, PSFontPNBS, PSFontPNBM, PSFontPNBL, PSFontPNBXL, PSFontPNBXXL
    ];
    
    int k = 5;
    int l = 8;
    int m = 0;
    
    for (int i = 0; i < k; ++i)
    {
        for (int j = 0; j < l; ++j, ++m)
        {
            NSString * fontName = fontNames[i];
            CGFloat size = fontSizes[j];
            NSString * key = fontKeys[m];
            
            [FontUtil registerFont:[UIFont fontWithName:fontName size:size] forKey:key];
        }
    }
    
}

@end
