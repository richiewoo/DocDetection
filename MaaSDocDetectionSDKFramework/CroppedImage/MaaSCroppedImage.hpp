//
//  MaaSCroppedImage.hpp
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 10/2/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#ifndef MaaSCroppedImage_hpp
#define MaaSCroppedImage_hpp

#include "MaaSImageProcessBase.hpp"

class MaaSCroppedImage : public MaaSImageProcessBase
{
public:
    MaaSCroppedImage();
    
    //! Gets a sample name
    std::string getName() const;
    
    //! Returns a detailed sample description
    std::string getDescription() const;
    
    //! Processes a frame and returns output image
    bool processFrame(const cv::Mat& inputFrame, const std::vector<cv::Point>pts, cv::Mat& outputFrame);
};

#endif /* MaaSCroppedImage_hpp */
