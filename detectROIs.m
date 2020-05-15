function detectROIs()
% This function takes an image and a classifier and returns potential ROIs
img = dicomread('.\ILD_DB_txtROIs\101/CT-0002-0006.dcm');
rowSize = 3;
columnSize = 3;

function x = classifyWindow(imgPatch)
    
end

filtered_img = colfilt(img, [rowSize, columnSize], 'sliding', @mean);
figure
imshow(filtered_img,[]);
%montage({img, filtered_img})
title('Original Image (left) and Median Filtered Image (right)')
end