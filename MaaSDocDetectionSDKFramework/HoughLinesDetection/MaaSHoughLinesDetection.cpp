//
//  MaaSHoughLinesDetection.cpp
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/18/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#include "MaaSHoughLinesDetection.hpp"

ClusterLineCriteria::ClusterLineCriteria()
{
    
}

ClusterLineCriteria::ClusterLineCriteria(int type, double epsilon)
: type(type)
, epsilon(epsilon)
{
    
}

MaaSHoughLinesDetection::MaaSHoughLinesDetection()
: m_rho(5.0)
, m_theta(CV_PI / 90.0f)
, m_threshold(100)
, m_thetaEpsilon(5)
, m_rhoEpsilon(200)
, m_AngleEpsilon(10)
, m_DisEpsilon(50)
{
    registerOption("Houghline theda", "", &m_thetaEpsilon, 5, 15);
    registerOption("Houghline rho", "", &m_rhoEpsilon, 50, 500);
}

//! Gets a sample name
std::string MaaSHoughLinesDetection::getName() const
{
    return "Hough lines detection";
}

//! Returns a detailed description
std::string MaaSHoughLinesDetection::getDescription() const
{
    return "Image hough lines detection is fundamental to many image analysis applications, including image segmentation, object recognition and classiﬁcation.";
}

bool MaaSHoughLinesDetection::processFrame(const cv::Mat& inputFrame, std::vector<cv::Vec2f>& output)
{
    output.clear();
    
    cv::HoughLines(inputFrame, houghLines, m_rho, m_theta, m_threshold);
    
    if (houghLines.size() <= 0) {
        return false;
    }
    
    //disregard those lines without parallel line
    std::vector<uint> counter(houghLines.size(), 0);
    for (int i = 0; i < houghLines.size(); i++) {
        cv::Vec2f line = houghLines.at(i);
        
        for (int j = i; j < houghLines.size() - i; j++) {
            cv::Vec2f curLine = houghLines.at(j);
            
            double deltaRho = abs(line[0] - curLine[0]);
            double deltaTheta = abs((line[1] -curLine[1])/CV_PI*180);
            if ((deltaTheta < m_thetaEpsilon) && deltaRho > m_rhoEpsilon) {
                
                counter[i] += 1;
                counter[j] += 1;
            }
        }
    }
    
    for (int i = 0; i < counter.size(); i++) {
        if (counter[i] > 0) {
            output.push_back(houghLines[i]);
        }
    }
    
    return true;
}

bool MaaSHoughLinesDetection::clusterLines(const std::vector<cv::Vec2f> &lines, std::vector< std::vector<cv::Vec2f> >&clusteredLines, ClusterLineCriteria criteria, int NumOfClusters)
{
    if (lines.size() <= 0) {
        return false;
    }
    
    if (lines.size() < NumOfClusters) {
        clusteredLines.push_back(lines);
    }
    else
    {
        //cluster line
        std::vector<cv::Point2f> pts;
        for( size_t i = 0; i < lines.size(); i++ ){
            if (criteria.type == eClusterType_Theta) {
                double theta = lines.at(i)[1];
                pts.push_back(cv::Point2f( 0.0f, theta));
            }
            else{
                double rho = lines.at(i)[0];
                pts.push_back(cv::Point2f( 0.0f, rho));
            }

        }
        
        std::vector<int> labels;
        cv::kmeans(pts, NumOfClusters, labels, cv::TermCriteria(cv::TermCriteria::EPS + cv::TermCriteria::MAX_ITER, 15, criteria.epsilon), 10, cv::KMEANS_RANDOM_CENTERS);
        
        if (labels.size() > 0) {
            std::map<int, std::vector<cv::Vec2f> > segmented;
            for (int i = 0; i < lines.size(); i++) {
                cv::Vec2f line = lines.at(i);
                segmented[labels.at(i)].push_back(line);
            }
            
            for(std::map<int, std::vector<cv::Vec2f> >::iterator it = segmented.begin(); it != segmented.end(); ++it) {
                clusteredLines.push_back(it->second);
            }
        }
        else{
            clusteredLines.push_back(lines);
        }
    }
    
    return true;
}

