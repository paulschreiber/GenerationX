//
//  GCField.h
//  GenerationX
//
//  Created by Nowhere Man on Tue Feb 19 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface GCField : NSObject
{
  NSInteger level;
  NSString* type;
  NSString* value;
  BOOL need_save;
  
  int num_subfields;
  NSMutableArray* subfields;
}
- (id)init: (NSInteger) my_level : (NSString*) my_type : (NSString*) my_value;
- (NSString*) fieldValue;
- (NSString*) fieldType;
- (NSString*) textValue;
- (BOOL) needSave;
- (void) setFieldType: (NSString*) my_type;
- (void) setFieldValue: (NSString*) my_value;
- (void) setNeedSave: (BOOL) b;
- (NSInteger) fieldLevel;
- (NSUInteger) numSubfields;
- (NSInteger) numEvents;
- (GCField*) subfieldAtIndex: (NSInteger) index;
- (GCField*) eventAtIndex: (NSInteger) index;
- (GCField*) subfieldWithType: (NSString*) my_type;
- (GCField*) subfieldWithType: (NSString*) t value: (NSString*) v;
- (NSMutableArray*) subfieldsWithType: (NSString*) my_type;
- (NSMutableArray*) valuesOfSubfieldsWithType: (NSString*) my_type;
- (NSString*) valueOfSubfieldWithType: (NSString*) my_type;
- (GCField*) lastField;
- (GCField*) addSubfield: (NSString*) my_type : (NSString*) my_value;
- (NSString*) dataForFile;
- (void) removeSubfield: (GCField*) my_field;
- (void) removeSubfieldWithType: (NSString*) my_type Value: (NSString*) my_value;
- (BOOL) isIdentical: (GCField*)my_field;
- (BOOL) isEvent;
- (void) sortEvents;
- (NSComparisonResult) eventCompare: (GCField*) my_field;
- (NSComparisonResult) compareAuthor: (GCField*) f;
- (NSComparisonResult) compareAuthorReverse: (GCField*) f;
- (NSComparisonResult) compareTitle: (GCField*) f;
- (NSComparisonResult) compareTitleReverse: (GCField*) f;

@end
