//
//  GenXUtil.m
//  GenerationX
//
//  Created by Nowhere Man on Tue Jun 11 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import "GenXUtil.h"


@implementation GenXUtil

+ (GenXUtil*) sharedUtil
{
  static GenXUtil* shared_util = nil;
  
  if( ! shared_util )
    shared_util = [[GenXUtil alloc] init];
    
  return shared_util;
}

// load the nib
- (GenXUtil*) init
{
  eventDict = [[NSMutableDictionary alloc] init];
  
  // INDI Events
  [eventDict setObject: @"Birth" forKey: @"BIRT"];
  [eventDict setObject: @"Death" forKey: @"DEAT"];
  [eventDict setObject: @"Burial" forKey: @"BURI"];
  [eventDict setObject: @"Cremation" forKey: @"CREM"];
  [eventDict setObject: @"Baptism" forKey: @"BAPM"];
  [eventDict setObject: @"Bar Mitzvah" forKey: @"BARM"];
  [eventDict setObject: @"Bas Mitzvah" forKey: @"BASM"];
  [eventDict setObject: @"Blessing" forKey: @"BLES"];
  [eventDict setObject: @"Adult Christening" forKey: @"CHRA"];
  [eventDict setObject: @"Confirmation" forKey: @"CONF"];
  [eventDict setObject: @"First Communion" forKey: @"FCOM"];
  [eventDict setObject: @"Ordination" forKey: @"ORDN"];
  [eventDict setObject: @"Naturalization" forKey: @"NATU"];
  [eventDict setObject: @"Emigration" forKey: @"EMIG"];
  [eventDict setObject: @"Immigration" forKey: @"IMMI"];
  [eventDict setObject: @"Census" forKey: @"CENS"];
  [eventDict setObject: @"Probate" forKey: @"PROB"];
  [eventDict setObject: @"Will" forKey: @"WILL"];
  [eventDict setObject: @"Graduation" forKey: @"GRAD"];
  [eventDict setObject: @"Retirement" forKey: @"RETI"];
  [eventDict setObject: @"Generic Event" forKey: @"EVEN"];
  [eventDict setObject: @"Christening" forKey: @"CHR"];
  [eventDict setObject: @"Adoption" forKey: @"ADOP"];
  [eventDict setObject: @"Marriage" forKey: @"MARR"];
  [eventDict setObject: @"Marriage" forKey: @"FAMS"];
  
  //FAM Events
  [eventDict setObject: @"Engagement" forKey: @"ENGA"];
  [eventDict setObject: @"Divorce" forKey: @"DIV"];
  [eventDict setObject: @"Annulment" forKey: @"ANUL"];
  [eventDict setObject: @"Marriage Bann" forKey: @"MARB"];
  [eventDict setObject: @"Marriage Settlement" forKey: @"MARS"];
  [eventDict setObject: @"Marriage Contract" forKey: @"MARC"];
  [eventDict setObject: @"Marriage License" forKey: @"MARL"];
  [eventDict setObject: @"Divorce Filing" forKey: @"DIVF"];
  
  return self;
}

- (NSString*) eventStringFromGEDCOM: (NSString*) my_gedcom
{
  return [eventDict objectForKey: my_gedcom];
}

@end
