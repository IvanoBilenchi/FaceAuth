//
//  Created by Ivano Bilenchi on 14/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

#import <UIKit/UIKit.h>

namespace cv { class Mat; }

@interface UIImage (OpenCV)

+ (UIImage *)imageFromCVMat:(cv::Mat)cvMat;
- (cv::Mat)faceRecCVMatWithBoundingBox:(CGRect)boundingBox faceAngle:(CGFloat)faceAngle eyeDistance:(CGFloat)eyeDistance;

@end
