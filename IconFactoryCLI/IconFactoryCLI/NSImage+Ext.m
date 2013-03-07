//
//  NSImage+Resize.m
//  IconFactoryCLI
//
//  Created by Xu Jun on 2/1/13.
//  Copyright (c) 2013 Xu Jun. All rights reserved.
//

#import "NSImage+Ext.h"

@implementation NSImage (Resize)

- (NSImage*)resize:(NSSize)destSize
{
    NSAssert([[self representations] count], @"Bad Input Image...");

    NSImage *newImage = [[[NSImage alloc]initWithSize:destSize] autorelease];
    [newImage lockFocus];
    [self drawInRect:NSMakeRect(0, 0, destSize.width, destSize.height)
            fromRect:NSMakeRect(0, 0, self.size.width, self.size.height)
           operation:NSCompositeSourceOver fraction:1.0];
    [newImage unlockFocus];
    
    return newImage;
}

- (NSData*)PNGRepresentation
{
    NSBitmapImageRep *bitmap = [[[NSBitmapImageRep alloc] initWithData:[self TIFFRepresentation]] autorelease];
    
    return [bitmap representationUsingType:NSPNGFileType properties:nil];
}

@end
