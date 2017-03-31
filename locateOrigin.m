function [ crackROIUpdate ] = locateOrigin( img, crackROI, crackStartROI, templateImg )
%locateOrigin Locates the origin of the crack
%   Detailed explanation goes here
global xPeakOriginal yPeakOriginal
    % Find the crack start within the 'cracROI' ROI
    imgROI = im2double(imcrop(img, crackROI)); 

    %cc = normxcorr2(templateImg,imgROI);
    %cc = cc(size(templateImg,1):(size(cc,1)),size(templateImg,2):size(cc,2)); %remove the padding
    cc2 = xcorr2(imgROI, im2double(templateImg));
    cc2 = cc2(size(templateImg,1):(size(cc2,1)),size(templateImg,2):size(cc2,2)); %remove the padding
   
    [~, imax] = max((cc2(:)));
    [ypeak, xpeak] = ind2sub(size(cc2),imax(1));
%   corr_offset = [ (ypeak-size(templateImg,1)) (xpeak-size(templateImg,2)) ]; %Not needed since padding was removed
%   corr_offset = [ (ypeak) (xpeak) ];

    
    crackROIUpdate = crackStartROI;
    crackROIUpdate(1) = crackStartROI(1) + xpeak - xPeakOriginal;
    crackROIUpdate(2) = crackStartROI(2) + ypeak - yPeakOriginal;
    %crackROIUpdate(1) = crackROI(1) + xpeak - crackROIUpdate(3);
    %crackROIUpdate(2) = crackROI(2) + ypeak + crackROIUpdate(4);
end

