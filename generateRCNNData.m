function gTruth = generateRCNNData(datasetDir, diseaseLabel)
%This funcation goes through a portion of the dataset and creates bounding
%boxes around the specified diseaseLabels
% It returns a M x diseaseLabel cell array where each column corresponds
% to the index within diseaseLabel. Where M represents the total ROIs

% Example usage
%---------------------------
% datasetDir = './'; % Assuming root project folder
% diseaseLabel = ["consolidation", "ground_glass"];
% diseaseBoxes = generateRCNNData(datasetDir, diseaseLabel);

%---------------------------

datasetDir = './'; %Assumes current working directory is the directory containing the database ILD_medgift
% emphysema was taken out
%diseaseLabel = ["fibrosis", "micronodules", "consolidation", "healthy", "ground_glass", "reticulation", "macronodules", "bronchiectasis"]; %'micronodules';%'emphysema';%'consolidation';%'healthy';%'fibrosis';%'ground_glass';
diseaseLabel = convertCharsToStrings(diseaseLabel);


% diseaseLabel = 'fibrosis';

if exist ('annotated_images', 'file') ~= 7
    mkdir ./annotated_images
end
annotatedImgs = '.\annotated_images\';

%First recursively get all files ending with .txt. Those contain information on all ROIs
files = subdir(strcat(datasetDir, 'ILD_DB_txtROIs/*.txt'));

imageFileNames = {};
bounding_boxes = {};
imgLabels = [];

diseaseBoxes = {};

% This code uses an array of diseases
% Specify the number of patients to add to annotated_images
for i=1:15%length(files) %Explicitly using first 109 files (essentially disregarding HRCT_pilot directory) will give results that match table 5 in the paper .. mostly..
    ROIfileName = files(i).name;
    disp(ROIfileName);
        
    %Get the directory fpath containing the DICOM data 
    [fpath, fname, ~] = fileparts(ROIfileName);
    patientNum = split(fpath, '\');
    patientDir = strcat(annotatedImgs, patientNum{3}, '\');

    
    
    %Construct the root of the dicom filename
    droot = strcat(fpath, '/CT-', fname(end-3:end),'-');
    
    ROIs = loadROIfiles(ROIfileName);
    for j = 1:numel(ROIs)
        if ~ismember(ROIs(j).label, diseaseLabel)
            continue;
        end

        if exist (patientDir, 'file') ~= 7
            mkdir(patientDir);
        end

        newEntry = cell(1,numel(diseaseLabel));

        %load the slice containing the ROI
        slice = ROIs(j).slice_number;
        slicestr = sprintf('%.4d',slice);
        dicomfname = strcat(droot, slicestr,'.dcm');

        if exist (dicomfname, 'file') ~= 7 
            dcmFiles = subdir(strcat(fpath, '\*.dcm'));
            dicomfname = dcmFiles(slice).name;
        end


%             disp(dicomfname)
        info = dicominfo(dicomfname);
        Y = dicomread(info);
        if(isa(Y, 'uint16'))
            Y = cast(Y, 'int16');
        end

        rescaleSlope = info.RescaleSlope;
        rescaleIntercept = info.RescaleIntercept;

        Y = Y * rescaleSlope;
        Y = Y + rescaleIntercept;

        new_image_name = strcat(patientDir, fname, '-', slicestr, '.png');

        % if a png version of the dcm file doesn't exist
        % create it
        if ~isfile(new_image_name)
            HUtoRGB(Y, new_image_name);
        end


        % add file path to file path vector
        imageFileNames = [imageFileNames; new_image_name;];

        %figure(1), imshow(Y, []);
        [BW, xj, yj] = roipoly(Y,ROIs(j).xValues/ROIs(j).spacing_x,ROIs(j).yValues/ROIs(j).spacing_y);


        %Create polygon of ROI
        polyin = polyshape(xj, yj, 'Simplify', false);
        simple_poly = simplify(polyin);
        % Get minimum bounding box around polygon
        [xlim, ylim] = boundingbox(simple_poly);

        % Get the dimensions of this bounding box
        bound_width = diff(xlim);
        bound_height = diff(ylim);
        x = xlim(1);
        y = ylim(1);

        bounding_boxes = [bounding_boxes; x y bound_width bound_height;];
        imgLabels = [imgLabels; convertCharsToStrings(ROIs(j).label)];

        idx = diseaseLabel==ROIs(j).label;

        newEntry(1, idx) = {[x y bound_width bound_height]};

        diseaseBoxes = [diseaseBoxes; newEntry];
        
%         To draw the slice and display roi and bounding box
%-------------------------------------------------------------
%         RGB = imread(new_image_name);
%         new_im = insertObjectAnnotation(RGB, 'Rectangle', [x y bound_width bound_height], ROIs(j).label, 'Color', 'cyan');     
%         figure
%         imshow(new_im)
%         h = drawpolygon('Position', [xj, yj], 'LineWidth', 1);
%         tic,pause(10),toc;
%         close all;
%-------------------------------------------------------------
    end

end

gTruth = [imageFileNames, diseaseBoxes];

end
