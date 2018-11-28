//
//  MaaSDocDetectionUtil.cpp
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/19/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#include "MaaSDocDetectionUtil.hpp"

double MaaSDocDetectionUtil::angle(cv::Point& pt1, cv::Point& pt2, cv::Point& pt0) {
    
    double a = abs(cv::norm(pt1 - pt0));
    double b = abs(cv::norm(pt2 - pt0));
    double c = abs(cv::norm(pt2 - pt1));
    
    double cosine = ((a * a) + (b * b) - (c * c))/(2 * a * b);
    double angle = acos(cosine) / CV_PI * 180;
    
    return angle;
}

bool MaaSDocDetectionUtil::sortContoursLength (std::vector<cv::Point>& first, std::vector<cv::Point>& second) {
    return (cv::arcLength(first, true) > cv::arcLength(second, true));
    
}

bool MaaSDocDetectionUtil::sortContoursArea (std::vector<cv::Point>& first, std::vector<cv::Point>& second) {
    return (cv::contourArea(first) > cv::contourArea(second));
    
}

void MaaSDocDetectionUtil::combination(size_t N, size_t K, std::vector< std::vector<int> >& combPts)
{
    std::string bitmask(K, 1); // K leading 1's
    bitmask.resize(N, 0); // N-K trailing 0's
    
    // print integers and permute bitmask
    do {
        std::vector<int> rect;
        for (int i = 0; i < N; ++i) // [0..N-1] integers
        {
            if (bitmask[i])
            {
                rect.push_back(i);
            }
        }
        combPts.push_back(rect);
        
    } while (std::prev_permutation(bitmask.begin(), bitmask.end()));
}

bool MaaSDocDetectionUtil::getLargestRectangleContour(std::vector< std::vector<cv::Point> >& rectangles, std::vector<cv::Point>& largestRec)
{
    if (rectangles.size() <= 0) {
        return false;
    }
    
    std::sort(rectangles.begin(), rectangles.end(), sortContoursArea);
    
    std::vector<cv::Point> pts = rectangles.at(0);
    for (int i = 0; i < pts.size(); i++) {
        largestRec.push_back(pts.at(i));
    }
    
    return true;
}

bool MaaSDocDetectionUtil::findRectangleFromPointSet(std::vector<cv::Point2f>& points, std::vector< std::vector<cv::Point> >& rects, float angleEpsilon)
{
    std::vector<std::vector<int> > combPts;
    combination(points.size(), 4, combPts);
    
    for( int i = 0; i < combPts.size(); i++ ){
        std::vector<int> indices = combPts.at(i);
        std::vector<cv::Point2f> singleRect;
        for( int j = 0; j < indices.size(); j++ ){
            singleRect.push_back(points.at(indices.at(j)));
        }
        
        std::vector<cv::Point2f> rectPtsf;
        cv::convexHull(singleRect, rectPtsf);
        
        double maxCosine = 180;
        
        for (int j = 0; j < 4; j++){
            cv::Point pt1 = rectPtsf[j];
            cv::Point pt2 = rectPtsf[(j+2)%4];
            cv::Point pt0 = rectPtsf[(j+1)%4];
            double cosine = fabs(angle(pt1, pt2, pt0));
            maxCosine = MIN(maxCosine, cosine);
        }
        
        if (abs(maxCosine - 90) < angleEpsilon)
        {
            
            std::vector<cv::Point> rectPts;
            for (std::vector<cv::Point2f>::iterator it = rectPtsf.begin(); it != rectPtsf.end(); it++) {
                rectPts.push_back(cv::Point((int)(*it).x, (int)(*it).y));
            }
            rects.push_back(rectPts);
        }
        
        
    }
    
    std::sort(rects.begin(), rects.end(), sortContoursArea);
    
    return true;
}
