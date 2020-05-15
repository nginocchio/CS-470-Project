function getROIpatches( datasetDir, diseaseLabel )
% This function will grab patches from CT slices (dicom files) based on
% regions of interested for every patient in ILD_medgift database.
% Specifically using the regions of interest from the ILD_DB_txtROIS files.
% The extracted patches are linearly transformed back into their original
% Hounsfield Unit (HU) pixel values and then converted into a 3 channel
% 8-bit RBG png image. Helper functions HUtoRGB.m and mapHuToRGB.m are 
% specifically used to handle the conversion from HU to 3 channel RGB. The
% patches are then saved in a file called ILD_DB_patientROIpatches. If this
% directory does not already exist it will be created for you.
%
% --------------------------------WARNING----------------------------------
%
% Any patches/images saved in the ILD_DB_patientROIpatches folder will be
% overwritten if another image with the same name is being saved into the
% folder. Copying the patches created by this framework are recommended to 
% be saved into a seperate location before running more tests to insure no
% data is overwritten.

% creates the folder that patches will be saved to if it doesn't exist
if exist ('ILD_DB_patientROIpatches', 'file') ~= 7
    mkdir ./ILD_DB_patientROIpatches
end

% adds the folder to the matlab path so that it can be accessed
addpath('ILD_DB_patientROIpatches');

% variable to be used later to indicate where to save the pathces
parentDir = '.\ILD_DB_patientROIpatches\';
datasetDir = '.\';

% an array of multiple diseases can be used to grab patches of all desired 
% diseases from the database (as long as the disease exists in the DB)
% However this will take longer and may be slower depending on how many
% and which diseases are chosen.

%original data set diseases
%diseaseLabelArray = {'fibrosis', 'micronodules', 'emphysema', 'healthy', 'ground_glass'};

%all possible diseases
%diseaseLabelArray = {'cysts', 'healthy', 'fibrosis', 'ground_glass', 'micronodules', 'consolidation', 'reticulation', 'emphysema', 'bronchiectasis', 'macronodules'};
diseaseLabelArray = {'reticulation'};

% gathers txt files from ILD_DB_txtROIs which have information about ROIs
files = subdir(strcat(datasetDir, 'ILD_DB_txtROIs\*.txt'));

% how many diseases classes there are for patch exctraction.
disp("Number of disease classes being tested: ")
disp(numel(diseaseLabelArray));

