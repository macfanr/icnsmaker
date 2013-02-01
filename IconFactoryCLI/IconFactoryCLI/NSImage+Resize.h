//
//  NSImage+Resize.h
//  IconFactoryCLI
//
//  Created by Xu Jun on 2/1/13.
//  Copyright (c) 2013 Xu Jun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Resize)
- (NSImage*)resize:(NSSize)destSize;
@end
