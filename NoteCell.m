//
//  NoteCell.m
//  GenerationX
//
//  Created by Nowhere Man on Wed Jul 31 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import "NoteCell.h"

@implementation NoteCell

- (NSSize)cellSize
{
  int num_lines = [[[self stringValue] componentsSeparatedByString: @"\n"] count];
  NSSize cellSize = [super cellSize];
  cellSize.height = 20 * num_lines;
  return cellSize;
}

@end
