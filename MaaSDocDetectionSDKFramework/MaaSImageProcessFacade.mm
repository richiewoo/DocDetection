//
//  MaaSImageProcessFacade.m
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/18/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#import "MaaSImageProcessFacade.h"
#import "UIImage+OpenCV.h"
#import "UIImage+Utils.h"
#import "MaaSEdgeDetection.hpp"
#import "MaaSContourDetection.hpp"
#import "MaaSHoughLinesDetection.hpp"
#import "MaaSDocDetectionUtil.hpp"
#import "MaaSCroppedImage.hpp"

#define minimumDetectedImgSize(img) (img.rows * img.cols * 0.1)

@interface MaaSImageProcessFacade()
{
    NSString * m_title;
    NSString * m_description;
    
    MaaSEdgeDetection* _edgeDetection;
    MaaSContourDetection* _contourDetection;
    MaaSHoughLinesDetection* _houghLinesDetection;
    MaaSCroppedImage* _cropImage;
    
    cv::Mat _detectedFrame;
    std::vector<cv::Point> _docCorners;
    UIImageOrientation _imageOrientation;
}

@end

@implementation MaaSImageProcessFacade

-(instancetype)init
{
    if (self = [super init]) {
        _edgeDetection = new MaaSEdgeDetection();
        _contourDetection = new MaaSContourDetection();
        _houghLinesDetection = new MaaSHoughLinesDetection();
        _cropImage = new MaaSCroppedImage();
    }
    return self;
}

- (UIImage*) processFrameForEdgeImg:(CVImageBufferRef) source
{
    UIImage *image = [UIImage imageWithImageBuffer:source];
    
    cv::Mat inputImage = [image toMat];
    cv::Mat outputImage;
    
    if(false == _edgeDetection->processFrame(inputImage, outputImage))
    {
        return nil;
    }

    UIImage * result = [UIImage imageWithMat:outputImage andImageOrientation:[image imageOrientation]];
    return result;
}

- (UIImage*) processFrameForContourImg:(CVImageBufferRef) source
{
    UIImage *image = [UIImage imageWithImageBuffer:source];
    
    cv::Mat inputImage = [image toMat];
    cv::Mat outputEdges;
    
    if(false == _edgeDetection->processFrame(inputImage, outputEdges))
    {
        return nil;
    }
    
    std::vector<std::vector<cv::Point> > c;
    if(false == _contourDetection->processFrame(outputEdges, c))
    {
        return nil;
    }
    
    cv::Mat outputImage;
    cv::Mat backgoundFrame = cv::Mat::zeros( inputImage.size(), CV_8U );
    backgoundFrame.copyTo(outputImage);
    cv::drawContours(outputImage, c, -1, cv::Scalar(255,255,255), 2);
    
    UIImage * result = [UIImage imageWithMat:outputImage andImageOrientation:[image imageOrientation]];
    return result;
}

- (UIImage*) processFrameForHoughLinesImg:(CVImageBufferRef) source
{
    UIImage *image = [UIImage imageWithImageBuffer:source];
    
    cv::Mat inputImage = [image toMat];
    cv::Mat outputEdges;
    
    if(false == _edgeDetection->processFrame(inputImage, outputEdges))
    {
        return nil;
    }
    
    std::vector<std::vector<cv::Point> > c;
    if(false == _contourDetection->processFrame(outputEdges, c))
    {
        return nil;
    }
    
    //hough lines
    cv::Mat houghLinesFrame = cv::Mat::zeros( inputImage.size(), CV_8U );
    cv::drawContours(houghLinesFrame, c, -1, cv::Scalar(255,255,255));
    std::vector<cv::Vec2f> lines;
    if (false == _houghLinesDetection->processFrame(houghLinesFrame, lines)) {
        return nil;
    }
    
    std::vector<std::vector<cv::Vec2f> > clusteredLines;
    if (false == _houghLinesDetection->clusterLines(lines, clusteredLines, ClusterLineCriteria(ClusterLineCriteria::eClusterType_Theta, CV_PI/4))) {
        return nil;
    }
    
    if (clusteredLines.size() <= 0) {
        return nil;
    }
    
    std::vector<std::vector<cv::Vec2f> > diluteLines;
    for (int i = 0; i < clusteredLines.size(); i++) {
        std::vector<cv::Vec2f> lines;
        if (true == _houghLinesDetection->diluteLines(clusteredLines.at(i), lines, sqrt(powf(inputImage.rows, 2) + powf(inputImage.cols, 2)))) {
            diluteLines.push_back(lines);
        }
    }
    
    // Draw lines
    cv::Mat outputImage;
    cv::Mat backgoundFrame = cv::Mat::zeros( inputImage.size(), CV_8U );
    backgoundFrame.copyTo(outputImage);

    for (int i = 0; i < diluteLines.size(); i++) {
        std::vector<cv::Vec2f> group = diluteLines.at(i);

        for( size_t i = 0; i < group.size(); i++ ){
            cv::Vec2f line = group.at(i);

            double rho = line[0];
            double theta = line[1];

            double a = cos(theta);
            double b = sin(theta);

            double x0 = a * rho;
            double y0 = b * rho;
            int x1 = (int)(x0 + 8000*(-b));
            int y1 = (int)(y0 + 8000*(a));
            int x2 = (int)(x0 - 8000*(-b));
            int y2 = (int)(y0 - 8000*(a));

            cv::line( outputImage, cv::Point( x1, y1 ), cv::Point( x2, y2 ), cv::Scalar(255,255,255), 1);
        }
    }
    
    UIImage * result = [UIImage imageWithMat:outputImage andImageOrientation:[image imageOrientation]];
    return result;
}

