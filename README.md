** New additions **
- generateRCNNData
- lungClassifier


## GenerateRCNNData
### Input
This function takes two input arguments
- the dataset directory (if working from root of project it is './')
- the diseaseLabels specified as a cell array of char vectors for example diseaseLabels = {'fibrosis', 'ground_glass'}
### Output
This function first creates RGB images of dicom images with contain ROIs corresponding to diseaseLabels.
It returns the ground truth ROIs as cell array of size M x numel(diseaseLabels)
Modify the outer loop `for i=1:N` to increase or decrease the number of patients added to annotated_images

## lungClassifier
### Input
This function takes no input
### Output
This function creates an R-CNN from resnet-18 by modifying the last three layers. Then calls GenerateRCNNData
and trains the RCNN with the data returned from the GenerateRCNNData. It then returns the average precision with precision recall plot for each disease
 


Program designed to extract 2D .rgb patches from .dicom files

To Run:
RUN getROIpatches.m file in MATLAB/Octave(if set up properly)

Output:
Patches will be output into ./ILD_DB_patientROIpatches

Parameters:
Line 42: diseaseLabelArray
	Can be run using only one disease or multiple diseases.

Line 114 & 115: patchWidth, patchHeight
	Can be set to: 16, 32, 64. width and height should always be the same. 

Line 122: shiftVal:
	possible shifts: .25, .5, or 1.0.


Large DataSet parameter values:
(This Dataset provides the most even distribution of images, not the most possible images.)

Bronchiectasis:
	Input:  patchWidth & patchHeight: 16, shiftVal: .25
	Output: 499 patches

Consolidation: 
	Input:  patchWidth & patchHeight: 32, shiftVal: .25
	Output: 499 patches

Emphysema:
	Input:  patchWidth & patchHeight: 32, shiftVal: .25
	Output: 2706 patches

Fibrosis:
	Input:  patchWidth & patchHeight: 64, shiftVal: .25
	Output: 3383 patches

Ground Glass:
	Input:  patchWidth & patchHeight: 64, shiftVal: .25
	Output: 2355 patches

Healthy:
	Input:  patchWidth & patchHeight: 64, shiftVal: .25
	Output: 4353 patches

Macronodules:
	Input:  patchWidth & patchHeight: 16, shiftVal: .25
	Output: 2093 patches

Micronodules:
	Input:  patchWidth & patchHeight: 64, shiftVal: .5
	Output: 1714 patches

Reticulation:
	Input:  patchWidth & patchHeight: 32, shiftVal: .5
	Output: 1732




	

