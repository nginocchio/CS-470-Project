function generateDiseasePatches( )
%Function will call GeneratePatchesForDisease on each possible disease with given parameters


% If running script on a Windows Operating System set value to true
% Linux and Apple computers need to set value to false.
% This will make sure that new files are generated properly.
usingWindows = false;

% Function generates patches for each disease individually
diseaseLabel = 'bronchiectasis';
patchWidth = 16;
patchHeight = 16;
shiftVal = .25;

getPatchesForDisease( diseaseLabel, patchWidth, patchHeight, shiftVal, usingWindows );

diseaseLabel = 'consolidation';
patchWidth = 32;
patchHeight = 32;
shiftVal = .25;

getPatchesForDisease( diseaseLabel, patchWidth, patchHeight, shiftVal, usingWindows );

%NOT CURRENTLY GENERATING CYSTS DUE TO UNEVEN PATIENT DISTRIBUTION
%diseaseLabel = 'cysts';
%patchWidth = 16;
%patchHeight = 16;
%shiftVal = .25;

%getPatchesForDisease( diseaseLabel, patchWidth, patchHeight, shiftVal, usingWindows );

diseaseLabel = 'emphysema';
patchWidth = 32;
patchHeight = 32;
shiftVal = .25;

getPatchesForDisease( diseaseLabel, patchWidth, patchHeight, shiftVal, usingWindows );

diseaseLabel = 'fibrosis';
patchWidth = 64;
patchHeight = 64;
shiftVal = .25;

getPatchesForDisease( diseaseLabel, patchWidth, patchHeight, shiftVal, usingWindows );

diseaseLabel = 'ground_glass';
patchWidth = 64;
patchHeight = 64;
shiftVal = .25;

getPatchesForDisease( diseaseLabel, patchWidth, patchHeight, shiftVal, usingWindows );

diseaseLabel = 'healthy';
patchWidth = 64;
patchHeight = 64;
shiftVal = .25;

getPatchesForDisease( diseaseLabel, patchWidth, patchHeight, shiftVal, usingWindows );

diseaseLabel = 'macronodules';
patchWidth = 16;
patchHeight = 16;
shiftVal = .25;

getPatchesForDisease( diseaseLabel, patchWidth, patchHeight, shiftVal, usingWindows );

diseaseLabel = 'micronodules';
patchWidth = 64;
patchHeight = 64;
shiftVal = .5;

getPatchesForDisease( diseaseLabel, patchWidth, patchHeight, shiftVal, usingWindows );

diseaseLabel = 'reticulation';
patchWidth = 32;
patchHeight = 32;
shiftVal = .5;

getPatchesForDisease( diseaseLabel, patchWidth, patchHeight, shiftVal, usingWindows );

