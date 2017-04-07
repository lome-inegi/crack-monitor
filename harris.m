% --------------------------------------------------------------------
function [r,c] = harris(im, sigma, radius, originCircleRadius, referenceCrackOrigin, rectCrackStartROI) 
    thresh = 0;
%% Validate input values to avoid errors
    if (radius * 2 ~= floor(radius * 2))
        radius = floor(radius * 2) / 2;
    end
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
        % Circle with radius 'originCircleRadius' centered at
        % 'referenceCrackOrigin'
        [rr, cc] = meshgrid(1:size(cimCrop,2),1:size(cimCrop,1));
        cimCropCircle = sqrt((rr-referenceCrackOrigin(2)).^2+(cc-referenceCrackOrigin(1)).^2) <= originCircleRadius;
        % Retain values
        cimCropFilter = cimCropCircle .* cimCrop;
        % Find maximum
        [~, imax] = sort(cimCropFilter(:),'descend');
        [r_max,c_max] = ind2sub(size(cimCropFilter),imax(1));
        % If no result possible
        if (max(cimCropFilter(:)) == min(cimCropFilter(:)))
           r_max = [];
           c_max = [];
        end
    else
%% Maximum/Sort
        [~, imax] = sort(cimCrop(:),'descend');
        [r_max,c_max] = ind2sub(size(cimCrop),imax(1));
     end
    
%% Output
    r = r_max;
    c = c_max;
    