//
//  Created by Ivano Bilenchi on 26/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

#import <UIKit/UIKit.h>

namespace cv { class Mat; }

@interface UIImage (OCVUtils)

/// @return New UIImage from the given OpenCV matrix.
+ (UIImage *)imageFromCVMat:(cv::Mat)cvMat;

/// @return OpenCV matrix from the current image, resized.
- (cv::Mat)cvMatResized:(CGSize)size;

/// @return New image cropped to the given rect.
- (UIImage *)cropped:(CGRect)rect;

/// @return New image rotated by the given angle.
- (UIImage *)rotated:(CGFloat)angle;

@end