- (UIImage*) processFrameForIntesectionImg:(CVImageBufferRef) source
{
    UIImage *image = [UIImage imageWithImageBuffer:source];
    
    cv::Mat inputImage = [image toMat];
    cv::Mat outputEdges;
    
    //Edges
    if(false == _edgeDetection->processFrame(inputImage, outputEdges))
    {
        return nil;
    }
    
    //Contours
    std::vector<std::vector<cv::Point> > c;
    if(false == _contourDetection->processFrame(outputEdges, c))
    {
        return nil;
    }
    
    //Check largest rectangle
    std::vector<std::vector<cv::Point> > rectangles;
    std::vector<cv::Point> largestRec;
    if (_contourDetection->findRectangleFromContours(rectangles)) {
        if (MaaSDocDetectionUtil::getLargestRectangleContour(rectangles, largestRec)) {
            
            if (cv::contourArea(largestRec) > minimumDetectedImgSize(inputImage)) {
                //draw intersecions
                cv::Mat outputImage;
                cv::Mat backgoundFrame = cv::Mat::zeros( inputImage.size(), CV_8U );
                backgoundFrame.copyTo(outputImage);
                for (int i = 0; i < largestRec.size(); i++) {
                    circle( outputImage, largestRec.at(i), 5, cv::Scalar(255, 255, 255), cv::FILLED, cv::LINE_AA );
                }
                
                UIImage * result = [UIImage imageWithMat:outputImage andImageOrientation:[image imageOrientation]];
                return result;
            }
        }
    }
    
    //hough lines
    cv::Mat backgoundFrame = cv::Mat::zeros( inputImage.size(), CV_8U );
    cv::drawContours(backgoundFrame, c, -1, cv::Scalar(255,255,255));
    std::vector<cv::Vec2f> lines;
    if (false == _houghLinesDetection->processFrame(backgoundFrame, lines)) {
        return nil;
    }
    
    std::vector<std::vector<cv::Vec2f> > clusteredLines;
    if (false == _houghLinesDetection->clusterLines(lines, clusteredLines, ClusterLineCriteria(ClusterLineCriteria::eClusterType_Theta, CV_PI/4))) {
        return nil;
    }
    
    std::vector<std::vector<cv::Vec2f> > diluteLines;
    for (int i = 0; i < clusteredLines.size(); i++) {
        std::vector<cv::Vec2f> lines;
        if (true == _houghLinesDetection->diluteLines(clusteredLines.at(i), lines, sqrt(powf(inputImage.rows, 2) + powf(inputImage.cols, 2)))) {
            diluteLines.push_back(lines);
        }
    }
    
    //Get the intersections of the lines
    std::vector< std::vector<cv::Point2f> > intersections;
    if (false == _houghLinesDetection->perpendicularIntersectionsFromLines(diluteLines, intersections)) {
        return nil;
    }
    
    //draw intersecions
    cv::Mat outputImage;
    cv::Mat backFrame = cv::Mat::zeros( inputImage.size(), CV_8U );
    backFrame.copyTo(outputImage);
    for (int i = 0; i < intersections.size(); i++) {
        std::vector<cv::Point2f> pts = intersections.at(i);
        for (int j = 0; j < pts.size(); j++) {
            circle( outputImage, pts.at(j), 5, cv::Scalar(255, 255, 255), cv::FILLED, cv::LINE_AA );
        }
        
    }
    
    UIImage * result = [UIImage imageWithMat:outputImage andImageOrientation:[image imageOrientation]];
    return result;
}