% Grabs all patches of one disease from all applicable patients before
% moving on to a new disease.
for d = 1:numel(diseaseLabelArray)
    
    % current disease label
    diseaseLabel = char(diseaseLabelArray(d));
    
    % resets patch number to one for every new disease.
    ROIpatchNum = 1;
    disp(diseaseLabel);

    % Explicitly using first 109 files (essentially disregarding 
    % HRCT_pilot directory)
    for i=1:109 
        
        % gets filename for patient to be evaluated
        ROIfileName = files(i).name;
        
        %Get the directory fpath containing the DICOM data
        [fpath, fname, ~] = fileparts(ROIfileName);
        
        %Construct the root of the dicom filename
        droot = strcat(fpath, '\CT-', fname(end-3:end),'-');
        
        % gathers ROI information (disease labels, xy coordinates, etc.)
        % for specific patient
        ROIs = loadROIfiles(ROIfileName);

        for j = 1:numel(ROIs)
            %if ROI with current diseaseLabel exists
            if strcmp(ROIs(j).label,diseaseLabel)
                
                %load the slice containing the ROI
                slice = ROIs(j).slice_number;
                slicestr = sprintf('%.4d',slice);
                
                % grabs the specific .dcm file from the ct volume
                dicomfname = strcat(droot, slicestr,'.dcm'); 
                
                % gets the dicom file names for the files that don't follow the
                % normal naming convention.
                if exist (dicomfname, 'file') ~= 7 
                    dcmFiles = subdir(strcat(fpath, '\*.dcm'));
                    dicomfname = dcmFiles(slice).name;
                end
                info = dicominfo(dicomfname);
                Y = dicomread(info);
                if(isa(Y, 'uint16'))
                    Y = cast(Y, 'int16');
                end

                % creating black and white version of the CT image
                % also draws the ROI over the image. (Drawing the ROI over 
                % the image is purely for visual purposes and does not
                % change or modify the original image.)
                [BW, xj, yj] = roipoly(Y,ROIs(j).xValues/ROIs(j).spacing_x,ROIs(j).yValues/ROIs(j).spacing_y);
                
                xmin = 1;
                ymin = 1;
                
                % both width and height should be the same to get a proper 
                % square sized patch
                % sizes 16, 32, and 64 are the recommended options.
                patchWidth  = 32; 
                patchHeight = 32; 
                
                % shiftVal will be the percentage of the height or width by
                % which the patch location will move while iterating through
                % the CT image. Choose values 0.25, 0.50, or 1 in order to 
                % get an even value to increment by, if using patch sizes
                % of 16, 32, or 64.
                shiftVal = .5;
                patchShift = patchWidth * shiftVal;
                
                % percentge of pixels in that area to have value of 1 in 
                % order to be an ROI patch worth extracting
                patchQualification = 0.5; 
                areaPatch = patchWidth*patchHeight;
                imwidth = info.Width;
                imheight = info.Height;
                dLabel = ROIs(j).label;
                patientNum = extractAfter(fpath, '.\ILD_DB_txtROIs\');
                
                % rescaleSlope and rescaleIntercept are values that will
                % be used in the linear transformation back to HU.
                rescaleSlope = info.RescaleSlope;
                rescaleIntercept = info.RescaleIntercept;
                
                % handles the patients that have more that one CT folder
                if(length(patientNum) > 3)
                    pNum = strsplit(patientNum, '\');
                    patientNum = char(pNum(1));
                end
                
                % seriesNumber refers to a series of CTs that were taken
                % at the same time. Could be useful in utilizing ROIs that
                % are coming from the same 3 dimensional region of the lung
                seriesNumber = num2str(info.SeriesNumber);
                
                % makes sure that only patches of the specified size are
                % grabbed
                if(shiftVal == 1)
                    subBy = 0;
                elseif(shiftVal == 0.5)
                    subBy = 1;
                elseif(shiftVal == 0.25)
                    subBy = 3;
                end
                
                % for loop to start moving through the image one patch at a time.
                for r = 1:((imheight/patchShift)-subBy)
                    for c = 1:((imwidth/patchShift)-subBy)
                        ROIpixelCount = 0;
                        
                        % cropping the patch from the Black and White
                        % version of the CT to evaluate which pixels
                        % are inside the ROI. White (1) is inside the ROI
                        % and black (0) is outside.
                        patch  = imcrop(BW, [xmin ymin patchWidth-1 patchHeight-1]);
                        
                        % check pixel values in patch
                        for h=1:patchHeight
                            for w=1:patchWidth
                                if patch(h, w) == 1
                                    ROIpixelCount = ROIpixelCount + 1;
                                end
                            end
                        end
                        
                        % if the patch meets the ROI patch qualifations
                        % process and save the image to the
                        % ILD_patientROIpatches folder
                        if ROIpixelCount >= areaPatch*patchQualification
                            ROIpatch = imcrop(Y, [xmin ymin patchWidth-1 patchHeight-1]);
                            
                            % transformation back into HU
                            ROIpatch = ROIpatch * rescaleSlope;
                            ROIpatch = ROIpatch + rescaleIntercept;

                            % creates file name that the patch will be
                            % saved under
                            patientROIpatch = strcat(dLabel, '_series', seriesNumber, '_slice', slicestr, '_patch', sprintf('%d', ROIpatchNum), '_patient', patientNum, '.png');
                            patchDestination = strcat(parentDir, patientROIpatch);
                            
                            % convert single channel HU image to a 3
                            % channel  8-bit RGB png
                            HUtoRGB(ROIpatch, patchDestination);
                            ROIpatchNum = ROIpatchNum + 1;
       
                        end
                        
                        % move the x coordinate by the desired shift value
                        xmin = xmin + patchShift;

                    end
                    
                    % move the y coordinate by the desired shift value
                    xmin = 1;
                    ymin = ymin + patchShift;
                        
                end
            end
        end
    end
end

