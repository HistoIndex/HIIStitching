function outimg = autolevel(img)
outimg(:,:,1)=imadjust(img(:,:,1));
outimg(:,:,2)=img(:,:,2);
outimg(:,:,3)=img(:,:,3);
% my_limit=0.5;
% a=double(img)./255;
% mean_adjustment=my_limit-mean(mean(a(:,:,1)));
% a(:,:,1)=a(:,:,1)+mean_adjustment*(1-a(:,:,1));
% outimg = uint8(a.*255);