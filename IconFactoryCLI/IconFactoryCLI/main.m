//
//  main.m
//  IconFactoryCLI
//
//  Created by Xu Jun on 2/1/13.
//  Copyright (c) 2013 Xu Jun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSImage+Ext.h"
#import "IcnsFactory.h"

#define AppName "icnsmaker"
#define AppVersion	"1.0.0"
#define AppBuildVer	__DATE__

#define iconutil_cmdtool_base 1

static void log_usage(int ill)
{
	if(ill)
	{
		printf(AppName": illegal option...\n");
	}
	printf("usage: "AppName" -i [image@1024x1024.png] -o [icon.icns]\n");
}

int main(int argc, char * argv[])
{
    @autoreleasepool
    {
        const char *opt_str = "vhi:o:";
        const char *input = NULL, *output = NULL;
        int i=0, opt = 0;
        
        if(argc == 1)
        {
            log_usage(0);
            exit(EXIT_FAILURE);
        }
        
        while( -1 != (opt = getopt(argc, argv, opt_str)) )
        {
            switch(opt)
            {
                case 'v':
                    printf(AppName": v%s, build on %s\n", AppVersion, AppBuildVer);
                    exit(EXIT_SUCCESS);
                    break;
                case 'h':
                    log_usage(0);
                    exit(EXIT_SUCCESS);
                    break;
                case 'i':
                    input = optarg;
                    break;
                case 'o':
                    output = optarg;
                    break;
                default:
                    log_usage(1);
                    exit(EXIT_SUCCESS);
                    break;
            }
        }
        
        NSString *srcImagePath = [NSString stringWithCString:input encoding:NSUTF8StringEncoding];
        NSString *outputPath = [NSString stringWithCString:output encoding:NSUTF8StringEncoding];
        
        if(![[NSFileManager defaultManager]fileExistsAtPath:srcImagePath])
        {
            fprintf(stderr, "%s","The source file not exist...");
            exit(EXIT_FAILURE);
        }
        
        NSSize sizeList[] = {{512, 512}, {256, 256}, {128, 128}, {32, 32}, {16, 16}};
        NSImage *srcimage = [[[NSImage alloc]initWithContentsOfURL:[NSURL fileURLWithPath:srcImagePath]] autorelease];
        
        srcimage = [srcimage resize:NSMakeSize(1024, 1024)];
        
        if(1024 != (int)srcimage.size.width ||
           1024 != (int)srcimage.size.height)
        {
            fprintf(stderr, "%s", "Warning: You would better give me an 1024x1024 image....\n");
        }
        
        int imageCount = sizeof(sizeList)/sizeof(NSSize);
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:imageCount];
        
        [images addObject:srcimage];
        
        for(i=0; i<imageCount; i++)
        {
            [images addObject:[srcimage resize:sizeList[i]]];
        }
        
        if([images count] == 6)
        {
#ifndef iconutil_cmdtool_base
            [IcnsFactory writeICNSToFile:outputPath withArrayOfImages:images];
#else
#define FileNamePrefix  @"icon_"
#define FileNameSuffix  @".png"
            NSArray *fileName = @[FileNamePrefix@"512x512@2x"FileNameSuffix, FileNamePrefix@"512x512"FileNameSuffix,
                                FileNamePrefix@"256x256@2x"FileNameSuffix, FileNamePrefix@"256x256"FileNameSuffix,
                                FileNamePrefix@"128x128@2x"FileNameSuffix, FileNamePrefix@"128x128"FileNameSuffix,
                                FileNamePrefix@"32x32@2x"FileNameSuffix, FileNamePrefix@"32x32"FileNameSuffix,
                                FileNamePrefix@"16x16@2x"FileNameSuffix, FileNamePrefix@"16x16"FileNameSuffix];
            NSInteger fileNameIndex = 0;
            NSInteger imageIndex = 0;
            NSString *iconsetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"icon.iconset"];
            NSError *error = nil;
            
            if([[NSFileManager defaultManager]fileExistsAtPath:iconsetPath]) {
                [[NSFileManager defaultManager]removeItemAtPath:iconsetPath error:nil];
            }
            
            if(![[NSFileManager defaultManager]createDirectoryAtPath:iconsetPath
                                         withIntermediateDirectories:YES
                                                          attributes:nil
                                                               error:&error]) {
                fprintf(stderr, "Error: %s", [[error description]UTF8String]);
                exit(EXIT_FAILURE);
            }
            
            for(NSImage *image in images) {
                NSString *pathname = nil;
                
                if(imageIndex == 0 || imageIndex == ([images count] - 1)) {
                    pathname = [iconsetPath stringByAppendingPathComponent:[fileName objectAtIndex:fileNameIndex++]];
                    [image.PNGRepresentation writeToFile:pathname atomically:YES];
                }
                else {
                    pathname = [iconsetPath stringByAppendingPathComponent:[fileName objectAtIndex:fileNameIndex++]];
                    [image.PNGRepresentation writeToFile:pathname atomically:YES];
                    
                    if(((int)(image.size.width)) == 128 ) {
                        image = [image resize:NSMakeSize(64, 64)];
                    }
                    pathname = [iconsetPath stringByAppendingPathComponent:[fileName objectAtIndex:fileNameIndex++]];
                    [image.PNGRepresentation writeToFile:pathname atomically:YES];
                }
                
                imageIndex += 1;
            }
            
            NSString *launchPath = @"/usr/bin/iconutil";
            NSArray *arguments = @[@"-c", @"icns", @"-o", outputPath, iconsetPath];
            if([[NSFileManager defaultManager]fileExistsAtPath:launchPath]) {
                NSTask *task = [NSTask launchedTaskWithLaunchPath:launchPath arguments:arguments];
                [task waitUntilExit];
                if([[NSFileManager defaultManager]fileExistsAtPath:iconsetPath]) {
                    [[NSFileManager defaultManager]removeItemAtPath:iconsetPath error:nil];
                }
                
            }
            else {
                fprintf(stderr, "%s", "Error: Can not find iconutil");
                exit(EXIT_FAILURE);
            }
#endif
            [[NSWorkspace sharedWorkspace]selectFile:outputPath inFileViewerRootedAtPath:nil];
        }
        else
        {
            fprintf(stderr, "%s", "Error: Generate small images failed...");
            exit(EXIT_FAILURE);
        }
    }
    return 0;
}

