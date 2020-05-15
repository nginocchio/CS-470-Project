function HUtoRGB(ROIpatch, patchDestination)
% HUTORGB Takes in an ROI patch that currently has int16 values equivalent
% to the CT scans original HU values. It takes this patch , which is a
% single channel image, and creates red, green, and blue channels based
% off of a specified HU range of values.
%
%   Inputs:
%       ROIpatch: Image patch to be converted to RGB
%       patchDestination: Where the RGB patch will be saved

%minR = -1400;
%maxR = -853;
%minG = -852;
%maxG = -306;
%minB = -305;
%maxB = 240;

%minR = -1400;
%maxR = -950;
%minG = -1400;
%maxG = -200;
%minB = -160;
%maxB = 240;

minR = -1400;
maxR = -601;
minG = -600;
maxG = -201;
minB = -200;
maxB = 200;

% mapHUtoRGB converts the HU image to a red, gree, or blue channel image
red = mapHuToRGB(ROIpatch, minR, maxR);
green = mapHuToRGB(ROIpatch, minG, maxG);
blue = mapHuToRGB(ROIpatch, minB, maxB);

% combines the three channels created by mapHUtoRGB into a single image.
RGBpatch = cat(3, uint8(red), uint8(green), uint8(blue));

% saves the patch to the specific destination
imwrite(RGBpatch, patchDestination, 'png');
%imwrite(ROIpatch, patchDestination, 'png');
end

