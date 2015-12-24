//
//  APITableViewCell.m
//  APITest
//
//  Created by Admin on 9/5/15.
//  Copyright (c) 2015 IphoneGameZone. All rights reserved.
//

#import "APITableViewCell.h"

@implementation APITableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void) bindDataWithCell : (Track *) track :(NSIndexPath *) indexPath :(UITableView*) tableView
{
    static UIImage * placeHolder;

    placeHolder = [UIImage imageNamed:@"placeholder"];
    
    self.labelArtist.text = track.trackArtist;
    self.labelDescription.text = track.trackDescription;
    self.cellImageView.image = placeHolder;
    
    NSString *imageUrl = track.trackImgURL;
    
    BOOL bNeedsToFetch = [self.cellImageView.image isEqual:placeHolder];
    
    if (bNeedsToFetch && imageUrl && ![imageUrl isEqualToString:@""])
    {
        //[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString: imageUrl] completionHandler:^(NSData * data, NSURLResponse * response, NSError * error)
        {
            if (!error && data)
            {
                UIImage *image = [UIImage imageWithData:data];
                //request succeeded, overwrite cellImage
                if (image)
                {
                    dispatch_async(dispatch_get_main_queue(),
                    ^{
                        APITableViewCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
                        if (cell)
                            cell.cellImageView.image = image;
                    });
                }
            }
            else
            {
                NSLog(@"Failed to load the image from URL: %@", imageUrl);
            }
        }];
        [task resume];
    }
}

@end
