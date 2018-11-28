//
//  MaaSContourDetection.cpp
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/18/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#include "MaaSContourDetection.hpp"
#include "MaaSDocDetectionUtil.hpp"
#include "MaaSDocDetectionUtil.hpp"

MaaSContourDetection::MaaSContourDetection()
: m_contourNum(5)
, m_AngleEpsilon(10)
{
   registerOption("Contour number", "", &m_contourNum, 1, 20);
}

//! Gets a sample name
std::string MaaSContourDetection::getName() const
{
    return "Contour detection";
}

//! Returns a detailed description
std::string MaaSContourDetection::getDescription() const
{
    return "Image contour detection is fundamental to many image analysis applications, including image segmentation, object recognition and classiﬁcation.";
}

bool MaaSContourDetection::processFrame(const cv::Mat& inputFrame, cv::Mat& output)
{
    //Get the contours based on detected edges
    contours.clear();
    cv::findContours(inputFrame, contours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
    
    if (contours.size() <= 0) {
        return false;
    }
    
    inputFrame.copyTo(output);
    
    cv::drawContours(output, contours, -1, cv::Scalar(255,255,255), 3);
    
    return true;
}

bool MaaSContourDetection::processFrame(const cv::Mat& inputFrame, std::vector< std::vector<cv::Point> >& output)
{
    //Get the contours based on detected edges
    contours.clear();
    cv::findContours(inputFrame, contours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
    
    if (contours.size() <= 0) {
        return false;
    }
    
    //get the m_contourNum longest contours
    std::sort(contours.begin(), contours.end(), MaaSDocDetectionUtil::sortContoursLength);
    
    for (int i=0; i < MIN(contours.size(), m_contourNum); i++)
        output.push_back(contours[i]);
    
    return true;
}

bool MaaSContourDetection::findRectangleFromContours(std::vector< std::vector<cv::Point> >& rectangles)
{
    if (contours.size() <= 0) {
        return false;
    }
    
    std::vector<cv::Point> approx;
    for (size_t i = 0; i < contours.size(); i++)
    {
        // approximate contour with accuracy proportional to the contour perimeter
        cv::approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
        
        if (approx.size() == 4){
            
            double maxCosine = 180;
            
            for (int j = 0; j < 4; j++){
                double cosine = fabs(MaaSDocDetectionUtil::angle(approx[j], approx[(j+2)%4], approx[(j+1)%4]));
                maxCosine = MIN(maxCosine, cosine);
            }
            
            if (abs((maxCosine - 90)) < m_contourNum)
                rectangles.push_back(approx);
        }
    }
    
    return true;
}

