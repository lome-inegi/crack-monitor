function [crckbin, lengthpix, BoundingBox, Image] = processCrack(crckimg, cracROI, crackOrigin, saveImg)
global SEImg ImgProcDataStructure myFolder
%% Input verification
if (~islogical(saveImg))
   saveImg = false; 
end

%% Startup definitions
ClipLimit = ImgProcDataStructure.ClipLimit;
THRect = ImgProcDataStructure.THRect;
GrayThresh = ImgProcDataStructure.GrayThresh;
StrelLR = ImgProcDataStructure.StrelLR;
CloseActions = ImgProcDataStructure.CloseActions;
SORemov = ImgProcDataStructure.SORemov;

%Structuring elements for morphological file processing tasks below
SESBallOverMLab = strel('ball', 3, -3, 0);

se = strel('disk',3,0);
seh = imdilate(SEImg, se);
X=crackOrigin(2); Y=crackOrigin(1);
sz=size(crckimg);
% Again, the cracks can run to either side...
if X>sz(2)/2
    toRight=0;
else
    toRight=1;
end    

%% Image processing
imgC = im2double(imcrop(crckimg, cracROI));
imCl = imclose(imgC,SESBallOverMLab);
imOp = imopen(imCl,SESBallOverMLab);
T = imgC - min(imOp,imgC);
imAT = adapthisteq(T,'ClipLimit',ClipLimit);

% Remove grayscale vertical lines - scratches
% THRect = [30 2]; % Default value
sev=strel('rectangle', THRect);
% Top-hat operation
imAT=imtophat(imAT,sev);

% Binarize
% Th=1.00; % Default threshold
level = GrayThresh*graythresh(imAT);
bw = im2bw(imAT,level);

if (saveImg)
    try
        imwrite(bw,[myFolder 'ROI1.tif'],'WriteMode','append');
    catch
    end
end

% Remove BW vertical lines - scratches that still remain
se = strel('line',StrelLR,0); % Line at 0 degrees
bw=imerode(bw,se);
% Vertical dilate and bridge. To remove 1 px gaps
se = strel('line',StrelLR,90); % Vertical line: 90 degrees. Maybe use a separate parameter?
bw=imdilate(bw,se);
bw=bwmorph(bw,'bridge');

if (saveImg)
    try
        imwrite(bw,[myFolder 'ROI2.tif'],'WriteMode','append');
    catch
    end
end

% Enhance the crack line with the structuring element from crack analysis
se = strel(seh);
for i=1:CloseActions bw=imclose(bw,se); end

if (saveImg)
    try
        imwrite(bw,[myFolder 'ROI3.tif'],'WriteMode','append');
    catch
    end
end

% Remove small objects
crckbin=bwareaopen(bw,SORemov);
if (saveImg)
    try
        imwrite(crckbin,[myFolder 'ROI4.tif'],'WriteMode','append');
    catch
    end
end

%% Region properties calculation
% Area Statistics: find the largest connected components area -
% represents the crack. If a bounding box contains the origin,
% it is the best candidate for the crack. This helps avoid the influence
% of larger bright areas.
% Next, return the bounding box's length - the crack projection on the xx axis

stats = regionprops(crckbin, 'Area','BoundingBox','Extrema','Image');
PosArray=zeros(1,length(stats)); AreaArray=zeros(1,length(stats));

% Define the origin in 'cracROI' coordinates
relativeOrigin = [crackOrigin(2)-cracROI(1) crackOrigin(1)-cracROI(2)];
inside=ones(length(stats),1);

%% Region selection
% Check if the origin is contained in any of the detected regions
corners=zeros(4,2,length(stats));
for j=1:length(stats)
    AreaArray(j) = stats(j).Area;
    PosArray(j) = stats(j).BoundingBox(1);
    corners(1,1,j) = stats(j).BoundingBox(1);
    corners(1,2,j) = stats(j).BoundingBox(2);
    corners(2,1,j) = stats(j).BoundingBox(1)+stats(j).BoundingBox(3);
    corners(2,2,j) = stats(j).BoundingBox(2);
    corners(3,1,j) = stats(j).BoundingBox(1)+stats(j).BoundingBox(3);
    corners(3,2,j) = stats(j).BoundingBox(2)+stats(j).BoundingBox(4);
    corners(4,1,j) = stats(j).BoundingBox(1);
    corners(4,2,j) = stats(j).BoundingBox(2)+stats(j).BoundingBox(4);
    
    xv=[corners(:,1,j); corners(1,1,j)];
    yv=[corners(:,2,j); corners(1,2,j)];
    inside(j) = inpolygon(relativeOrigin(1),relativeOrigin(2),xv,yv);
end

% If not, consider them all
if ~any(inside)
    inside=~inside;
end

% Filter the areas of the ones that are not to be considered
for k=1:length(stats)
   if(inside(k)==0)
       AreaArray(k) = 0;
   end
end

%% Find the maximum area among the selected regions
[~,idxMax]=max(AreaArray);

%% Calculate pixel length
if toRight
    TipXX = stats(idxMax).Extrema(3);
    lengthpix = TipXX - (X-cracROI(1));
else
    TipXX = stats(idxMax).Extrema(8);
    lengthpix = (X-cracROI(1)) - TipXX;
end
% Usually, tipXX is a value half pixel to the left/right of the outermost
% pixel, that is, up to the border between that pixel and the next and X
% is the center of the pixel. This means that lengthpix won't be a round
% number.

%% Return the selected region's Image and BoundingBox
BoundingBox=stats(idxMax).BoundingBox;
Image = stats(idxMax).Image;