- (UIImage*) processFrameForFinalDocContourImg:(CVImageBufferRef) source
{
    UIImage *image = [UIImage imageWithImageBuffer:source];
    
    cv::Mat inputImage = [image toMat];
    cv::Mat outputEdges;
    
    //Edges
    if(false == _edgeDetection->processFrame(inputImage, outputEdges))
    {
        return nil;
    }
    
    //Contours
    std::vector<std::vector<cv::Point> > c;
    if(false == _contourDetection->processFrame(outputEdges, c))
    {
        return nil;
    }
    
    //Check largest rectangle
    std::vector<std::vector<cv::Point> > rectangles;
    std::vector<cv::Point> largestRec;
    if (_contourDetection->findRectangleFromContours(rectangles)) {
        if (MaaSDocDetectionUtil::getLargestRectangleContour(rectangles, largestRec)) {
            
            if (cv::contourArea(largestRec) > minimumDetectedImgSize(inputImage))
            {
                _docCorners.clear();
                _docCorners.resize(0);
                
                for (int i = 0; i < largestRec.size(); i++) {
                    cv::Point pt = largestRec.at(i);
                    _docCorners.push_back(pt);
                    
                }
                
                _detectedFrame.empty();
                inputImage.copyTo(_detectedFrame);
                
                //draw lines
                cv::Mat outputImage;
                cv::Mat backgoundFrame = cv::Mat::zeros( inputImage.size(), CV_8U );
                backgoundFrame.copyTo(outputImage);
                for(int i = 0; i < largestRec.size(); i++ )
                    line(outputImage, largestRec[i], largestRec[(i+1)%4], cv::Scalar(255, 255, 255), 1);
                
                UIImage * result = [UIImage imageWithMat:outputImage andImageOrientation:[image imageOrientation]];
                return result;
            }
        }
    }
    
    //hough lines
    cv::Mat backgoundFrame = cv::Mat::zeros( inputImage.size(), CV_8U );
    cv::drawContours(backgoundFrame, c, -1, cv::Scalar(255,255,255));
    std::vector<cv::Vec2f> lines;
    if (false == _houghLinesDetection->processFrame(backgoundFrame, lines)) {
        return nil;
    }
    
    std::vector<std::vector<cv::Vec2f> > clusterLines;
    if (false == _houghLinesDetection->clusterLines(lines, clusterLines, ClusterLineCriteria(ClusterLineCriteria::eClusterType_Theta, CV_PI/3))) {
        return nil;
    }
    
    std::vector<std::vector<cv::Vec2f> > diluteLines;
    for (int i = 0; i < clusterLines.size(); i++) {
        std::vector<cv::Vec2f> lines;
        if (true == _houghLinesDetection->diluteLines(clusterLines.at(i), lines, sqrt(powf(inputImage.rows, 2) + powf(inputImage.cols, 2)))) {
            diluteLines.push_back(lines);
        }
    }
    
    //Get the intersections of the lines
    std::vector< std::vector<cv::Point2f> > intersections;
    if (false == _houghLinesDetection->perpendicularIntersectionsFromLines(diluteLines, intersections)) {
        return nil;
    }
    
    //dilute points
    std::vector<cv::Point2f> centroidPts;
    if (false == _houghLinesDetection->dilutePoint(intersections, centroidPts)) {
        return nil;
    }
    
    std::vector<std::vector<cv::Point> > rects;
    if (false == MaaSDocDetectionUtil::findRectangleFromPointSet(centroidPts, rects)) {
        return nil;
    }
    
    largestRec.clear();
    if (false == MaaSDocDetectionUtil::getLargestRectangleContour(rects, largestRec)) {
        return nil;
    }
    
    if (largestRec.size() != 4 || (cv::contourArea(largestRec) > minimumDetectedImgSize(inputImage))) {
        return nil;
    }
    
    _docCorners.clear();
    _docCorners.resize(0);
    for (int i = 0; i < largestRec.size(); i++) {
        cv::Point pt = largestRec.at(i);
        
        _docCorners.push_back(pt);
    }
    
    _detectedFrame.empty();
    inputImage.copyTo(_detectedFrame);

    //draw lines
    cv::Mat outputImage;
    cv::Mat backFrame = cv::Mat::zeros( inputImage.size(), CV_8U );
    backFrame.copyTo(outputImage);
    for(int i = 0; i < largestRec.size(); i++ )
        line(outputImage, largestRec[i], largestRec[(i+1)%4], cv::Scalar(255, 255, 255), 1);
    
    UIImage * result = [UIImage imageWithMat:outputImage andImageOrientation:[image imageOrientation]];
    return result;
}

