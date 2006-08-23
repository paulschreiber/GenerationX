//
//  GEDParser.h
//  GenXDoc
//
//  Created by Nowhere Man on Fri Feb 06 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCFile.h"

#define kParsingHeader			1

@interface GEDParser : NSObject
{
  int state;
  GCFile* g;
	GCField* currentRecord;
}

@end
