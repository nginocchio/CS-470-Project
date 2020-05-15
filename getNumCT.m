function [numCT, numSlices] = getNumCT(datasetDir, diseaseLabels)
%This function browses through all patient data and each CT volume and determine number of
%slices and number of CT volumes (image series) that have the given diseaseLabels
%Example usage: [numCT, numSlices] = getNumCT('./',['healthy', 'fibrosis','ground_glass'])

datasetDir = './'; %Assumes current working directory is the directory containing the database ILD_medgift 
diseaseLabels = {'healthy', 'fibrosis','ground_glass','micronodules','emphysema'};%'micronodules';%'emphysema';%'consolidation';%'healthy';%'fibrosis';%'ground_glass';

%First recursively get all files ending with .txt. Those contain infomation on all ROIs
files = subdir(strcat(datasetDir, 'ILD_DB_txtROIs/*.txt')); 

numCT = 0;
numSlices = 0;

for i=1:109% length(files)%%Explicitly using first 109 files (essentially disregarding HRCT_pilot directory) will give results that match table 5 in the paper .. mostly..
    ROIfileName = files(i).name;
    
    ROIs = loadROIfiles(ROIfileName);
   
    mapObj = containers.Map('KeyType','int32','ValueType','int32');
    for j = 1:numel(ROIs)
        if sum(strcmp(ROIs(j).label,diseaseLabels)) > 0 %implies this ROI has atleast one of the disease labels
            %Add the corresponding slice to a "set" data structure?
            mapObj(ROIs(j).slice_number) = 1;
        end
    end

    numSlices = numSlices + mapObj.Count; 
    if mapObj.Count > 0 %If there is even a single roi with these label, increment numCT
        numCT = numCT + 1;
    end   

end
