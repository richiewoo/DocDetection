//
//  MaaSContourDetection.hpp
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/18/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#ifndef MaaSContourDetection_hpp
#define MaaSContourDetection_hpp

#include "MaaSImageProcessBase.hpp"

class MaaSContourDetection : public MaaSImageProcessBase
{
public:
    MaaSContourDetection();
    
    //! Gets a sample name
    std::string getName() const;
    
    //! Returns a detailed sample description
    std::string getDescription() const;
    
    //! Processes a frame and returns output image
    bool processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame);
    bool processFrame(const cv::Mat& inputFrame, std::vector< std::vector<cv::Point> >& output);
    
    //Have to call processFrame before it
    bool findRectangleFromContours(std::vector< std::vector<cv::Point> >& rectangles);
    
    std::vector< std::vector<cv::Point> > contours;
    
private:
    int m_contourNum;
    
    int m_AngleEpsilon;
};

#endif /* MaaSContourDetection_hpp */
