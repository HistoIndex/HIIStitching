function [stitchImg,alStitchImg] = stitchConst(folder, rOLPCT, cOLPCT)
% folder: folder name
% olpct: overlap percentage
if nargin < 2
    error(['Not enough input parameters']);
end
if nargin == 2
    cOLPCT = rOLPCT;
end
if ~exist(folder)
    error(['Cannot find ',folder]);
end

trSplitedStrs = strsplit(folder,'=');
tX = trSplitedStrs{2};
tY = trSplitedStrs{3};

tileCNo = str2num(tX(1:3));
tileRNo = str2num(tY(1:3));

firstImgName = [folder,'\000000.tif'];
if ~exist(firstImgName)
    error(['Cannot find ',firstImgName]);
else
    firstImg = imread(firstImgName);
    [rPSize,cPSize,nChannel] = size(firstImg);
end

if rPSize ~= cPSize
    error('Tile is not square');
end

if isdeployed
    rOLPCT = str2double(rOLPCT);
    cOLPCT = str2double(cOLPCT);
end

rOLPNo = uint16(rPSize * rOLPCT); % row overlap pixel number
rOffset = uint16(rPSize - rOLPNo);

cOLPNo = uint16(cPSize * cOLPCT);
cOffset = uint16(cPSize - cOLPNo);

rStitchPSize = rPSize*tileRNo - (tileRNo-1)*rOLPNo;
cStitchPSize = cPSize*tileCNo - (tileCNo-1)*cOLPNo;

stitchImg = zeros(rStitchPSize, cStitchPSize, nChannel);
stitchImgMask = zeros(rStitchPSize, cStitchPSize, nChannel); % how many times the pixel is added.

n=0;
for trNo=0:1:tileRNo-1
    for tcNo=0:1:tileCNo-1
        imgName = [sprintf('%06d',trNo*tileCNo+tcNo),'.tif'];
        tile = double(imread([folder,'\',imgName]));
        rCurStart = trNo*rOffset+1;
        rCurEnd = trNo*rOffset+rPSize;
        cCurStart = tcNo*cOffset+1;
        cCurEnd = tcNo*cOffset+cPSize;

        stitchImg(rCurStart:rCurEnd,cCurStart:cCurEnd,:) = stitchImg(rCurStart:rCurEnd,cCurStart:cCurEnd,:) + tile;
        stitchImgMask(rCurStart:rCurEnd,cCurStart:cCurEnd,:) = stitchImgMask(rCurStart:rCurEnd,cCurStart:cCurEnd,:) + ones(rPSize,cPSize,3);
        %debug%
        msg = [num2str(trNo+1),' ', num2str(tcNo+1)];
        fprintf(repmat('\b',1,n));
        fprintf(msg);
        n=numel(msg);
        pause(0.01);
%         disp([num2str(trNo),' ', num2str(tcNo)]);
    end
end

stitchImg = uint16(stitchImg./stitchImgMask);
stitchImg = im2uint8(stitchImg);
%figure,imshow(stitchImg,[]);
% imwrite(stitchImg,[folder,'\rawStitched.tif'],'Compression','lzw');
% fileattrib([folder,'\rawStitched.tif'],'+h');
alStitchImg = autolevel(stitchImg);
imwrite(alStitchImg,[folder,'\stitched.tif'],'Compression','lzw');
fprintf(' stitching completed\n');