//
//  MaaSDocDetectionUtil.hpp
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/19/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#ifndef MaaSDocDetectionUtil_hpp
#define MaaSDocDetectionUtil_hpp

#include <vector>
#include <map>

class MaaSDocDetectionUtil
{
public:
    static double angle(cv::Point& pt1, cv::Point& pt2, cv::Point& pt0);
    
    static bool sortContoursLength (std::vector<cv::Point>& first, std::vector<cv::Point>& second);
    
    static bool sortContoursArea (std::vector<cv::Point>& first, std::vector<cv::Point>& second);
    
    static void combination(size_t N, size_t K, std::vector< std::vector<int> >& combPts);
    
    static bool getLargestRectangleContour(std::vector< std::vector<cv::Point> >& rectangles, std::vector<cv::Point>& largestRec);
    
    static bool findRectangleFromPointSet(std::vector<cv::Point2f>& points, std::vector< std::vector<cv::Point> >& rects, float angleEpsilon = 6);
};

#endif /* MaaSDocDetectionUtil_hpp */
