function [ crackROIUpdate ] = locateOrigin( img, crackROI, crackStartROI, templateImg )
%locateOrigin Locates the origin of the crack
%   Detailed explanation goes here
global xPeakOriginal yPeakOriginal
    %% Calculate the cross correlation between the image and the templateImage
    % Calculate a comparable image (subtract its mean)
    imgROI = im2double(imcrop(img, crackROI)); 
    nimg = imgROI - mean(mean(imgROI));
    % Calculate the cross correlation
    cc2 = xcorr2(nimg,templateImg);
    % Remove the padding
    cc2 = cc2(size(templateImg,1):(size(cc2,1)),size(templateImg,2):size(cc2,2));
    
    %% Find the maximum
    [~, imax] = max((cc2(:)));
    [ypeak, xpeak] = ind2sub(size(cc2),imax(1));
    
    %% Update the ROI
    crackROIUpdate = crackStartROI;
    crackROIUpdate(1) = crackStartROI(1) + xpeak - xPeakOriginal;
    crackROIUpdate(2) = crackStartROI(2) + ypeak - yPeakOriginal;
end

