function visualizeROIs(datasetDir, diseaseLabel)
%This funcation goes through the entire dataset and displays all slices (one by one)
%with ROI labeled with the diseaseLabel. Sample Usage: visualizeROIs('./','fibrosis')

datasetDir = './'; %Assumes current working directory is the directory containing the database ILD_medgift 
diseaseLabel = 'fibrosis';%'micronodules';%'emphysema';%'consolidation';%'healthy';%'fibrosis';%'ground_glass';

%First recursively get all files ending with .txt. Those contain infomation on all ROIs
files = subdir(strcat(datasetDir, 'ILD_DB_txtROIs/*.txt')); 


for i=1:length(files) %Explicitly using first 109 files (essentially disregarding HRCT_pilot directory) will give results that match table 5 in the paper .. mostly..
    ROIfileName = files(i).name;
        
    %Get the directory fpath containing the DICOM data 
    [fpath, fname, ~] = fileparts(ROIfileName);
    
    %Construct the root of the dicom filename
    droot = strcat(fpath, '/CT-', fname(end-3:end),'-');
    
    ROIs = loadROIfiles(ROIfileName);
       
    for j = 1:numel(ROIs)
        if strcmp(ROIs(j).label,diseaseLabel) %if ROI with diseaselabel exists
            %load the slice containing the ROI
            slice = ROIs(j).slice_number;
            slicestr = sprintf('%.4d',slice);
            dicomfname = strcat(droot, slicestr,'.dcm');  
            info = dicominfo(dicomfname);
            Y = dicomread(info);
            
            figure(1), imshow(Y, []);
            [BW, xj, yj] = roipoly(Y,ROIs(j).xValues/ROIs(j).spacing_x,ROIs(j).yValues/ROIs(j).spacing_y);
            %To visualize this mask, overlay on top of the image
            h = impoly(gca, [xj, yj]);
            setVerticesDraggable(h,false);
            %setColor(h,'yellow');
            imcrop(roipoly(Y,ROIs(j).xValues/ROIs(j).spacing_x,ROIs(j).yValues/ROIs(j).spacing_y));
            imshow(BW);
            pause;
            close (1)
                        
        end
    end
    
   
end