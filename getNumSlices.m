function [numCT, numROIs] = getNumSlices(datasetDir, diseaseLabel)
%This function browses through all patient data and each CT volume and determine number of
%CT volumes and total number of ROIs that have the given diseaseLabel
%Example usage: [numCT, numROIs] = getNumSlices('./','healthy')

datasetDir = './'; %Assumes current working directory is the directory containing the database ILD_medgift 
diseaseLabel = 'fibrosis';%'micronodules';%'emphysema';%'consolidation';%'healthy';%'fibrosis';%'ground_glass';

%First recursively get all files ending with .txt. Those contain infomation on all ROIs
files = subdir(strcat(datasetDir, 'ILD_DB_txtROIs/*.txt')); 

numROIs = 0; %Total number of ROIs
numCT = 0; %Total number of CT volumes with the diseaseLabel
for i=1:109 %length(files) %109 %Explicitly using first 109 files (essentially disregarding HRCT_pilot directory) will give results that match table 5 in the paper .. mostly..
    ROIfileName = files(i).name;
    
    ROIs = loadROIfiles(ROIfileName);
    
    numROIsi = 0;
    for j = 1:numel(ROIs)
        numROIsi = numROIsi + strcmp(ROIs(j).label,diseaseLabel);
    end
    
    numROIs = numROIs + numROIsi;
    if numROIsi > 0 %If there is even a single roi with this label, increment numSlices
        numCT = numCT + 1;
    end   

end
