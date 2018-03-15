//
//  Created by Ivano Bilenchi on 14/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
namespace cv { class Mat; }
#endif

@interface UIImage (OpenCV)

- (UIImage *)normalizedForFaceRecognition;

#ifdef __cplusplus
+ (UIImage *)imageFromCVMat:(cv::Mat)cvMat;

- (cv::Mat)cvMat;
- (cv::Mat)cvMatGray;
- (cv::Mat)cvMatNormalized;
#endif

@end