bool MaaSHoughLinesDetection::diluteLines(const std::vector<cv::Vec2f> &lines, std::vector<cv::Vec2f> &diluteLines, int maxRho)
{
    int NumOfClusters = 4;
    if (lines.size() <= NumOfClusters) {
        return true;
    }
    
//    struct sortFunctions { // struct's as good as class
//        static bool sortLinesByRho (cv::Vec2f& first, cv::Vec2f& second) {
//            return (first[0] > second[0]);
//        }
//
//        static bool sortGroupLinesByRho (std::vector<cv::Vec2f>& first, std::vector<cv::Vec2f>& second) {
//            cv::Vec2f firstLine = first.back();
//            cv::Vec2f secondLine = second.front();
//
//            return (firstLine[0] > secondLine[0]);
//        }
//    };
    
    std::vector< std::vector<cv::Vec2f> > clusteredLines;
    if(clusterLines(lines, clusteredLines, ClusterLineCriteria(ClusterLineCriteria::eClusterType_Rho, maxRho/NumOfClusters), NumOfClusters))
    {
        if (clusteredLines.size() <= 0) {
            return false;
        }
        for (std::vector< std::vector<cv::Vec2f> >::iterator curGroupIt = clusteredLines.begin(); curGroupIt != clusteredLines.end(); curGroupIt++) {
            std::vector<cv::Vec2f> &curGroup = *curGroupIt;
            
            double rhoSum = 0.0;
            double thetaSum = 0.0;
            for (std::vector<cv::Vec2f>::iterator lineIt = curGroup.begin(); lineIt != curGroup.end(); lineIt++) {
                cv::Vec2f &line = *lineIt;
                double rho = line[0];
                double theta = line[1];
                
                rhoSum += rho;
                thetaSum += theta;
            }
            
            double averageRho = rhoSum / curGroup.size();
            double averageTheta = thetaSum / curGroup.size();
            
            diluteLines.push_back(cv::Vec2f(averageRho, averageTheta));
        }
        
        
        
//        for (std::vector< std::vector<cv::Vec2f> >::iterator curGroupIt = clusteredLines.begin(); curGroupIt != clusteredLines.end(); curGroupIt++) {
//            std::vector<cv::Vec2f> &curGroup = *curGroupIt;
//
//            //sort the lines by rho
//            std::sort(curGroup.begin(), curGroup.end(), sortFunctions::sortLinesByRho);
//        }
//        //sort the group lines by rho
//        std::sort(clusteredLines.begin(), clusteredLines.end(), sortFunctions::sortGroupLinesByRho);
        
    }
    else
    {
        return false;
    }
    
    return true;
}

bool MaaSHoughLinesDetection::perpendicularIntersectionsFromLines(std::vector< std::vector<cv::Vec2f> > &lines, std::vector< std::vector<cv::Point2f> >& intersections)
{
    if (lines.size() <= 0) {
        return false;
    }
    //Get the intersections of the lines
    for (std::vector< std::vector<cv::Vec2f> >::iterator curGroupIt = lines.begin(); curGroupIt != lines.end(); curGroupIt++) {
        std::vector<cv::Vec2f> &curGroup = *curGroupIt;
        
        for (std::vector<cv::Vec2f>::iterator curLineIt = curGroup.begin(); curLineIt != curGroup.end(); curLineIt++) {
            cv::Vec2f &lineInCurGroup = *curLineIt;
            double rho0 = lineInCurGroup[0];
            double theta0 = lineInCurGroup[1];
            double a0 = cos(theta0);
            double b0 = sin(theta0);
            
            for (std::vector< std::vector<cv::Vec2f> >::iterator nextGroupIt = curGroupIt+1; nextGroupIt != lines.end(); nextGroupIt++) {
                std::vector<cv::Vec2f> &nextGroup = *nextGroupIt;
                
                for (std::vector<cv::Vec2f>::iterator nextLineIt = nextGroup.begin(); nextLineIt != nextGroup.end(); nextLineIt++) {
                    cv::Vec2f &lineInNextGroup = *nextLineIt;
                    float rho1 = lineInNextGroup[0];
                    float theta1 = lineInNextGroup[1];
                    float a1 = cos(theta1);
                    float b1 = sin(theta1);
                    
                    float angle = abs(abs((theta0 - theta1)/CV_PI)*180 - 90);
                    if (angle < m_AngleEpsilon)
                    {
                        cv::Matx<float, 2, 2> theta= cv::Matx<float, 2, 2>(a0, b0, a1, b1);
                        cv::Matx<float, 2, 1> rho  = cv::Matx<float, 2, 1>(rho0, rho1);
                        
                        cv::Matx<float, 2, 1> result = theta.solve(rho);
                        float x = (float)result(0);
                        float y = (float)result(1);
                        
                        cv::Point2f curPoint(x, y);
                        
                        //cluster nearest points
                        bool find = false;
                        if (intersections.size() > 0) {
                            for (std::vector< std::vector<cv::Point2f> >::iterator inIt = intersections.begin(); inIt != intersections.end(); inIt++) {
                                std::vector<cv::Point2f> &pts = *inIt;
                                
                                for (int i = 0; i < pts.size(); i++) {
                                    cv::Point2f pt = pts.at(i);
                                    
                                    double dis = abs(cv::norm(curPoint - pt));
                                    if (dis < m_DisEpsilon) {
                                        find = true;
                                        pts.push_back(curPoint);
                                        break;
                                    }
                                }
                                if (true == find) {
                                    break;
                                }
                            }
                        }
                        if (false == find) {
                            std::vector<cv::Point2f> pts;
                            pts.push_back(curPoint);
                            intersections.push_back(pts);
                        }
                    }
                    else{
                        
                    }
                }
            }
        }
    }
    
    return true;
}

bool MaaSHoughLinesDetection::dilutePoint(std::vector< std::vector<cv::Point2f> >& intersections, std::vector<cv::Point2f>& centroidPts)
{
    if (intersections.size() <= 0) {
        return false;
    }
    
    for( int i = 0; i < intersections.size(); i++ ){
        std::vector<cv::Point2f>pts = intersections.at(i);
        if (pts.size() == 1) {
            centroidPts.push_back(pts.at(0));
        }
        else{
            cv::RotatedRect box = cv::minAreaRect(pts);
            centroidPts.push_back(box.center);
        }
    }
    
    return true;
}
