//
//  DescendantOutlineData.h
//  GenerationX
//
//  Created by Nowhere Man on Thu Feb 28 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCFile.h"
#import "INDI.h"
#import "FAM.h"


@interface DescendantOutlineData : NSObject
{
  INDI* indi;
  GCFile* ged;
}

+ (DescendantOutlineData*) sharedDescendant;
- (void) setData: (INDI*) my_indi: (GCFile*) my_ged; 

@end
