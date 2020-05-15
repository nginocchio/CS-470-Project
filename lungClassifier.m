net = resnet18;

diseaseLabels = {'fibrosis', 'ground_glass'};
labelNames = ['imageFileNames', diseaseLabels];

numClasses = numel(diseaseLabels) + 1;
lgraph = layerGraph(net);
% Remove the the last 3 layers. 
layersToRemove = {
    'fc1000'
    'prob'
    'ClassificationLayer_predictions'
    };

lgraph = removeLayers(lgraph, layersToRemove);

% % Define new classfication layers
newLayers = [
    fullyConnectedLayer(numClasses, 'Name', 'rcnnFC')
    softmaxLayer('Name', 'rcnnSoftmax')
    classificationLayer('Name', 'rcnnClassification')
    ];

% % Add new layers
lgraph = addLayers(lgraph, newLayers);

% % Connect the new layers to the network. 
lgraph = connectLayers(lgraph, 'pool5', 'rcnnFC');
%% 


options = trainingOptions('sgdm', ...
'MiniBatchSize', 128, ...
'InitialLearnRate', 1e-3, ...
'LearnRateDropFactor',0.2, ...
'LearnRateDropPeriod', 5, ...
'MaxEpochs', 15, ...
'ExecutionEnvironment', 'gpu');

gTruth = generateRCNNData('./', diseaseLabels);


% Use this data to cross validate
allPatients = dir('annotated_images\');
patientFolders = allPatients([allPatients(:).isdir] == 1);
patientFolders = patientFolders(~ismember({patientFolders(:).name}, {'.','..'}));
patientFolders = [{patientFolders.name}];

imageFiles = gTruth(:,1);
precisionScores = cell(length(patientFolders), 1);
for i=1:length(patientFolders)
    patientPrecision = {};
    patientFolder = patientFolders{i};
    testData = {};
    trainData = {};
    for j=1:length(gTruth(:,1))
        curFile = imageFiles{j};
        splitFile = split(curFile, '\');
        patientNum = splitFile{3};
        
        if strcmp(patientNum, patientFolder)
            testData = [testData; gTruth(j,:)];
        else
            trainData = [trainData;gTruth(j,:)];
        end
    end
    
    trainDataTable = cell2table(trainData);
    trainDataTable.Properties.VariableNames = labelNames;

    
    % Train an R-CNN object detector. This will take several minutes.    
    rcnn = trainRCNNObjectDetector(trainDataTable, lgraph, options, ...
    'NegativeOverlapRange', [0 0.3], 'PositiveOverlapRange',[0.4 1])

    patientBBoxes = [];
    patientLabels = [];
    patientScore = {};
    patientGTruth = {};

    [sz, ~] = size(testData);
    seenFiles = [];
    for k=1:sz
        testFile = testData{k, 1};
        lastFile = convertCharsToStrings(testFile);
        if isempty(seenFiles)
            seenFiles = [seenFiles; lastFile];
        elseif ~contains(seenFiles, lastFile)
            seenFiles = [seenFiles; lastFile];
        else
            continue
        end
        RGB = imread(testFile);
        [bboxes, score, label] = detect(rcnn, RGB, 'MiniBatchSize', 128, "ExecutionEnvironment","gpu");
        
        % find all files with image name testFile
        isMatch = strfind(testData(:, 1), testFile);
        matchedIdxs = find(not(cellfun('isempty', isMatch)));
        
        groundTruthBoxes = {};
        for ii=1:numel(matchedIdxs)
            dataIdx = matchedIdxs(ii);
            for jj=2:numel(labelNames)
                if isempty(testData{dataIdx, jj})
                    continue
                else
                    newEntry = cell(1, numel(diseaseLabels));
                    newEntry{1, jj - 1} = testData{dataIdx, jj};
                    groundTruthBoxes = [groundTruthBoxes; newEntry];
                end
            end
        end

        preds = num2cell(bboxes, 2);
        categoryLabels = cell(numel(label), 1);
        for ii = 1:numel(label)
            categoryLabels{ii} = categorical(label(ii), diseaseLabels);
        end
        
        patientBBoxes = [patientBBoxes; preds];
        patientLabels = [patientLabels; categoryLabels];
        patientScore = [patientScore; num2cell(score)];
        patientGTruth = [patientGTruth; groundTruthBoxes];
        

%         % Display predicted ROIs and display Ground Truth ROIs
%         %-----------------------------------------------------
%         if ~isempty(score)
%             
%             labels_str = cell(numel(score, 1));
%             for z=1:numel(score)
%                 labels_str{z} = [sprintf('%s: (Confidence = %f)', label(z), score(z))];
%             end
%             outputImage = insertObjectAnnotation(RGB, 'rectangle', [bboxes], labels_str, 'Color', 'cyan');
%             figure
%             imshow(outputImage)
%                     
%             gTruthbbox = [];
%             gTruthAnnotation = {};
%             sz = size(groundTruthBoxes, 1)
%             for ii=1:sz
%                 for j=1:size(diseaseLabels, 2)
%                     if ~isempty(groundTruthBoxes{ii, j})
%                         gTruthbbox = [gTruthbbox; groundTruthBoxes{ii, j}];
%                         gTruthAnnotation = [gTruthAnnotation; diseaseLabels{j}];
%                     end
%                 end
%             end
%             
%             groundTruthImage = insertObjectAnnotation(RGB, 'rectangle', gTruthbbox, gTruthAnnotation, 'Color', 'green');
%             figure
%             imshow(groundTruthImage)
%             pause(1);
%             
%         end
        %-----------------------------------------------------
                
        
    end
    
%     change groundTruthTable to number of corresponding diseaseLabels
    groundTruthTable = table(patientGTruth(:, 1), patientGTruth(:, 2));
    groundTruthTable.Properties.VariableNames = diseaseLabels;
    
    predsTable = table(patientBBoxes, patientScore, patientLabels);

    tableHeightDiff = abs(height(predsTable) - height(groundTruthTable));
    
    if height(predsTable) < height(groundTruthTable)
        newCell = cell(1, 3);
        newCells = repmat(newCell, tableHeightDiff, 1);
        predsTable = [predsTable; newCells];
    else
        newCell = cell(1, numel(diseaseLabels));
        newCells = repmat(newCell, tableHeightDiff, 1);
        groundTruthTable = [groundTruthTable; newCells];
    end
        
    [averagePrecision,recall,precision] = evaluateDetectionPrecision(predsTable, groundTruthTable, 0.2)
    
    for jj=1:numel(diseaseLabels)
        currPrecision = precision{jj};
        currRecall = recall{jj};
        currAvgPrecision = averagePrecision(jj);
        figure
        xlim([0 1]);
        ylim([0 1]);
        xlabel('Precision');
        ylabel('Recall')
        plot(currPrecision, currRecall)
        title(sprintf('%s Average Precision = %.1f',diseaseLabels{jj}, currAvgPrecision))
%         tic,pause(1),toc;
    end
    
end