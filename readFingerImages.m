function imOut = readFingerImages(filename)
% filename = 'index_3.bmp';
initialSize = [190,336];
basePaperSize = [65,153];

im = imread(filename);
im = imresize(im,initialSize);
imG = rgb2gray(im);
im1 = uint8(myLee(imG));
im2 = im1(31:170,:);  % ROI extraction
im3 = adapthisteq(im2);% CLAHE method
imOut = imresize(im3,basePaperSize);


montage({im,imG,im1,im2,im3,imOut})
end