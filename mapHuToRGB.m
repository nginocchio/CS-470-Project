function [ channelPatch ] = mapHuToRGB(ROIpatch, minHU, maxHU)
%Rescales Hounsfield unit to the range [0,255] using linear transformation. 
% 
%     Inputs:
%         ROIpatch: Image patch that is being converted to RGB
%         minHU: Hounsfield unit value to map to 0 (integer)
%         maxHU: Hounsfield unit value to map to 255 (integer)
%     Output: image channel in range [0,255]

[width, height] = size(ROIpatch);

% new blank image that will take on the channel values so that the original
% patch isn't overwritten
channelPatch = zeros(width);

for i=1:height
    for j=1:width
        
        if ROIpatch(i, j) < minHU
            channelPatch(i, j) = 0;
        elseif ROIpatch(i, j) > maxHU
            channelPatch(i, j) = 255;
        else
            spanHU = maxHU - minHU;
            valueScaled = single(ROIpatch(i, j) - minHU) / single(spanHU);
            channelPatch(i, j) = uint16((valueScaled * 255));
        end
        
    end
end

end

