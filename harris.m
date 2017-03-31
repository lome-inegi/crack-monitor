% --------------------------------------------------------------------
function [r,c] = harris(im, sigma, radius, originCircleRadius, referenceCrackOrigin, rectCrackStartROI) 
    thresh = 0; % Filter possible negative values only
%% Preliminary calculations    
    dx = [-1 0 1; -1 0 1; -1 0 1]; % Derivative masks
    dy = dx';
    Ix = conv2(im, dx, 'same');    % Image derivatives
    Iy = conv2(im, dy, 'same');    
    % Generate Gaussian filter of size 6*sigma (+/- 3sigma) and of
    % minimum size 1x1.
    g = fspecial('gaussian',max(1,fix(6*sigma)), sigma);
    
%% Calculate Harris' parameters    
    Ix2 = conv2(Ix.^2, g, 'same'); % Smoothed squared image derivatives
    Iy2 = conv2(Iy.^2, g, 'same');
    Ixy = conv2(Ix.*Iy, g, 'same');

    cim = (Ix2.*Iy2 - Ixy.^2)./(Ix2 + Iy2 + eps);   % Alison Noble, "Descriptions of Image Surfaces", PhD thesis, Department
                                                    % of Engineering Science, Oxford University 1989, p45.
    sze = 2*radius+1;                   % Size of mask.
    mx = ordfilt2(cim,sze^2,ones(sze)); % Grey-scale dilate.
    cimmx = ((cim==mx)&(cim>thresh)).*cim;       % Find maxima, keeping values
%% Crop to ROI    
    cimCrop = imcrop(cimmx,rectCrackStartROI);
    
%% Bordermask    
    % Make mask to exclude points within radius of the image boundary. 
    bordermask = zeros(size(cimCrop));
    borderRadius = ceil(radius);
    bordermask(borderRadius+1:end-borderRadius, borderRadius+1:end-borderRadius) = 1;
    cimCrop = bordermask .* cimCrop;
     
 %% Choose result
     if (~isempty(referenceCrackOrigin))
 %% If there is a previous result, compare
        %Circle with radius centered at referenceCrackOrigin
        [rr, cc] = meshgrid(1:size(cimCrop,2),1:size(cimCrop,1));
        cimCropCircle = sqrt((rr-referenceCrackOrigin(2)).^2+(cc-referenceCrackOrigin(1)).^2) <= originCircleRadius;
        cimCropFilter = cimCropCircle .* cimCrop;
        [~, imax] = sort(cimCropFilter(:),'descend');
        [r_max,c_max] = ind2sub(size(cimCropFilter),imax(1));
%         [pX, pY]=find(imregionalmax(cimCropFilter)>0);
%         %figure;h=surf(cimCropFilter);set(h,'LineStyle','none');
%         distResult = pdist2([pX pY],[referenceCrackOrigin(2)-rectCrackStartROI(2), referenceCrackOrigin(1)-rectCrackStartROI(1)]);
%         [~, imin] = min(distResult);
%         r_max = pX(imin);
%         c_max = pY(imin);
        if (max(cimCropFilter(:)) == min(cimCropFilter(:)))
           r_max = [];
           c_max = [];
        end
    else
%% Maximum/Sort
        [~, imax] = sort(cimCrop(:),'descend');
        [r_max,c_max] = ind2sub(size(cimCrop),imax(1));
    end
    
%% Filter
%     linX = linspace(0,1,floor((rectCrackStartROI(3)+1)/3));
%     linY = linspace(0,1,floor((rectCrackStartROI(4)+1)/3));
%     linX2 = [linX ones([1 floor((rectCrackStartROI(3)+1)/3)+mod(floor(rectCrackStartROI(3))+1,3)]) fliplr(linX)];
%     linY2 = [linY ones([1 floor((rectCrackStartROI(4)+1)/3)+mod(floor(rectCrackStartROI(4))+1,3)]) fliplr(linY)];
%     filt = linY2'*linX2; % Higher likelihood of it beeing in the center of the ROI and 0 likelihood of it being in the edges
%
%     cimCropFilt = cimCrop .* filt;
%     [~, imax] = max(cimCropFilt(:));
%     [r_max,c_max] = ind2sub(size(cimCropFilt),imax(1));
    

%% Subpixel
%     cimCropOrig = imcrop(cim,rectCrackStartROI);
%     w=1;
%     cy = cimCropOrig(r_max,c_max);
%     ay = (cimCropOrig(r_max-1,c_max)+cimCropOrig(r_max+1,c_max))/2 - cy;
%     by = ay + cy - cimCropOrig(r_max-1,c_max);
%     if (ay ~= 0)
%         rshift = -w*by/(2*ay); 
%     else
%         rshift = 0;
%     end
%     cx = cimCropOrig(r_max,c_max);
%     ax = (cimCropOrig(r_max,c_max-1)+cimCropOrig(r_max,c_max+1))/2 - cx;
%     bx = ax + cx - cimCropOrig(r_max,c_max-1);
%     if (ax ~= 0)
%         cshift = -w*bx/(2*ax); 
%     else
%         cshift = 0;
%     end
    
%% Output
    r = r_max;
    c = c_max;
    