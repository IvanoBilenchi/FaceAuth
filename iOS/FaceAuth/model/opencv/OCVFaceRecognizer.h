//
//  Created by Ivano Bilenchi on 14/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OCVFaceRecognizer : NSObject

@property (nonatomic, copy, readonly) NSArray<UIImage *> *images;

- (void)addImage:(UIImage *)image;
- (BOOL)predict:(UIImage *)image;
- (void)train;
- (void)serializeModelToFileAtPath:(NSString *)path;

@end
