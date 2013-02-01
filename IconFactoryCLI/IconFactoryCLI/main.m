//
//  main.m
//  IconFactoryCLI
//
//  Created by Xu Jun on 2/1/13.
//  Copyright (c) 2013 Xu Jun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSImage+Resize.h"
#import "IcnsFactory.h"

#define AppName "icnsmaker"
#define AppVersion	"1.0.0"
#define AppBuildVer	__DATE__

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
            exit(1);
        }
        
        while( -1 != (opt = getopt(argc, argv, opt_str)) )
        {
            switch(opt)
            {
                case 'v':
                    printf(AppName": v%s, build on %s\n", AppVersion, AppBuildVer);
                    exit(0);
                    break;
                case 'h':
                    log_usage(0);
                    exit(0);
                    break;
                case 'i':
                    input = optarg;
                    break;
                case 'o':
                    output = optarg;
                    break;
                default:
                    log_usage(1);
                    exit(0);
                    break;
            }
        }
        
        NSString *srcImagePath = [NSString stringWithCString:input encoding:NSUTF8StringEncoding];
        NSString *outputPath = [NSString stringWithCString:output encoding:NSUTF8StringEncoding];
        
        if(![[NSFileManager defaultManager]fileExistsAtPath:srcImagePath])
        {
            printf("The source file not exist...");
            exit(1);
        }
        
        NSSize sizeList[] = {{512, 512}, {256, 256}, {128, 128}, {32, 32}, {16, 16}};
        NSImage *srcimage = [[[NSImage alloc]initWithContentsOfFile:srcImagePath] autorelease];
        
        if(1024 == (int)srcimage.size.width ||
           1024 == (int)srcimage.size.height)
        {
            printf("Warning: You would better give me an 1024x1024 image....\n");
        }
        
        int imageCount = sizeof(sizeList)/sizeof(NSSize);
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:imageCount];
        
        [images addObject:srcimage];
        
        for(i=0; i<imageCount; i++)
        {
            [images addObject:[srcimage resize:sizeList[i]]];
        }
        
        if([images count] == 6 ||
           [images count] == 5)
        {
            [IcnsFactory writeICNSToFile:outputPath withArrayOfImages:images];
            [[NSWorkspace sharedWorkspace]selectFile:outputPath inFileViewerRootedAtPath:nil];
        }
        else
        {
            printf("Error: Generate small images failed...\n");
            exit(1);
        }
    }
    return 0;
}