- (NSArray*) processFrame:(CVImageBufferRef) source
{
    UIImage *image = [UIImage imageWithImageBuffer:source];
    
    cv::Mat inputImage = [image toMat];
    cv::Mat outputEdges;
    
    //Edges
    if(false == _edgeDetection->processFrame(inputImage, outputEdges))
    {
        return nil;
    }
    
    //Contours
    std::vector<std::vector<cv::Point> > outputContours;
    if(false == _contourDetection->processFrame(outputEdges, outputContours))
    {
        return nil;
    }
    
    //Check largest rectangle
    std::vector<std::vector<cv::Point> > rectangles;
    std::vector<cv::Point> largestRec;
    if (_contourDetection->findRectangleFromContours(rectangles)) {
        if (MaaSDocDetectionUtil::getLargestRectangleContour(rectangles, largestRec)) {
            
            if (cv::contourArea(largestRec) > minimumDetectedImgSize(inputImage))
            {
                _docCorners.clear();
                _docCorners.resize(0);
                
                _imageOrientation = [image imageOrientation];
                
                NSMutableArray *rectCGPointArray = [[NSMutableArray alloc] initWithCapacity:4];
                
                for (int i = 0; i < largestRec.size(); i++) {
                    cv::Point2f pt = largestRec.at(i);
                    _docCorners.push_back(pt);
                    
                    //Normalize points of image
                    [rectCGPointArray addObject: [NSValue valueWithCGPoint:CGPointMake(pt.x/inputImage.cols, pt.y/inputImage.rows)]];
                }
                
                _detectedFrame.empty();
                inputImage.copyTo(_detectedFrame);
                
                return rectCGPointArray;
            }
        }
    }
    
    
    //Hough lines
    cv::Mat houghLinesFrame = cv::Mat::zeros( inputImage.size(), CV_8U );
    cv::drawContours(houghLinesFrame, outputContours, -1, cv::Scalar(255,255,255));
    std::vector<cv::Vec2f> outputHoughLines;
    if (false == _houghLinesDetection->processFrame(houghLinesFrame, outputHoughLines)) {
        return nil;
    }
    
    std::vector< std::vector<cv::Vec2f> > clusterLines;
    if (false == _houghLinesDetection->clusterLines(outputHoughLines, clusterLines, ClusterLineCriteria(ClusterLineCriteria::eClusterType_Theta, CV_PI/3))) {
        return nil;
    }
    
    std::vector<std::vector<cv::Vec2f> > diluteLines;
    for (int i = 0; i < clusterLines.size(); i++) {
        std::vector<cv::Vec2f> lines;
        if (true == _houghLinesDetection->diluteLines(clusterLines.at(i), lines, sqrt(powf(inputImage.rows, 2) + powf(inputImage.cols, 2)))) {
            diluteLines.push_back(lines);
        }
    }
    
    //Get the intersections of the lines
    std::vector< std::vector<cv::Point2f> > intersections;
    if (false == _houghLinesDetection->perpendicularIntersectionsFromLines(diluteLines, intersections)) {
        return nil;
    }
    
    std::vector<cv::Point2f> centroidPts;
    if (false == _houghLinesDetection->dilutePoint(intersections, centroidPts)) {
        return nil;
    }
    
    //dilute points
    std::vector<std::vector<cv::Point> > rects;
    if (false == MaaSDocDetectionUtil::findRectangleFromPointSet(centroidPts, rects)) {
        return nil;
    }
    
    largestRec.clear();
    if (MaaSDocDetectionUtil::getLargestRectangleContour(rects, largestRec)) {
        if (cv::contourArea(largestRec) > minimumDetectedImgSize(inputImage)) {
            _docCorners.clear();
            _docCorners.resize(0);
            
            _imageOrientation = [image imageOrientation];
            
            NSMutableArray *rectCGPointArray = [[NSMutableArray alloc] initWithCapacity:4];
            for (int i = 0; i < largestRec.size(); i++) {
                cv::Point2f pt = largestRec.at(i);
                
                _docCorners.push_back(pt);
                
                //Normalize points of image
                [rectCGPointArray addObject: [NSValue valueWithCGPoint:CGPointMake(pt.x/inputImage.cols, pt.y/inputImage.rows)]];
            }
            
            _detectedFrame.empty();
            inputImage.copyTo(_detectedFrame);
            
            return rectCGPointArray;
        }
    }
    
    return nil;
}

- (UIImage*) cropImage
{
    cv::Mat outputImage;
    _cropImage->processFrame(_detectedFrame, _docCorners, outputImage);
    
    UIImage * result = [UIImage imageWithMat:outputImage andImageOrientation:UIImageOrientationRight];
    return result;
}

@end
