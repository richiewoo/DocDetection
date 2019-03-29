# DocDetection
Detect document based on OpenCV lib.

A powerful productivity of tool can make work better, document detection for scanning is the one of those. And machine learning make it easier and accurate, as a computer vision application, machine learning algorithm has been proved to be tremendously succcessful.

Within this sample app based on iOS platform, capture live video fro camera in conjunction with OpenCV lib, to scan the document by breaking down each steps from edge detection, contour detection, hough lines and intersections of diluted hough lines, end up with 4 vertices we are interested in, it turns out the document can be cropped out from these four points.

Coz all detection process is running on CPU, undoubtedly the performance is too bad, so the next we alternatively work it out with iOS Vision Framework, CoreML plus our own trained models.
