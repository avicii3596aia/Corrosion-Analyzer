classdef CorrosionAnalyzerApp < handle

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        
        % Left Panel Components
        LeftPanel                   matlab.ui.container.Panel
        SelectFilesButton           matlab.ui.control.Button
        ParametersPanel             matlab.ui.container.Panel
        CircleRadiusMinSpinner      matlab.ui.control.Spinner
        CircleRadiusMaxSpinner      matlab.ui.control.Spinner
        SensitivitySpinner          matlab.ui.control.Spinner
        RGBMinEditField             matlab.ui.control.EditField
        RGBMaxEditField             matlab.ui.control.EditField
        RGBFactorEditField          matlab.ui.control.EditField
        AutoDetectRGBButton         matlab.ui.control.Button
        RGBPreviewButton            matlab.ui.control.Button
        InnerDiameterRatioSpinner   matlab.ui.control.Spinner
        CircleSelectionDropDown     matlab.ui.control.DropDown
        
        ProcessImagesButton         matlab.ui.control.Button
        ExportResultsButton         matlab.ui.control.Button
        ProgressGauge               matlab.ui.control.LinearGauge
        
        % Group Information Panel
        GroupInfoPanel              matlab.ui.container.Panel
        GroupTable                  matlab.ui.control.Table
        EditGroupsButton            matlab.ui.control.Button
        AddGroupButton              matlab.ui.control.Button
        DeleteGroupButton           matlab.ui.control.Button
        ResetGroupsButton           matlab.ui.control.Button
        
        % Right Panel Components
        RightPanel                  matlab.ui.container.Panel
        ResultsAxes                 matlab.ui.control.UIAxes
        ImageAxes                   matlab.ui.control.UIAxes
        ImageNavigationPanel        matlab.ui.container.Panel
        PrevImageButton             matlab.ui.control.Button
        NextImageButton             matlab.ui.control.Button
        ImageIndexSpinner           matlab.ui.control.Spinner
        ViewModeDropDown            matlab.ui.control.DropDown
        LogTextArea                 matlab.ui.control.TextArea
        CurrentImageIndex           double
    end
    
    properties (Access = private)
        ImageFiles                  % Selected image files
        ImageDirectory              % Directory containing images
        Results                     % Analysis results
        EnvironmentGroups           % Environment group definitions
    end
    
    % Constructor and main methods
    methods (Access = public)
        function app = CorrosionAnalyzerApp
            createComponents(app);
            if nargout == 0
                clear app
            end
        end
        
        function delete(app)
            delete(app.UIFigure);
        end
    end
    
    % UI Creation methods
    methods (Access = private)
        function createComponents(app)
            % Create UIFigure and components
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1200 800];
            app.UIFigure.Name = 'Advanced Corrosion Analysis Tool';
            
            % Create left panel
            app.LeftPanel = uipanel(app.UIFigure);
            app.LeftPanel.Title = 'Control Panel';
            app.LeftPanel.Position = [10 10 380 780];
            
            % Create right panel
            app.RightPanel = uipanel(app.UIFigure);
            app.RightPanel.Title = 'Results & Visualization';
            app.RightPanel.Position = [400 10 790 780];
            
            % Create left panel components
            createLeftPanelComponents(app);
            
            % Create right panel components
            createRightPanelComponents(app);
            
            % Initialize environment groups
            initializeEnvironmentGroups(app);
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
        
        function createLeftPanelComponents(app)
            yPos = 720;
            spacing = 40;
            
            % File selection button
            app.SelectFilesButton = uibutton(app.LeftPanel, 'push');
            app.SelectFilesButton.ButtonPushedFcn = @(~,~) SelectFilesButtonPushed(app);
            app.SelectFilesButton.Text = 'Select Image Directory';
            app.SelectFilesButton.FontWeight = 'bold';
            app.SelectFilesButton.BackgroundColor = [0.2 0.6 1];
            app.SelectFilesButton.FontColor = [1 1 1];
            app.SelectFilesButton.Position = [10 yPos 350 30];
            yPos = yPos - spacing - 20;
            
            % Parameters panel
            app.ParametersPanel = uipanel(app.LeftPanel);
            app.ParametersPanel.Title = 'Analysis Parameters';
            app.ParametersPanel.Position = [10 yPos-260 350 260];
            
            createParametersPanel(app);
            yPos = yPos - 280;
            
            % Group information panel
            app.GroupInfoPanel = uipanel(app.LeftPanel);
            app.GroupInfoPanel.Title = 'Environment Groups';
            app.GroupInfoPanel.Position = [10 yPos-200 350 200];
            
            createGroupInfoPanel(app);
            yPos = yPos - 220;
            
            % Process button
            app.ProcessImagesButton = uibutton(app.LeftPanel, 'push');
            app.ProcessImagesButton.ButtonPushedFcn = @(~,~) ProcessImagesButtonPushed(app);
            app.ProcessImagesButton.Text = 'Process Images';
            app.ProcessImagesButton.FontWeight = 'bold';
            app.ProcessImagesButton.BackgroundColor = [0.2 0.8 0.2];
            app.ProcessImagesButton.FontColor = [1 1 1];
            app.ProcessImagesButton.Enable = 'off';
            app.ProcessImagesButton.Position = [10 yPos 350 30];
            yPos = yPos - spacing;
            
            % Progress gauge
            app.ProgressGauge = uigauge(app.LeftPanel, 'linear');
            app.ProgressGauge.Limits = [0 100];
            app.ProgressGauge.Position = [10 yPos 350 20];
            yPos = yPos - spacing;
            
            % Export button
            app.ExportResultsButton = uibutton(app.LeftPanel, 'push');
            app.ExportResultsButton.ButtonPushedFcn = @(~,~) ExportResultsButtonPushed(app);
            app.ExportResultsButton.Text = 'Export Results';
            app.ExportResultsButton.FontWeight = 'bold';
            app.ExportResultsButton.BackgroundColor = [0.8 0.4 0.0];
            app.ExportResultsButton.FontColor = [1 1 1];
            app.ExportResultsButton.Enable = 'off';
            app.ExportResultsButton.Position = [10 yPos 350 30];
        end
        
        function createParametersPanel(app)
            yPos = 200;
            spacing = 22;
            
            % Circle detection parameters
            uilabel(app.ParametersPanel, 'Text', 'Circle Radius Min:', 'Position', [10 yPos 120 20]);
            app.CircleRadiusMinSpinner = uispinner(app.ParametersPanel);
            app.CircleRadiusMinSpinner.Limits = [50 500];
            app.CircleRadiusMinSpinner.Value = 245;
            app.CircleRadiusMinSpinner.Position = [140 yPos 80 20];
            yPos = yPos - spacing;
            
            uilabel(app.ParametersPanel, 'Text', 'Circle Radius Max:', 'Position', [10 yPos 120 20]);
            app.CircleRadiusMaxSpinner = uispinner(app.ParametersPanel);
            app.CircleRadiusMaxSpinner.Limits = [100 800];
            app.CircleRadiusMaxSpinner.Value = 295;
            app.CircleRadiusMaxSpinner.Position = [140 yPos 80 20];
            yPos = yPos - spacing;
            
            uilabel(app.ParametersPanel, 'Text', 'Sensitivity:', 'Position', [10 yPos 120 20]);
            app.SensitivitySpinner = uispinner(app.ParametersPanel);
            app.SensitivitySpinner.Limits = [0.1 1.0];
            app.SensitivitySpinner.Step = 0.001;
            app.SensitivitySpinner.Value = 0.989;
            app.SensitivitySpinner.Position = [140 yPos 80 20];
            yPos = yPos - spacing;
            
            % Inner diameter ratio
            uilabel(app.ParametersPanel, 'Text', 'Inner/Outer Ratio:', 'Position', [10 yPos 120 20]);
            app.InnerDiameterRatioSpinner = uispinner(app.ParametersPanel);
            app.InnerDiameterRatioSpinner.Limits = [0.1 0.9];
            app.InnerDiameterRatioSpinner.Step = 0.01;
            app.InnerDiameterRatioSpinner.Value = 0.525; % 10.5/20
            app.InnerDiameterRatioSpinner.Position = [140 yPos 80 20];
            yPos = yPos - spacing;
            
            % Circle selection strategy
            uilabel(app.ParametersPanel, 'Text', 'Multiple Circles:', 'Position', [10 yPos 120 20]);
            app.CircleSelectionDropDown = uidropdown(app.ParametersPanel);
            app.CircleSelectionDropDown.Items = {'Use Largest', 'Use All', 'Use First'};
            app.CircleSelectionDropDown.Value = 'Use Largest';
            app.CircleSelectionDropDown.Position = [140 yPos 120 20];
            yPos = yPos - spacing;
            
            % Auto-detect RGB button
            app.AutoDetectRGBButton = uibutton(app.ParametersPanel, 'push');
            app.AutoDetectRGBButton.Text = 'Auto-Detect RGB Range';
            app.AutoDetectRGBButton.Position = [10 yPos 210 20];
            app.AutoDetectRGBButton.ButtonPushedFcn = @(~,~) autoDetectRGBRange(app);
            app.AutoDetectRGBButton.BackgroundColor = [0.9 0.7 0.2];
            app.AutoDetectRGBButton.Enable = 'off';
            yPos = yPos - spacing;
            
            % RGB parameters
            uilabel(app.ParametersPanel, 'Text', 'RGB Min [R,G,B]:', 'Position', [10 yPos 120 20]);
            app.RGBMinEditField = uieditfield(app.ParametersPanel, 'text');
            app.RGBMinEditField.Value = '[65, 35, 0]';
            app.RGBMinEditField.Position = [140 yPos 180 20];
            yPos = yPos - spacing;
            
            uilabel(app.ParametersPanel, 'Text', 'RGB Max [R,G,B]:', 'Position', [10 yPos 120 20]);
            app.RGBMaxEditField = uieditfield(app.ParametersPanel, 'text');
            app.RGBMaxEditField.Value = '[170, 120, 25]';
            app.RGBMaxEditField.Position = [140 yPos 180 20];
            yPos = yPos - spacing;
            
            uilabel(app.ParametersPanel, 'Text', 'RGB Factor [R,G,B]:', 'Position', [10 yPos 120 20]);
            app.RGBFactorEditField = uieditfield(app.ParametersPanel, 'text');
            app.RGBFactorEditField.Value = '[0.55, 0.35, 0.10]';
            app.RGBFactorEditField.Position = [140 yPos 180 20];
            yPos = yPos - spacing;
            
            % Preview RGB button
            app.RGBPreviewButton = uibutton(app.ParametersPanel, 'push');
            app.RGBPreviewButton.Text = 'Preview RGB Detection';
            app.RGBPreviewButton.Position = [10 yPos 210 20];
            app.RGBPreviewButton.ButtonPushedFcn = @(~,~) previewRGBDetection(app);
            app.RGBPreviewButton.BackgroundColor = [0.7 0.9 0.7];
            app.RGBPreviewButton.Enable = 'off';
        end
        
        function createGroupInfoPanel(app)
            app.GroupTable = uitable(app.GroupInfoPanel);
            app.GroupTable.Position = [10 50 330 130];
            app.GroupTable.ColumnName = {'Environment', 'Range', 'Count'};
            app.GroupTable.ColumnWidth = {200, 60, 60};
            app.GroupTable.ColumnEditable = [true, true, false]; % Make editable
            app.GroupTable.CellEditCallback = @(~,~) updateGroupCounts(app);
            
            % Group management buttons
            app.EditGroupsButton = uibutton(app.GroupInfoPanel, 'push');
            app.EditGroupsButton.Text = 'Edit Groups';
            app.EditGroupsButton.Position = [10 20 75 25];
            app.EditGroupsButton.ButtonPushedFcn = @(~,~) editGroupsDialog(app);
            app.EditGroupsButton.BackgroundColor = [0.3 0.7 1.0];
            app.EditGroupsButton.FontColor = [1 1 1];
            
            app.AddGroupButton = uibutton(app.GroupInfoPanel, 'push');
            app.AddGroupButton.Text = '+ Add';
            app.AddGroupButton.Position = [90 20 60 25];
            app.AddGroupButton.ButtonPushedFcn = @(~,~) addNewGroup(app);
            app.AddGroupButton.BackgroundColor = [0.2 0.8 0.2];
            app.AddGroupButton.FontColor = [1 1 1];
            
            app.DeleteGroupButton = uibutton(app.GroupInfoPanel, 'push');
            app.DeleteGroupButton.Text = 'Delete';
            app.DeleteGroupButton.Position = [155 20 60 25];
            app.DeleteGroupButton.ButtonPushedFcn = @(~,~) deleteSelectedGroup(app);
            app.DeleteGroupButton.BackgroundColor = [0.9 0.3 0.3];
            app.DeleteGroupButton.FontColor = [1 1 1];
            
            app.ResetGroupsButton = uibutton(app.GroupInfoPanel, 'push');
            app.ResetGroupsButton.Text = 'Reset';
            app.ResetGroupsButton.Position = [220 20 60 25];
            app.ResetGroupsButton.ButtonPushedFcn = @(~,~) resetToDefaultGroups(app);
            app.ResetGroupsButton.BackgroundColor = [0.7 0.7 0.7];
        end
        
        function createRightPanelComponents(app)
            % Image axes (top half)
            app.ImageAxes = uiaxes(app.RightPanel);
            app.ImageAxes.Position = [20 450 370 320];
            title(app.ImageAxes, 'Image Analysis View');
            
            % Results axes (top right)
            app.ResultsAxes = uiaxes(app.RightPanel);
            app.ResultsAxes.Position = [400 450 370 320];
            title(app.ResultsAxes, 'Analysis Results');
            
            % Image navigation panel
            app.ImageNavigationPanel = uipanel(app.RightPanel);
            app.ImageNavigationPanel.Title = 'Image Navigation & View';
            app.ImageNavigationPanel.Position = [20 380 750 60];
            
            % Navigation controls
            app.PrevImageButton = uibutton(app.ImageNavigationPanel, 'push');
            app.PrevImageButton.Text = '← Previous';
            app.PrevImageButton.Position = [10 10 80 30];
            app.PrevImageButton.ButtonPushedFcn = @(~,~) showPreviousImage(app);
            app.PrevImageButton.Enable = 'off';
            
            uilabel(app.ImageNavigationPanel, 'Text', 'Image:', 'Position', [100 15 40 20]);
            
            app.ImageIndexSpinner = uispinner(app.ImageNavigationPanel);
            app.ImageIndexSpinner.Position = [150 10 60 30];
            app.ImageIndexSpinner.Limits = [1 100];  % Initial valid limits
            app.ImageIndexSpinner.Value = 1;
            app.ImageIndexSpinner.ValueChangedFcn = @(~,~) showSelectedImage(app);
            app.ImageIndexSpinner.Enable = 'off';
            
            app.NextImageButton = uibutton(app.ImageNavigationPanel, 'push');
            app.NextImageButton.Text = 'Next →';
            app.NextImageButton.Position = [220 10 80 30];
            app.NextImageButton.ButtonPushedFcn = @(~,~) showNextImage(app);
            app.NextImageButton.Enable = 'off';
            
            uilabel(app.ImageNavigationPanel, 'Text', 'View Mode:', 'Position', [320 15 70 20]);
            
            app.ViewModeDropDown = uidropdown(app.ImageNavigationPanel);
            app.ViewModeDropDown.Items = {'Original', 'With Circles', 'Corrosion Mask', 'Combined View'};
            app.ViewModeDropDown.Value = 'Combined View';
            app.ViewModeDropDown.Position = [400 10 120 30];
            app.ViewModeDropDown.ValueChangedFcn = @(~,~) updateImageDisplay(app);
            app.ViewModeDropDown.Enable = 'off';
            
            % Log text area (bottom half)
            app.LogTextArea = uitextarea(app.RightPanel);
            app.LogTextArea.Position = [20 20 750 350];
            app.LogTextArea.Value = {'Corrosion Analysis Tool Initialized', 'Select image directory to begin...'};
            app.LogTextArea.Editable = 'off';
            
            % Initialize current image index
            app.CurrentImageIndex = 1;
        end
        
        function initializeEnvironmentGroups(app)
            app.EnvironmentGroups = {
                'Sterilized seawater', '1-4', 0;
                'Sterilized seawater + B.S.', '5-8', 0;
                'Sterilized seawater + B.S.+ Glyc', '9-12', 0;
                'Seawater', '13-16', 0;
                'Seawater + B.S.', '17-20', 0;
                'Seawater + B.S.+ Glyc', '21-24', 0;
                'Seawater without light', '25-28', 0;
                'Seawater without light + B.S.', '29+', 0;
            };
            app.GroupTable.Data = app.EnvironmentGroups;
        end
    end
    
    % Group management methods
    methods (Access = private)
        function editGroupsDialog(app)
            % Create a dialog for editing all groups at once
            d = uifigure('Position', [300 300 500 400], 'Name', 'Edit Environment Groups');
            
            % Instructions
            uilabel(d, 'Position', [20 360 460 20], ...
                'Text', 'Edit group names and ranges. Use formats like "1-4", "5-8", "15+", etc.');
            
            % Create editable table
            editTable = uitable(d, 'Position', [20 60 460 290]);
            editTable.ColumnName = {'Environment Name', 'Number Range'};
            editTable.ColumnWidth = {300, 140};
            editTable.ColumnEditable = [true, true];
            
            % Prepare data (exclude count column)
            editData = cell(size(app.EnvironmentGroups, 1), 2);
            for i = 1:size(app.EnvironmentGroups, 1)
                editData{i, 1} = app.EnvironmentGroups{i, 1};
                editData{i, 2} = app.EnvironmentGroups{i, 2};
            end
            editTable.Data = editData;
            
            % Buttons
            saveBtn = uibutton(d, 'push', 'Position', [300 20 80 30], 'Text', 'Save');
            cancelBtn = uibutton(d, 'push', 'Position', [390 20 80 30], 'Text', 'Cancel');
            
            saveBtn.ButtonPushedFcn = @(~,~) saveGroupChanges();
            cancelBtn.ButtonPushedFcn = @(~,~) close(d);
            
            function saveGroupChanges()
                try
                    newData = editTable.Data;
                    % Validate and update groups
                    for i = 1:size(newData, 1)
                        if isempty(newData{i, 1}) || isempty(newData{i, 2})
                            uialert(d, 'All fields must be filled.', 'Validation Error');
                            return;
                        end
                    end
                    
                    % Update the groups
                    app.EnvironmentGroups = cell(size(newData, 1), 3);
                    for i = 1:size(newData, 1)
                        app.EnvironmentGroups{i, 1} = newData{i, 1};
                        app.EnvironmentGroups{i, 2} = newData{i, 2};
                        app.EnvironmentGroups{i, 3} = 0; % Reset count
                    end
                    
                    updateGroupCounts(app);
                    logMessage(app, 'Environment groups updated successfully');
                    close(d);
                    
                catch ME
                    uialert(d, ['Error saving groups: ' ME.message], 'Save Error');
                end
            end
        end
        
        function addNewGroup(app)
            % Add a new group
            groupName = inputdlg({'Enter group name:', 'Enter number range (e.g., "25-30"):'}, ...
                'Add New Group', 1, {'New Environment', '1-5'});
            
            if ~isempty(groupName)
                newRow = {groupName{1}, groupName{2}, 0};
                app.EnvironmentGroups = [app.EnvironmentGroups; newRow];
                updateGroupCounts(app);
                logMessage(app, sprintf('Added new group: %s (%s)', groupName{1}, groupName{2}));
            end
        end
        
        function deleteSelectedGroup(app)
            % Get selected row (basic implementation)
            if size(app.EnvironmentGroups, 1) <= 1
                uialert(app.UIFigure, 'Cannot delete the last group.', 'Delete Error');
                return;
            end
            
            selection = listdlg('PromptString', 'Select group to delete:', ...
                'SelectionMode', 'single', ...
                'ListString', app.EnvironmentGroups(:, 1));
            
            if ~isempty(selection)
                groupName = app.EnvironmentGroups{selection, 1};
                app.EnvironmentGroups(selection, :) = [];
                updateGroupCounts(app);
                logMessage(app, sprintf('Deleted group: %s', groupName));
            end
        end
        
        function resetToDefaultGroups(app)
            % Reset to original default groups
            response = uiconfirm(app.UIFigure, ...
                'This will reset all groups to default. Continue?', ...
                'Reset Groups', 'Options', {'Yes', 'No'});
            
            if strcmp(response, 'Yes')
                initializeEnvironmentGroups(app);
                updateGroupCounts(app);
                logMessage(app, 'Environment groups reset to defaults');
            end
        end
        
        function environment = getEnvironment(app, carbonSteelNumber)
            % Dynamic environment detection based on current groups
            num = str2double(carbonSteelNumber);
            if isnan(num)
                environment = 'Unknown';
                return;
            end
            
            % Check each group's range
            for i = 1:size(app.EnvironmentGroups, 1)
                rangeStr = app.EnvironmentGroups{i, 2};
                if isInRange(app, num, rangeStr)
                    environment = app.EnvironmentGroups{i, 1};
                    return;
                end
            end
            
            % If no match found
            environment = 'Unknown';
        end
        
        function inRange = isInRange(app, num, rangeStr)
            % Parse range string and check if number is in range
            inRange = false;
            rangeStr = strtrim(rangeStr);
            
            if contains(rangeStr, '+')
                % Handle "25+" format
                minVal = str2double(strrep(rangeStr, '+', ''));
                inRange = num >= minVal;
            elseif contains(rangeStr, '-')
                % Handle "1-4" format
                parts = split(rangeStr, '-');
                if length(parts) == 2
                    minVal = str2double(parts{1});
                    maxVal = str2double(parts{2});
                    inRange = num >= minVal && num <= maxVal;
                end
            else
                % Handle single number
                targetVal = str2double(rangeStr);
                inRange = num == targetVal;
            end
        end
    end
    
    % Utility methods  
    methods (Access = private)
        function logMessage(app, message)
            currentLog = app.LogTextArea.Value;
            timestamp = datestr(now, 'HH:MM:SS');
            newMessage = sprintf('[%s] %s', timestamp, message);
            app.LogTextArea.Value = [currentLog; {newMessage}];
            drawnow;
        end
        
        function updateGroupCounts(app)
            % Reset counts
            for i = 1:size(app.EnvironmentGroups, 1)
                app.EnvironmentGroups{i, 3} = 0;
            end
            
            % Count files in each group
            if ~isempty(app.ImageFiles)
                for i = 1:length(app.ImageFiles)
                    filename = app.ImageFiles(i).name;
                    carbonSteelNumber = regexp(filename, '\d+', 'match', 'once');
                    if ~isempty(carbonSteelNumber)
                        environment = getEnvironment(app, carbonSteelNumber);
                        
                        % Find and increment count
                        for j = 1:size(app.EnvironmentGroups, 1)
                            if strcmpi(app.EnvironmentGroups{j, 1}, environment)
                                app.EnvironmentGroups{j, 3} = app.EnvironmentGroups{j, 3} + 1;
                                break;
                            end
                        end
                    end
                end
                
                % Enable navigation controls and set proper limits
                numFiles = length(app.ImageFiles);
                app.ImageIndexSpinner.Limits = [1 max(1, numFiles)];  % Ensure valid limits
                app.ImageIndexSpinner.Enable = 'on';
                app.PrevImageButton.Enable = 'on';
                app.NextImageButton.Enable = 'on';
                app.ViewModeDropDown.Enable = 'on';
                app.AutoDetectRGBButton.Enable = 'on';
                app.RGBPreviewButton.Enable = 'on';
                app.CurrentImageIndex = 1;
                app.ImageIndexSpinner.Value = 1;
            end
            
            app.GroupTable.Data = app.EnvironmentGroups;
        end
    end
    
    % Image navigation and display methods
    methods (Access = private)
        function showPreviousImage(app)
            if isempty(app.ImageFiles) || app.CurrentImageIndex <= 1
                return;
            end
            
            app.CurrentImageIndex = app.CurrentImageIndex - 1;
            app.ImageIndexSpinner.Value = app.CurrentImageIndex;
            updateImageDisplay(app);
        end
        
        function showNextImage(app)
            if isempty(app.ImageFiles) || app.CurrentImageIndex >= length(app.ImageFiles)
                return;
            end
            
            app.CurrentImageIndex = app.CurrentImageIndex + 1;
            app.ImageIndexSpinner.Value = app.CurrentImageIndex;
            updateImageDisplay(app);
        end
        
        function showSelectedImage(app)
            if isempty(app.ImageFiles)
                return;
            end
            
            % Ensure the value is within bounds
            maxImages = length(app.ImageFiles);
            app.CurrentImageIndex = max(1, min(app.ImageIndexSpinner.Value, maxImages));
            app.ImageIndexSpinner.Value = app.CurrentImageIndex;  % Update spinner to corrected value
            updateImageDisplay(app);
        end
        
        function updateImageDisplay(app)
            if isempty(app.ImageFiles)
                return;
            end
            
            cla(app.ImageAxes);
            
            % Check if we have processed results for this image
            if ~isempty(app.Results) && app.CurrentImageIndex <= length(app.Results)
                result = app.Results(app.CurrentImageIndex);
                if result.success && isfield(result, 'visualizationData')
                    showProcessedImage(app, result);
                else
                    showOriginalImage(app);
                end
            else
                showOriginalImage(app);
            end
        end
        
        function showOriginalImage(app)
            % Show original image for current index
            if app.CurrentImageIndex <= length(app.ImageFiles)
                filename = app.ImageFiles(app.CurrentImageIndex).name;
                fullImagePath = fullfile(app.ImageDirectory, filename);
                
                try
                    rgb = imread(fullImagePath);
                    imshow(rgb, 'Parent', app.ImageAxes);
                    title(app.ImageAxes, sprintf('Original: %s', filename), 'Interpreter', 'none');
                catch
                    title(app.ImageAxes, 'Error loading image');
                end
            end
        end
        
        function showProcessedImage(app, result)
            viewMode = app.ViewModeDropDown.Value;
            vizData = result.visualizationData;
            
            switch viewMode
                case 'Original'
                    imshow(vizData.originalImage, 'Parent', app.ImageAxes);
                    title(app.ImageAxes, sprintf('Original: %s', result.filename), 'Interpreter', 'none');
                    
                case 'With Circles'
                    imshow(vizData.originalImage, 'Parent', app.ImageAxes);
                    hold(app.ImageAxes, 'on');
                    
                    % Draw circles
                    if ~isempty(vizData.d_centers)
                        for i = 1:size(vizData.d_centers, 1)
                            % Outer circle (blue)
                            theta = 0:0.1:2*pi;
                            x_outer = vizData.d_centers(i,1) + vizData.d_radii(i) * cos(theta);
                            y_outer = vizData.d_centers(i,2) + vizData.d_radii(i) * sin(theta);
                            plot(app.ImageAxes, x_outer, y_outer, 'b-', 'LineWidth', 2);
                            
                            % Inner circle (red)
                            x_inner = vizData.b_centers(i,1) + vizData.b_radii(i) * cos(theta);
                            y_inner = vizData.b_centers(i,2) + vizData.b_radii(i) * sin(theta);
                            plot(app.ImageAxes, x_inner, y_inner, 'r-', 'LineWidth', 2);
                        end
                    end
                    hold(app.ImageAxes, 'off');
                    title(app.ImageAxes, sprintf('Detected Circles: %s', result.filename), 'Interpreter', 'none');
                    
                case 'Corrosion Mask'
                    % Show corrosion areas in red overlay
                    overlayImage = vizData.originalImage;
                    overlayImage(:,:,1) = overlayImage(:,:,1) + uint8(vizData.corrosion_mask * 100);
                    imshow(overlayImage, 'Parent', app.ImageAxes);
                    title(app.ImageAxes, sprintf('Corrosion Areas (%.2f%%): %s', result.corrosionRatio, result.filename), 'Interpreter', 'none');
                    
                case 'Combined View'
                    imshow(vizData.originalImage, 'Parent', app.ImageAxes);
                    hold(app.ImageAxes, 'on');
                    
                    % Draw circles
                    if ~isempty(vizData.d_centers)
                        for i = 1:size(vizData.d_centers, 1)
                            theta = 0:0.1:2*pi;
                            x_outer = vizData.d_centers(i,1) + vizData.d_radii(i) * cos(theta);
                            y_outer = vizData.d_centers(i,2) + vizData.d_radii(i) * sin(theta);
                            plot(app.ImageAxes, x_outer, y_outer, 'b-', 'LineWidth', 2);
                            
                            x_inner = vizData.b_centers(i,1) + vizData.b_radii(i) * cos(theta);
                            y_inner = vizData.b_centers(i,2) + vizData.b_radii(i) * sin(theta);
                            plot(app.ImageAxes, x_inner, y_inner, 'r-', 'LineWidth', 1);
                        end
                    end
                    
                    % Show corrosion areas
                    [corr_y, corr_x] = find(vizData.corrosion_mask);
                    if ~isempty(corr_x)
                        scatter(app.ImageAxes, corr_x, corr_y, 1, 'y', 'filled', 'MarkerFaceAlpha', 0.6);
                    end
                    
                    hold(app.ImageAxes, 'off');
                    title(app.ImageAxes, sprintf('Analysis Result (%.2f%%): %s', result.corrosionRatio, result.filename), 'Interpreter', 'none');
            end
        end
    end
    
    % Image processing methods
    methods (Access = private)
        function result = processImage(app, imageFile, params)
            try
                % Read image
                fullImagePath = fullfile(app.ImageDirectory, imageFile.name);
                rgb = imread(fullImagePath);
                
                % Convert to grayscale and detect edges
                grayImage = rgb2gray(rgb);
                edges = edge(grayImage, 'canny');
                
                % Find circles
                [d_centers, d_radii] = imfindcircles(edges, ...
                    [params.radiusMin params.radiusMax], ...
                    'ObjectPolarity', 'dark', ...
                    'Sensitivity', params.sensitivity);
                
                if isempty(d_centers)
                    error('No circles detected in image');
                end
                
                % Handle multiple circles based on user preference
                selectionMethod = app.CircleSelectionDropDown.Value;
                switch selectionMethod
                    case 'Use Largest'
                        [~, maxIdx] = max(d_radii);
                        d_centers = d_centers(maxIdx, :);
                        d_radii = d_radii(maxIdx);
                    case 'Use First'
                        d_centers = d_centers(1, :);
                        d_radii = d_radii(1);
                    % 'Use All' keeps all circles
                end
                
                % Calculate ring parameters using adjustable inner ratio
                innerRatio = params.innerRatio;
                b_centers = d_centers;
                b_radii = d_radii * innerRatio;
                ring_area = pi * (d_radii.^2 - b_radii.^2);
                if size(ring_area, 1) > 1
                    ring_area = sum(ring_area); % Sum areas if multiple circles
                end
                
                % Create masks
                [corrosion_mask, ring_mask] = createCorrosionMask(app, rgb, d_centers, d_radii, b_centers, b_radii, params);
                
                % Calculate corrosion ratio
                mask_area = sum(corrosion_mask(:));
                mask_ring_ratio = (mask_area / ring_area) * 100;
                
                % Calculate average color
                factored_image = params.rgbFactor(1) * double(rgb(:,:,1)) + ...
                                params.rgbFactor(2) * double(rgb(:,:,2)) + ...
                                params.rgbFactor(3) * double(rgb(:,:,3));
                
                ring_pixels = factored_image(ring_mask);
                avg_color_calc = mean(ring_pixels);
                
                % Extract carbon steel number and environment
                [~, name, ~] = fileparts(imageFile.name);
                carbonSteelNumber = regexp(name, '\d+', 'match', 'once');
                environment = getEnvironment(app, carbonSteelNumber);
                
                % Create visualization data
                visualizationData = struct();
                visualizationData.originalImage = rgb;
                visualizationData.d_centers = d_centers;
                visualizationData.d_radii = d_radii;
                visualizationData.b_centers = b_centers;
                visualizationData.b_radii = b_radii;
                visualizationData.corrosion_mask = corrosion_mask;
                visualizationData.ring_mask = ring_mask;
                
                % Create result structure
                result = struct();
                result.filename = imageFile.name;
                result.carbonSteelNumber = str2double(carbonSteelNumber);
                result.environment = environment;
                result.corrosionRatio = mask_ring_ratio;
                result.averageColor = avg_color_calc;
                result.visualizationData = visualizationData;
                result.success = true;
                result.error = '';
                
            catch ME
                result = struct();
                result.filename = imageFile.name;
                result.success = false;
                result.error = ME.message;
            end
        end
        
        function [corrosion_mask, ring_mask] = createCorrosionMask(app, rgb, d_centers, d_radii, b_centers, b_radii, params)
            corrosion_mask = false(size(rgb, 1), size(rgb, 2));
            ring_mask = false(size(rgb, 1), size(rgb, 2));
            
            for i = 1:size(d_centers, 1)
                center_d = d_centers(i, :);
                radius_d = d_radii(i);
                center_b = b_centers(i, :);
                radius_b = b_radii(i);
                
                % Vectorized approach for better performance
                [X, Y] = meshgrid(1:size(rgb, 2), 1:size(rgb, 1));
                
                % Check if pixels are within the ring
                dist_from_center = sqrt((X - center_d(1)).^2 + (Y - center_d(2)).^2);
                
                ring_pixels = (dist_from_center <= radius_d) & (dist_from_center >= radius_b);
                ring_mask = ring_mask | ring_pixels;
                
                % Check RGB values for corrosion
                r_channel = rgb(:,:,1);
                g_channel = rgb(:,:,2);
                b_channel = rgb(:,:,3);
                
                color_match = (r_channel >= params.rgbMin(1)) & (r_channel <= params.rgbMax(1)) & ...
                             (g_channel >= params.rgbMin(2)) & (g_channel <= params.rgbMax(2)) & ...
                             (b_channel >= params.rgbMin(3)) & (b_channel <= params.rgbMax(3));
                
                corrosion_mask = corrosion_mask | (ring_pixels & color_match);
            end
        end
        
        function visualizeResults(app)
            if isempty(app.Results)
                return;
            end
            
            cla(app.ResultsAxes);
            
            % Extract data for plotting
            environments = {app.Results.environment};
            corrosionRatios = [app.Results.corrosionRatio];
            
            % Create grouped bar chart
            uniqueEnvs = unique(environments);
            avgRatios = zeros(size(uniqueEnvs));
            
            for i = 1:length(uniqueEnvs)
                envMask = strcmp(environments, uniqueEnvs{i});
                envRatios = corrosionRatios(envMask);
                if ~isempty(envRatios)
                    avgRatios(i) = mean(envRatios);
                end
            end
            
            bar(app.ResultsAxes, avgRatios);
            title(app.ResultsAxes, 'Average Corrosion Ratio by Environment');
            ylabel(app.ResultsAxes, 'Corrosion Ratio (%)');
            app.ResultsAxes.XTickLabel = uniqueEnvs;
            xtickangle(app.ResultsAxes, 45);
        end
        
        function ring_mask = createRingMask(app, rgb, d_centers, d_radii)
            % Create ring mask for detected circles with smart selection
            ring_mask = false(size(rgb, 1), size(rgb, 2));
            
            if isempty(d_centers)
                return;
            end
            
            % Get user preferences
            innerRatio = app.InnerDiameterRatioSpinner.Value;
            selectionMethod = app.CircleSelectionDropDown.Value;
            
            % Handle multiple circles based on user preference
            switch selectionMethod
                case 'Use Largest'
                    % Find the largest circle
                    [~, maxIdx] = max(d_radii);
                    selected_centers = d_centers(maxIdx, :);
                    selected_radii = d_radii(maxIdx);
                    
                case 'Use First'
                    % Use the first detected circle
                    selected_centers = d_centers(1, :);
                    selected_radii = d_radii(1);
                    
                case 'Use All'
                    % Use all detected circles
                    selected_centers = d_centers;
                    selected_radii = d_radii;
            end
            
            % Create ring mask for selected circles
            for i = 1:size(selected_centers, 1)
                center_d = selected_centers(i, :);
                radius_d = selected_radii(i);
                radius_b = selected_radii(i) * innerRatio;
                
                [X, Y] = meshgrid(1:size(rgb, 2), 1:size(rgb, 1));
                dist_from_center = sqrt((X - center_d(1)).^2 + (Y - center_d(2)).^2);
                
                ring_pixels = (dist_from_center <= radius_d) & (dist_from_center >= radius_b);
                ring_mask = ring_mask | ring_pixels;
            end
        end
    end
    
    % Auto-detection methods
    methods (Access = private)
        function autoDetectRGBRange(app)
            if isempty(app.ImageFiles)
                uialert(app.UIFigure, 'Please select images first.', 'No Images');
                return;
            end
            
            logMessage(app, 'Starting intelligent RGB range detection on ALL images...');
            
            % Use ALL images for better analysis (or sample only if too many)
            numImages = length(app.ImageFiles);
            if numImages > 50
                % Only sample if we have more than 50 images to avoid performance issues
                numSamples = 30;
                sampleIndices = round(linspace(1, numImages, numSamples));
                logMessage(app, sprintf('Analyzing %d sample images (out of %d total)', numSamples, numImages));
            else
                % Use all images for best results
                sampleIndices = 1:numImages;
                logMessage(app, sprintf('Analyzing ALL %d images for optimal RGB detection', numImages));
            end
            
            % Get circle detection parameters
            params = struct();
            params.radiusMin = app.CircleRadiusMinSpinner.Value;
            params.radiusMax = app.CircleRadiusMaxSpinner.Value;
            params.sensitivity = app.SensitivitySpinner.Value;
            
            allRingPixels = [];
            successfulImages = 0;
            
            app.ProgressGauge.Value = 0;
            
            % Collect all ring pixels from all images (or samples)
            for i = 1:length(sampleIndices)
                app.ProgressGauge.Value = (i-1) / length(sampleIndices) * 50; % Use 50% for collection
                drawnow;
                
                imgIdx = sampleIndices(i);
                filename = app.ImageFiles(imgIdx).name;
                logMessage(app, sprintf('Analyzing image %d/%d: %s', i, length(sampleIndices), filename));
                
                try
                    fullImagePath = fullfile(app.ImageDirectory, filename);
                    rgb = imread(fullImagePath);
                    
                    % Detect circles
                    grayImage = rgb2gray(rgb);
                    edges = edge(grayImage, 'canny');
                    [d_centers, d_radii] = imfindcircles(edges, [params.radiusMin params.radiusMax], ...
                        'ObjectPolarity', 'dark', 'Sensitivity', params.sensitivity);
                    
                    if ~isempty(d_centers)
                        % Create ring mask
                        ring_mask = createRingMask(app, rgb, d_centers, d_radii);
                        
                        % Extract RGB values from ring area
                        ringPixels = extractRGBFromMask(app, rgb, ring_mask);
                        if ~isempty(ringPixels)
                            allRingPixels = [allRingPixels; ringPixels];
                            successfulImages = successfulImages + 1;
                        end
                    end
                    
                catch ME
                    logMessage(app, sprintf('Error analyzing %s: %s', filename, ME.message));
                end
            end
            
            if isempty(allRingPixels)
                logMessage(app, 'No ring areas detected in any images');
                uialert(app.UIFigure, 'Could not detect ring areas in any images. Check circle detection parameters.', 'Auto-Detection Failed');
                return;
            end
            
            logMessage(app, sprintf('Successfully analyzed %d images, collected %d pixels from ring areas', ...
                successfulImages, size(allRingPixels, 1)));
            logMessage(app, 'Analyzing corrosion colors from complete dataset...');
            
            % Advanced corrosion-specific range detection using ALL data
            [rgbMin, rgbMax, confidence] = detectCorrosionRange(app, allRingPixels);
            
            app.ProgressGauge.Value = 100;
            
            % Update the GUI
            app.RGBMinEditField.Value = sprintf('[%d, %d, %d]', rgbMin(1), rgbMin(2), rgbMin(3));
            app.RGBMaxEditField.Value = sprintf('[%d, %d, %d]', rgbMax(1), rgbMax(2), rgbMax(3));
            
            logMessage(app, sprintf('Detected RGB range from %d images: Min=[%d,%d,%d], Max=[%d,%d,%d] (Confidence: %.1f%%)', ...
                successfulImages, rgbMin(1), rgbMin(2), rgbMin(3), rgbMax(1), rgbMax(2), rgbMax(3), confidence*100));
            
            % Show detailed results
            msg = sprintf(['RGB Range Detection Complete!\n\n' ...
                          'Analyzed: %d images\n' ...
                          'Pixels analyzed: %,d\n\n' ...
                          'Detected Range:\n' ...
                          'Min: [%d, %d, %d]\n' ...
                          'Max: [%d, %d, %d]\n\n' ...
                          'Detection Confidence: %.1f%%\n\n' ...
                          'This range is optimized for your specific\n' ...
                          'corrosion images and should provide\n' ...
                          'excellent detection accuracy.\n\n' ...
                          'Use "Preview RGB Detection" to test the results.'], ...
                          successfulImages, size(allRingPixels, 1), ...
                          rgbMin(1), rgbMin(2), rgbMin(3), rgbMax(1), rgbMax(2), rgbMax(3), confidence*100);
            
            uialert(app.UIFigure, msg, 'Auto-Detection Complete');
        end
        
        function rgbPixels = extractRGBFromMask(app, rgb, mask)
            % Extract RGB values from masked area
            r_vals = rgb(:,:,1);
            g_vals = rgb(:,:,2);
            b_vals = rgb(:,:,3);
            
            r_masked = r_vals(mask);
            g_masked = g_vals(mask);
            b_masked = b_vals(mask);
            
            rgbPixels = [double(r_masked), double(g_masked), double(b_masked)];
        end
        
        function [rgbMin, rgbMax, confidence] = detectCorrosionRange(app, allPixels)
            % Balanced corrosion range detection (not too sensitive)
            
            logMessage(app, 'Applying balanced corrosion color analysis...');
            
            % Step 1: Reasonable filtering (not too aggressive)
            brightness = sum(allPixels, 2) / 3;
            % Keep pixels in moderate brightness range
            filteredPixels = allPixels(brightness < 200 & brightness > 40, :);
            
            if size(filteredPixels, 1) < 100
                filteredPixels = allPixels; % Use all if filtering removed too much
            end
            
            % Step 2: Moderate HSV analysis for corrosion
            hsvPixels = rgb2hsv(reshape(filteredPixels, [size(filteredPixels, 1), 1, 3]));
            hsvPixels = reshape(hsvPixels, [size(filteredPixels, 1), 3]);
            
            % Step 3: Balanced corrosion color detection
            % Focus on typical rust colors: red/orange/brown range
            corrosion_hue_mask = (hsvPixels(:,1) <= 0.12) | (hsvPixels(:,1) >= 0.92); % Red to orange
            corrosion_sat_mask = hsvPixels(:,2) >= 0.15; % Reasonable saturation
            corrosion_val_mask = hsvPixels(:,3) >= 0.2 & hsvPixels(:,3) <= 0.85; % Moderate brightness
            
            % Additional rust pattern detection
            r_channel = filteredPixels(:,1);
            g_channel = filteredPixels(:,2);
            b_channel = filteredPixels(:,3);
            
            % Detect typical rust patterns: R > G > B tendency
            rust_pattern = (r_channel > g_channel * 1.1) & (r_channel > b_channel * 1.2);
            
            % Combine criteria (moderate inclusivity)
            corrosion_mask = (corrosion_hue_mask & corrosion_sat_mask & corrosion_val_mask) | rust_pattern;
            
            % Step 4: Use detected corrosion pixels
            if sum(corrosion_mask) > 100  % Reasonable threshold
                corrosionPixels = filteredPixels(corrosion_mask, :);
                logMessage(app, sprintf('Found %d corrosion-like pixels using balanced analysis', sum(corrosion_mask)));
                confidence = min(0.85, sum(corrosion_mask) / size(filteredPixels, 1) * 2.5);
            else
                % Moderate fallback approach
                logMessage(app, 'Using moderate statistical clustering...');
                [corrosionPixels, ~] = clusterRGBPixelsBalanced(app, filteredPixels);
                confidence = 0.65;
            end
            
            % Step 5: Calculate reasonable range boundaries
            if ~isempty(corrosionPixels)
                % Use moderate percentiles (not too wide, not too narrow)
                rgbMin = floor(prctile(corrosionPixels, 8, 1));   % 8th percentile
                rgbMax = ceil(prctile(corrosionPixels, 92, 1));   % 92nd percentile
                
                % Step 6: Moderate validation
                [rgbMin, rgbMax, confidence] = validateRangeBalanced(app, rgbMin, rgbMax, allPixels, corrosionPixels, confidence);
            else
                % Reasonable default range
                rgbMin = [60, 30, 5];
                rgbMax = [165, 110, 30];
                confidence = 0.5;
                logMessage(app, 'Using balanced default range');
            end
            
            % Ensure valid ranges
            rgbMin = max(0, rgbMin);
            rgbMax = min(255, rgbMax);
            
            % Ensure reasonable range spans
            for i = 1:3
                if rgbMin(i) >= rgbMax(i)
                    rgbMax(i) = rgbMin(i) + 18;
                elseif (rgbMax(i) - rgbMin(i)) < 12
                    % Expand slightly if too narrow
                    center = (rgbMin(i) + rgbMax(i)) / 2;
                    rgbMin(i) = max(0, center - 8);
                    rgbMax(i) = min(255, center + 8);
                end
            end
        end
        
        function [corrosionPixels, nonCorrosionPixels] = clusterRGBPixelsBalanced(app, rgbPixels)
            % Balanced clustering for corrosion detection
            if size(rgbPixels, 1) < 50
                corrosionPixels = rgbPixels;
                nonCorrosionPixels = [];
                return;
            end
            
            try
                % Use moderate clustering
                k = min(3, size(rgbPixels, 1));
                [idx, centers] = kmeans(rgbPixels, k);
                
                % Balanced criteria for identifying corrosion clusters
                redScore = centers(:,1) * 0.5;
                rbScore = (centers(:,1) - centers(:,3)) * 0.3;
                rgScore = (centers(:,1) - centers(:,2)) * 0.2;
                
                % Combined score (moderate approach)
                combinedScore = redScore + rbScore + rgScore;
                [~, corrosionClusterIdx] = max(combinedScore);
                
                corrosionPixels = rgbPixels(idx == corrosionClusterIdx, :);
                nonCorrosionPixels = rgbPixels(idx ~= corrosionClusterIdx, :);
                
            catch
                % Simple fallback
                rustMask = (rgbPixels(:,1) > rgbPixels(:,2) * 1.1) & ...
                          (rgbPixels(:,1) > rgbPixels(:,3) * 1.2);
                corrosionPixels = rgbPixels(rustMask, :);
                nonCorrosionPixels = rgbPixels(~rustMask, :);
            end
        end
        
        function [rgbMin, rgbMax, confidence] = validateRangeBalanced(app, rgbMin, rgbMax, allPixels, corrosionPixels, confidence)
            % Balanced validation
            
            % Test current range
            r_in_range = (allPixels(:,1) >= rgbMin(1)) & (allPixels(:,1) <= rgbMax(1));
            g_in_range = (allPixels(:,2) >= rgbMin(2)) & (allPixels(:,2) <= rgbMax(2));
            b_in_range = (allPixels(:,3) >= rgbMin(3)) & (allPixels(:,3) <= rgbMax(3));
            
            in_range_mask = r_in_range & g_in_range & b_in_range;
            detection_rate = sum(in_range_mask) / size(allPixels, 1);
            
            % Moderate adjustment criteria
            if detection_rate < 0.03 % Too restrictive
                logMessage(app, sprintf('Range too restrictive (%.1f%% detected), expanding moderately...', detection_rate*100));
                % Moderate expansion
                range_r = rgbMax(1) - rgbMin(1);
                range_g = rgbMax(2) - rgbMin(2);
                range_b = rgbMax(3) - rgbMin(3);
                
                rgbMin = rgbMin - [range_r*0.15, range_g*0.15, range_b*0.15];
                rgbMax = rgbMax + [range_r*0.15, range_g*0.15, range_b*0.15];
                confidence = confidence * 0.85;
                
            elseif detection_rate > 0.25 % Too broad
                logMessage(app, sprintf('Range too broad (%.1f%% detected), tightening moderately...', detection_rate*100));
                % Moderate tightening
                rgbMin = floor(prctile(corrosionPixels, 12, 1));
                rgbMax = ceil(prctile(corrosionPixels, 88, 1));
                confidence = confidence * 0.9;
                
            else
                logMessage(app, sprintf('Balanced range achieved (%.1f%% of pixels detected)', detection_rate*100));
                confidence = min(0.9, confidence * 1.05);
            end
        end
        
        function previewRGBDetection(app)
            if isempty(app.ImageFiles)
                uialert(app.UIFigure, 'Please select images first.', 'No Images');
                return;
            end
            
            try
                % Parse current RGB parameters
                rgbMin = eval(app.RGBMinEditField.Value);
                rgbMax = eval(app.RGBMaxEditField.Value);
                innerRatio = app.InnerDiameterRatioSpinner.Value;
                
                % Test on current image
                filename = app.ImageFiles(app.CurrentImageIndex).name;
                fullImagePath = fullfile(app.ImageDirectory, filename);
                rgb = imread(fullImagePath);
                
                % Quick circle detection for preview
                grayImage = rgb2gray(rgb);
                edges = edge(grayImage, 'canny');
                [d_centers, d_radii] = imfindcircles(edges, ...
                    [app.CircleRadiusMinSpinner.Value app.CircleRadiusMaxSpinner.Value], ...
                    'ObjectPolarity', 'dark', 'Sensitivity', app.SensitivitySpinner.Value);
                
                if ~isempty(d_centers)
                    % Handle multiple circles based on user preference
                    selectionMethod = app.CircleSelectionDropDown.Value;
                    switch selectionMethod
                        case 'Use Largest'
                            [~, maxIdx] = max(d_radii);
                            d_centers = d_centers(maxIdx, :);
                            d_radii = d_radii(maxIdx);
                        case 'Use First'
                            d_centers = d_centers(1, :);
                            d_radii = d_radii(1);
                        % 'Use All' keeps all circles
                    end
                    
                    % Create preview mask with adjustable inner ratio
                    b_centers = d_centers;
                    b_radii = d_radii * innerRatio;
                    
                    previewMask = false(size(rgb, 1), size(rgb, 2));
                    ring_mask = false(size(rgb, 1), size(rgb, 2));
                    
                    for i = 1:size(d_centers, 1)
                        [X, Y] = meshgrid(1:size(rgb, 2), 1:size(rgb, 1));
                        dist_from_center = sqrt((X - d_centers(i,1)).^2 + (Y - d_centers(i,2)).^2);
                        ring_pixels = (dist_from_center <= d_radii(i)) & (dist_from_center >= b_radii(i));
                        ring_mask = ring_mask | ring_pixels;
                        
                        % Apply RGB filtering
                        r_channel = rgb(:,:,1);
                        g_channel = rgb(:,:,2);
                        b_channel = rgb(:,:,3);
                        
                        color_match = (r_channel >= rgbMin(1)) & (r_channel <= rgbMax(1)) & ...
                                     (g_channel >= rgbMin(2)) & (g_channel <= rgbMax(2)) & ...
                                     (b_channel >= rgbMin(3)) & (b_channel <= rgbMax(3));
                        
                        previewMask = previewMask | (ring_pixels & color_match);
                    end
                    
                    % Calculate detection percentage
                    ring_area = sum(ring_mask(:));
                    detected_area = sum(previewMask(:));
                    detection_percent = (detected_area / ring_area) * 100;
                    
                    % Show preview in image axes
                    overlayImage = rgb;
                    overlayImage(:,:,1) = overlayImage(:,:,1) + uint8(previewMask * 100);
                    imshow(overlayImage, 'Parent', app.ImageAxes);
                    
                    circleInfo = sprintf('%d circle(s), Inner ratio: %.3f', size(d_centers, 1), innerRatio);
                    title(app.ImageAxes, sprintf('RGB Preview (%.2f%% detected)\n%s: %s', ...
                        detection_percent, circleInfo, filename), 'Interpreter', 'none');
                    
                    logMessage(app, sprintf('RGB Preview: %.2f%% of ring area detected as corrosion (%s)', ...
                        detection_percent, circleInfo));
                    
                else
                    uialert(app.UIFigure, 'No circles detected in current image. Check circle detection parameters.', 'Preview Failed');
                end
                
            catch ME
                uialert(app.UIFigure, ['Preview failed: ' ME.message], 'Error');
            end
        end
    end
    
    % Button callback methods
    methods (Access = private)
        function SelectFilesButtonPushed(app)
            app.ImageDirectory = uigetdir('', 'Select Directory Containing Images');
            if app.ImageDirectory == 0
                return;
            end
            
            % Get image files
            imageExtensions = {'*.jpg', '*.jpeg', '*.png', '*.tif', '*.tiff'};
            app.ImageFiles = [];
            
            for ext = imageExtensions
                files = dir(fullfile(app.ImageDirectory, ext{1}));
                app.ImageFiles = [app.ImageFiles; files];
            end
            
            if isempty(app.ImageFiles)
                uialert(app.UIFigure, 'No image files found in the selected directory.', 'No Images Found');
                logMessage(app, 'No image files found in selected directory');
                return;
            end
            
            logMessage(app, sprintf('Found %d image files in directory', length(app.ImageFiles)));
            updateGroupCounts(app);
            app.ProcessImagesButton.Enable = 'on';
            app.AutoDetectRGBButton.Enable = 'on';
            app.RGBPreviewButton.Enable = 'on';
            
            % Show first image
            updateImageDisplay(app);
        end
        
        function ProcessImagesButtonPushed(app)
            if isempty(app.ImageFiles)
                uialert(app.UIFigure, 'Please select a directory with images first.', 'No Images');
                return;
            end
            
            % Parse parameters
            try
                params = struct();
                params.radiusMin = app.CircleRadiusMinSpinner.Value;
                params.radiusMax = app.CircleRadiusMaxSpinner.Value;
                params.sensitivity = app.SensitivitySpinner.Value;
                params.innerRatio = app.InnerDiameterRatioSpinner.Value;
                params.rgbMin = eval(app.RGBMinEditField.Value);
                params.rgbMax = eval(app.RGBMaxEditField.Value);
                params.rgbFactor = eval(app.RGBFactorEditField.Value);
            catch
                uialert(app.UIFigure, 'Invalid parameter values. Please check your inputs.', 'Parameter Error');
                return;
            end
            
            logMessage(app, sprintf('Starting image processing with Inner/Outer ratio: %.3f', params.innerRatio));
            logMessage(app, sprintf('Circle selection method: %s', app.CircleSelectionDropDown.Value));
            app.ProcessImagesButton.Enable = 'off';
            app.Results = [];
            
            % Process images
            numImages = length(app.ImageFiles);
            for i = 1:numImages
                app.ProgressGauge.Value = (i-1) / numImages * 100;
                drawnow;
                
                logMessage(app, sprintf('Processing image %d/%d: %s', i, numImages, app.ImageFiles(i).name));
                
                result = processImage(app, app.ImageFiles(i), params);
                app.Results = [app.Results result];
                
                if ~result.success
                    logMessage(app, sprintf('Error processing %s: %s', result.filename, result.error));
                else
                    % Update current image display if this is the currently viewed image
                    if app.CurrentImageIndex == i
                        updateImageDisplay(app);
                    end
                end
            end
            
            app.ProgressGauge.Value = 100;
            app.ProcessImagesButton.Enable = 'on';
            app.ExportResultsButton.Enable = 'on';
            
            % Count successful and failed processing
            successCount = sum([app.Results.success]);
            failCount = numImages - successCount;
            
            logMessage(app, sprintf('Processing completed: %d successful, %d failed', successCount, failCount));
            
            % Visualize results and update image display
            visualizeResults(app);
            updateImageDisplay(app);
        end
        
        function ExportResultsButtonPushed(app)
            if isempty(app.Results)
                uialert(app.UIFigure, 'No results to export. Please process images first.', 'No Results');
                return;
            end
            
            % Prepare data for export
            successfulResults = app.Results([app.Results.success]);
            
            if isempty(successfulResults)
                uialert(app.UIFigure, 'No successful results to export.', 'No Successful Results');
                return;
            end
            
            % Create main export folder with timestamp
            timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
            exportFolderName = sprintf('CorrosionAnalysis_%s', timestamp);
            exportFolder = fullfile(app.ImageDirectory, exportFolderName);
            
            if ~exist(exportFolder, 'dir')
                mkdir(exportFolder);
            end
            
            logMessage(app, sprintf('Creating comprehensive export in: %s', exportFolder));
            
            % 1. Export main results to Excel
            exportMainResults(app, successfulResults, exportFolder);
            
            % 2. Export all analysis parameters
            exportAnalysisParameters(app, exportFolder);
            
            % 3. Export environment groups configuration
            exportGroupsConfiguration(app, exportFolder);
            
            % 4. Create image visualization folders
            createImageVisualizations(app, successfulResults, exportFolder);
            
            % 5. Create summary report
            createSummaryReport(app, successfulResults, exportFolder, timestamp);
            
            % 6. Create advanced statistical visualizations
            createAdvancedVisualizations(app, successfulResults, exportFolder);
            
            logMessage(app, 'Comprehensive export completed successfully!');
            uialert(app.UIFigure, sprintf(['Comprehensive export completed!\n\n' ...
                'Location: %s\n\n' ...
                'Contents:\n' ...
                '• Excel results with all parameters\n' ...
                '• 4-panel visualization images (standard + hi-res)\n' ...
                '• Advanced statistical analysis (box plots, heatmaps, correlations)\n' ...
                '• Analysis summary report\n' ...
                '• Groups configuration'], exportFolder), 'Export Complete');
            
            % Open the export folder
            if ispc
                winopen(exportFolder);
            elseif ismac
                system(['open "' exportFolder '"']);
            else
                system(['xdg-open "' exportFolder '"']);
            end
        end
        
        function exportMainResults(app, successfulResults, exportFolder)
            % Export main results to Excel
            excelFileName = fullfile(exportFolder, 'CorrosionAnalysisResults.xlsx');
            
            % Main results sheet
            headers = {'Carbon Steel P/N', 'Environment', 'Corrosion Ratio (%)', 'Average Color', 'Filename'};
            exportData = cell(length(successfulResults) + 1, 5);
            exportData(1, :) = headers;
            
            for i = 1:length(successfulResults)
                exportData{i+1, 1} = successfulResults(i).carbonSteelNumber;
                exportData{i+1, 2} = successfulResults(i).environment;
                exportData{i+1, 3} = successfulResults(i).corrosionRatio;
                exportData{i+1, 4} = successfulResults(i).averageColor;
                exportData{i+1, 5} = successfulResults(i).filename;
            end
            
            writecell(exportData, excelFileName, 'Sheet', 'Results');
            
            % Group summary sheet
            groupSummary = cell(size(app.EnvironmentGroups, 1) + 1, 4);
            groupSummary(1, :) = {'Environment', 'Sample Count', 'Avg Corrosion Ratio (%)', 'Std Deviation'};
            
            for i = 1:size(app.EnvironmentGroups, 1)
                envName = app.EnvironmentGroups{i, 1};
                envMask = strcmp({successfulResults.environment}, envName);
                envResults = successfulResults(envMask);
                
                groupSummary{i+1, 1} = envName;
                groupSummary{i+1, 2} = length(envResults);
                if ~isempty(envResults)
                    ratios = [envResults.corrosionRatio];
                    groupSummary{i+1, 3} = mean(ratios);
                    groupSummary{i+1, 4} = std(ratios);
                else
                    groupSummary{i+1, 3} = 0;
                    groupSummary{i+1, 4} = 0;
                end
            end
            
            writecell(groupSummary, excelFileName, 'Sheet', 'GroupSummary');
            logMessage(app, 'Main results exported to Excel');
        end
        
        function exportAnalysisParameters(app, exportFolder)
            % Export all analysis parameters used
            excelFileName = fullfile(exportFolder, 'CorrosionAnalysisResults.xlsx');
            
            % Get current parameter values
            try
                rgbMin = eval(app.RGBMinEditField.Value);
                rgbMax = eval(app.RGBMaxEditField.Value);
                rgbFactor = eval(app.RGBFactorEditField.Value);
            catch
                rgbMin = [65, 35, 0];
                rgbMax = [170, 120, 25];
                rgbFactor = [0.55, 0.35, 0.10];
            end
            
            % Create parameters data
            paramData = {
                'Parameter', 'Value', 'Description';
                'Circle Radius Min', app.CircleRadiusMinSpinner.Value, 'Minimum radius for circle detection (pixels)';
                'Circle Radius Max', app.CircleRadiusMaxSpinner.Value, 'Maximum radius for circle detection (pixels)';
                'Sensitivity', app.SensitivitySpinner.Value, 'Circle detection sensitivity (0-1)';
                'Inner/Outer Ratio', app.InnerDiameterRatioSpinner.Value, 'Ratio of inner to outer circle radius';
                'Circle Selection', app.CircleSelectionDropDown.Value, 'Method for handling multiple detected circles';
                'RGB Min R', rgbMin(1), 'Minimum red value for corrosion detection';
                'RGB Min G', rgbMin(2), 'Minimum green value for corrosion detection';
                'RGB Min B', rgbMin(3), 'Minimum blue value for corrosion detection';
                'RGB Max R', rgbMax(1), 'Maximum red value for corrosion detection';
                'RGB Max G', rgbMax(2), 'Maximum green value for corrosion detection';
                'RGB Max B', rgbMax(3), 'Maximum blue value for corrosion detection';
                'RGB Factor R', rgbFactor(1), 'Red channel weight for color calculation';
                'RGB Factor G', rgbFactor(2), 'Green channel weight for color calculation';
                'RGB Factor B', rgbFactor(3), 'Blue channel weight for color calculation';
                'Analysis Date', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'When this analysis was performed';
                'Total Images Processed', length(app.Results), 'Total number of images in analysis';
                'Successful Analyses', sum([app.Results.success]), 'Number of successfully processed images';
            };
            
            writecell(paramData, excelFileName, 'Sheet', 'Parameters');
            logMessage(app, 'Analysis parameters exported to Excel');
        end
        
        function exportGroupsConfiguration(app, exportFolder)
            % Export environment groups configuration
            excelFileName = fullfile(exportFolder, 'CorrosionAnalysisResults.xlsx');
            
            % Groups configuration with descriptions
            groupsData = cell(size(app.EnvironmentGroups, 1) + 1, 4);
            groupsData(1, :) = {'Environment Name', 'Number Range', 'Sample Count', 'Description'};
            
            for i = 1:size(app.EnvironmentGroups, 1)
                groupsData{i+1, 1} = app.EnvironmentGroups{i, 1};
                groupsData{i+1, 2} = app.EnvironmentGroups{i, 2};
                groupsData{i+1, 3} = app.EnvironmentGroups{i, 3};
                groupsData{i+1, 4} = sprintf('Images with carbon steel numbers in range %s', app.EnvironmentGroups{i, 2});
            end
            
            writecell(groupsData, excelFileName, 'Sheet', 'GroupsConfiguration');
            logMessage(app, 'Groups configuration exported to Excel');
        end
        
        function createImageVisualizations(app, successfulResults, exportFolder)
            % Create folder and save all image visualizations as subplots
            logMessage(app, 'Creating image visualization subplots...');
            
            % Create single subfolder for combined visualizations
            visualizationFolder = fullfile(exportFolder, 'ImageVisualizations');
            if ~exist(visualizationFolder, 'dir')
                mkdir(visualizationFolder);
            end
            
            % Process each successful result
            app.ProgressGauge.Value = 0;
            for i = 1:length(successfulResults)
                app.ProgressGauge.Value = (i-1) / length(successfulResults) * 100;
                drawnow;
                
                result = successfulResults(i);
                if ~isfield(result, 'visualizationData') || isempty(result.visualizationData)
                    continue;
                end
                
                [~, baseName, ~] = fileparts(result.filename);
                saveImageVisualizationSubplot(app, result, visualizationFolder, baseName);
            end
            
            app.ProgressGauge.Value = 100;
            logMessage(app, sprintf('Saved %d comprehensive visualization images', length(successfulResults)));
        end
        
        function saveImageVisualizationSubplot(app, result, exportFolder, baseName)
            % Save all 4 visualization types in a single subplot image
            vizData = result.visualizationData;
            
            % Create figure with 2x2 subplot layout
            fig = figure('Visible', 'off', 'Position', [100, 100, 1200, 900]);
            
            % Subplot 1: Original Image
            subplot(2, 2, 1);
            imshow(vizData.originalImage);
            title('Original Image', 'FontSize', 12, 'FontWeight', 'bold');
            
            % Subplot 2: With Circles
            subplot(2, 2, 2);
            imshow(vizData.originalImage);
            hold on;
            
            if ~isempty(vizData.d_centers)
                for i = 1:size(vizData.d_centers, 1)
                    % Draw outer circle (blue)
                    theta = 0:0.1:2*pi;
                    x_outer = vizData.d_centers(i,1) + vizData.d_radii(i) * cos(theta);
                    y_outer = vizData.d_centers(i,2) + vizData.d_radii(i) * sin(theta);
                    plot(x_outer, y_outer, 'b-', 'LineWidth', 2);
                    
                    % Draw inner circle (red)
                    x_inner = vizData.b_centers(i,1) + vizData.b_radii(i) * cos(theta);
                    y_inner = vizData.b_centers(i,2) + vizData.b_radii(i) * sin(theta);
                    plot(x_inner, y_inner, 'r-', 'LineWidth', 2);
                end
            end
            hold off;
            title('Detected Circles', 'FontSize', 12, 'FontWeight', 'bold');
            
            % Subplot 3: Corrosion Mask
            subplot(2, 2, 3);
            maskImg = vizData.originalImage;
            maskImg(:,:,1) = maskImg(:,:,1) + uint8(vizData.corrosion_mask * 100);
            imshow(maskImg);
            title(sprintf('Corrosion Areas (%.2f%%)', result.corrosionRatio), 'FontSize', 12, 'FontWeight', 'bold');
            
            % Subplot 4: Combined View
            subplot(2, 2, 4);
            imshow(vizData.originalImage);
            hold on;
            
            % Draw circles
            if ~isempty(vizData.d_centers)
                for i = 1:size(vizData.d_centers, 1)
                    theta = 0:0.1:2*pi;
                    x_outer = vizData.d_centers(i,1) + vizData.d_radii(i) * cos(theta);
                    y_outer = vizData.d_centers(i,2) + vizData.d_radii(i) * sin(theta);
                    plot(x_outer, y_outer, 'b-', 'LineWidth', 2);
                    
                    x_inner = vizData.b_centers(i,1) + vizData.b_radii(i) * cos(theta);
                    y_inner = vizData.b_centers(i,2) + vizData.b_radii(i) * sin(theta);
                    plot(x_inner, y_inner, 'r-', 'LineWidth', 1);
                end
            end
            
            % Show corrosion areas
            [corr_y, corr_x] = find(vizData.corrosion_mask);
            if ~isempty(corr_x)
                scatter(corr_x, corr_y, 1, 'y', 'filled', 'MarkerFaceAlpha', 0.6);
            end
            
            hold off;
            title('Complete Analysis', 'FontSize', 12, 'FontWeight', 'bold');
            
            % Add main title with sample information
            sgtitle(sprintf('%s - Steel #%d (%s)', baseName, result.carbonSteelNumber, result.environment), ...
                'FontSize', 14, 'FontWeight', 'bold');
            
            % Add analysis information as text
            annotation('textbox', [0.02, 0.02, 0.96, 0.08], ...
                'String', sprintf(['Analysis Info: Avg Color: %.2f | Inner/Outer Ratio: %.3f | ' ...
                'RGB Range: [%s] to [%s] | Detection Method: %s'], ...
                result.averageColor, app.InnerDiameterRatioSpinner.Value, ...
                app.RGBMinEditField.Value, app.RGBMaxEditField.Value, ...
                app.CircleSelectionDropDown.Value), ...
                'FontSize', 10, 'HorizontalAlignment', 'center', ...
                'BackgroundColor', 'white', 'EdgeColor', 'black');
            
            % Save the subplot image
            outputPath = fullfile(exportFolder, [baseName '_Analysis.png']);
            saveas(fig, outputPath, 'png');
            
            % Also save as high-resolution for publications
            outputPathHiRes = fullfile(exportFolder, [baseName '_Analysis_HiRes.png']);
            print(fig, outputPathHiRes, '-dpng', '-r300'); % 300 DPI
            
            close(fig);
        end
        
        function createSummaryReport(app, successfulResults, exportFolder, timestamp)
            % Create a comprehensive text summary report
            reportFile = fullfile(exportFolder, 'AnalysisSummaryReport.txt');
            
            fid = fopen(reportFile, 'w');
            if fid == -1
                logMessage(app, 'Warning: Could not create summary report file');
                return;
            end
            
            % Write header
            fprintf(fid, '=======================================================\n');
            fprintf(fid, '           CORROSION ANALYSIS SUMMARY REPORT\n');
            fprintf(fid, '=======================================================\n\n');
            fprintf(fid, 'Analysis Date: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
            fprintf(fid, 'Export Timestamp: %s\n\n', timestamp);
            
            % Write analysis overview
            fprintf(fid, 'ANALYSIS OVERVIEW:\n');
            fprintf(fid, '- Total Images Analyzed: %d\n', length(app.Results));
            fprintf(fid, '- Successfully Processed: %d\n', length(successfulResults));
            fprintf(fid, '- Failed Analyses: %d\n\n', length(app.Results) - length(successfulResults));
            
            % Write parameter summary
            fprintf(fid, 'ANALYSIS PARAMETERS:\n');
            fprintf(fid, '- Circle Detection Range: %d - %d pixels\n', app.CircleRadiusMinSpinner.Value, app.CircleRadiusMaxSpinner.Value);
            fprintf(fid, '- Detection Sensitivity: %.3f\n', app.SensitivitySpinner.Value);
            fprintf(fid, '- Inner/Outer Ring Ratio: %.3f\n', app.InnerDiameterRatioSpinner.Value);
            fprintf(fid, '- Circle Selection Method: %s\n', app.CircleSelectionDropDown.Value);
            fprintf(fid, '- RGB Detection Range: %s to %s\n', app.RGBMinEditField.Value, app.RGBMaxEditField.Value);
            fprintf(fid, '- RGB Weighting Factors: %s\n\n', app.RGBFactorEditField.Value);
            
            % Write group statistics
            fprintf(fid, 'ENVIRONMENT GROUP STATISTICS:\n');
            for i = 1:size(app.EnvironmentGroups, 1)
                envName = app.EnvironmentGroups{i, 1};
                envMask = strcmp({successfulResults.environment}, envName);
                envResults = successfulResults(envMask);
                
                if ~isempty(envResults)
                    ratios = [envResults.corrosionRatio];
                    fprintf(fid, '- %s (%s): %d samples, Avg: %.2f%%, Std: %.2f%%\n', ...
                        envName, app.EnvironmentGroups{i, 2}, length(envResults), mean(ratios), std(ratios));
                else
                    fprintf(fid, '- %s (%s): 0 samples\n', envName, app.EnvironmentGroups{i, 2});
                end
            end
            
            % Write detailed results
            fprintf(fid, '\n\nDETAILED RESULTS:\n');
            fprintf(fid, 'Carbon Steel#  | Environment                    | Corrosion%% | Avg Color | Filename\n');
            fprintf(fid, '---------------|--------------------------------|-----------|-----------|----------------\n');
            
            for i = 1:length(successfulResults)
                result = successfulResults(i);
                fprintf(fid, '%-14d | %-30s | %8.2f%% | %8.2f | %s\n', ...
                    result.carbonSteelNumber, result.environment(1:min(30,end)), ...
                    result.corrosionRatio, result.averageColor, result.filename);
            end
            
            fprintf(fid, '\n\nEXPORT CONTENTS:\n');
            fprintf(fid, '- CorrosionAnalysisResults.xlsx: Complete data with parameters\n');
            fprintf(fid, '- ImageVisualizations/: Comprehensive analysis images for each sample\n');
            fprintf(fid, '  * Each image shows 4-panel view: Original, Circles, Corrosion Mask, Complete Analysis\n');
            fprintf(fid, '  * Standard resolution: _Analysis.png (for viewing)\n');
            fprintf(fid, '  * High resolution: _Analysis_HiRes.png (300 DPI, for publications)\n');
            fprintf(fid, '- StatisticalAnalysis/: Advanced statistical visualizations\n');
            fprintf(fid, '  * GroupBoxPlots.png: Distribution comparison between environment groups\n');
            fprintf(fid, '  * ViolinPlots.png: Detailed distribution shapes with individual data points\n');
            fprintf(fid, '  * CorrelationAnalysis.png: Parameter relationships and correlations\n');
            fprintf(fid, '  * StatisticalSummary.png: Clean bar charts with error bars and sample sizes\n');
            fprintf(fid, '- AnalysisSummaryReport.txt: This summary report\n\n');
            
            fprintf(fid, 'Analysis completed successfully!\n');
            fprintf(fid, '=======================================================\n');
            
            fclose(fid);
            logMessage(app, 'Summary report created');
        end
        
        function createAdvancedVisualizations(app, successfulResults, exportFolder)
            % Create advanced statistical visualizations to show group differences
            logMessage(app, 'Creating advanced statistical visualizations...');
            
            if length(successfulResults) < 3
                logMessage(app, 'Skipping advanced visualizations - insufficient data');
                return;
            end
            
            % Create statistical plots folder
            statsFolder = fullfile(exportFolder, 'StatisticalAnalysis');
            if ~exist(statsFolder, 'dir')
                mkdir(statsFolder);
            end
            
            % 1. Box Plot - Best for showing group differences
            createGroupBoxPlots(app, successfulResults, statsFolder);
            
            % 2. Violin Plots - Better than box plots for showing distribution shape
            createViolinPlots(app, successfulResults, statsFolder);
            
            % 3. Correlation Analysis
            createCorrelationAnalysis(app, successfulResults, statsFolder);
            
            % 4. Statistical Summary Bar Chart
            createStatisticalSummary(app, successfulResults, statsFolder);
            
            logMessage(app, 'Advanced visualizations completed');
        end
        
        function createViolinPlots(app, successfulResults, statsFolder)
            % Create violin plots showing detailed distribution shapes by group
            try
                environments = {successfulResults.environment};
                corrosionRatios = [successfulResults.corrosionRatio];
                
                % Get unique environments and their data
                uniqueEnvs = unique(environments);
                groupData = {};
                groupLabels = {};
                
                for i = 1:length(uniqueEnvs)
                    envMask = strcmp(environments, uniqueEnvs{i});
                    envRatios = corrosionRatios(envMask);
                    if length(envRatios) >= 3  % Need at least 3 points for violin plot
                        groupData{end+1} = envRatios;
                        groupLabels{end+1} = uniqueEnvs{i};
                    end
                end
                
                if length(groupData) >= 2
                    fig = figure('Visible', 'off', 'Position', [100, 100, 1200, 700]);
                    
                    % Create violin-like plots using histograms and curves
                    colors = lines(length(groupData));
                    maxCount = 0;
                    
                    % First pass: determine scale
                    for i = 1:length(groupData)
                        [counts, ~] = hist(groupData{i}, 8);
                        maxCount = max(maxCount, max(counts));
                    end
                    
                    hold on;
                    for i = 1:length(groupData)
                        data = groupData{i};
                        
                        % Create histogram
                        [counts, centers] = hist(data, 8);
                        
                        % Normalize and create violin shape
                        normCounts = counts / maxCount * 0.4; % Scale for width
                        
                        % Plot left side of violin
                        xLeft = i - normCounts;
                        plot(xLeft, centers, 'Color', colors(i,:), 'LineWidth', 2);
                        
                        % Plot right side of violin
                        xRight = i + normCounts;
                        plot(xRight, centers, 'Color', colors(i,:), 'LineWidth', 2);
                        
                        % Fill the violin
                        for j = 1:length(centers)
                            plot([xLeft(j), xRight(j)], [centers(j), centers(j)], ...
                                'Color', colors(i,:), 'LineWidth', 1, 'LineStyle', '-');
                        end
                        
                        % Add median line
                        medianVal = median(data);
                        plot([i-0.4, i+0.4], [medianVal, medianVal], 'k-', 'LineWidth', 3);
                        
                        % Add individual data points
                        jitter = (rand(size(data)) - 0.5) * 0.1;
                        scatter(i + jitter, data, 20, colors(i,:), 'filled', 'alpha', 0.6);
                    end
                    
                    hold off;
                    
                    % Formatting
                    set(gca, 'XTick', 1:length(groupLabels), 'XTickLabel', groupLabels);
                    xtickangle(45);
                    title('Detailed Distribution Analysis (Violin Plots)', 'FontSize', 14, 'FontWeight', 'bold');
                    ylabel('Corrosion Ratio (%)', 'FontSize', 12);
                    xlabel('Environment Groups', 'FontSize', 12);
                    grid on;
                    
                    % Add statistics
                    statsText = 'Distribution Statistics: ';
                    for i = 1:length(groupData)
                        q25 = prctile(groupData{i}, 25);
                        q75 = prctile(groupData{i}, 75);
                        statsText = [statsText sprintf('%s: Median=%.1f%%, IQR=%.1f%%  ', ...
                            groupLabels{i}, median(groupData{i}), q75-q25)];
                    end
                    
                    annotation('textbox', [0.02, 0.02, 0.96, 0.08], 'String', statsText, ...
                        'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black');
                    
                    saveas(fig, fullfile(statsFolder, 'ViolinPlots.png'));
                    print(fig, fullfile(statsFolder, 'ViolinPlots_HiRes.png'), '-dpng', '-r300');
                    close(fig);
                    
                    logMessage(app, 'Violin plots created successfully');
                end
            catch ME
                logMessage(app, sprintf('Error creating violin plots: %s', ME.message));
            end
        end
        
        function createStatisticalSummary(app, successfulResults, statsFolder)
            % Create clean statistical summary with error bars
            try
                environments = {successfulResults.environment};
                corrosionRatios = [successfulResults.corrosionRatio];
                avgColors = [successfulResults.averageColor];
                
                uniqueEnvs = unique(environments);
                
                if length(uniqueEnvs) >= 2
                    % Calculate statistics for each group
                    meanCorr = zeros(1, length(uniqueEnvs));
                    stdCorr = zeros(1, length(uniqueEnvs));
                    meanColor = zeros(1, length(uniqueEnvs));
                    stdColor = zeros(1, length(uniqueEnvs));
                    sampleSizes = zeros(1, length(uniqueEnvs));
                    
                    for i = 1:length(uniqueEnvs)
                        envMask = strcmp(environments, uniqueEnvs{i});
                        envCorr = corrosionRatios(envMask);
                        envColor = avgColors(envMask);
                        
                        meanCorr(i) = mean(envCorr);
                        stdCorr(i) = std(envCorr);
                        meanColor(i) = mean(envColor);
                        stdColor(i) = std(envColor);
                        sampleSizes(i) = length(envCorr);
                    end
                    
                    fig = figure('Visible', 'off', 'Position', [100, 100, 1200, 500]);
                    
                    % Subplot 1: Corrosion with error bars
                    subplot(1, 2, 1);
                    b1 = bar(meanCorr, 'FaceColor', [0.2, 0.6, 0.8], 'EdgeColor', 'black');
                    hold on;
                    errorbar(1:length(uniqueEnvs), meanCorr, stdCorr, 'k.', 'LineWidth', 2, 'MarkerSize', 10);
                    
                    % Add sample size labels on bars
                    for i = 1:length(uniqueEnvs)
                        text(i, meanCorr(i) + stdCorr(i) + max(meanCorr)*0.05, ...
                            sprintf('n=%d', sampleSizes(i)), 'HorizontalAlignment', 'center', ...
                            'FontWeight', 'bold', 'FontSize', 10);
                    end
                    
                    set(gca, 'XTickLabel', uniqueEnvs);
                    xtickangle(45);
                    title('Mean Corrosion Ratio (±1 SD)', 'FontSize', 12, 'FontWeight', 'bold');
                    ylabel('Corrosion Ratio (%)', 'FontSize', 11);
                    grid on;
                    hold off;
                    
                    % Subplot 2: Average color with error bars
                    subplot(1, 2, 2);
                    b2 = bar(meanColor, 'FaceColor', [0.8, 0.4, 0.2], 'EdgeColor', 'black');
                    hold on;
                    errorbar(1:length(uniqueEnvs), meanColor, stdColor, 'k.', 'LineWidth', 2, 'MarkerSize', 10);
                    
                    % Add sample size labels on bars
                    for i = 1:length(uniqueEnvs)
                        text(i, meanColor(i) + stdColor(i) + max(meanColor)*0.05, ...
                            sprintf('n=%d', sampleSizes(i)), 'HorizontalAlignment', 'center', ...
                            'FontWeight', 'bold', 'FontSize', 10);
                    end
                    
                    set(gca, 'XTickLabel', uniqueEnvs);
                    xtickangle(45);
                    title('Mean Average Color (±1 SD)', 'FontSize', 12, 'FontWeight', 'bold');
                    ylabel('Average Color Value', 'FontSize', 11);
                    grid on;
                    hold off;
                    
                    sgtitle('Statistical Summary by Environment Groups', 'FontSize', 14, 'FontWeight', 'bold');
                    
                    saveas(fig, fullfile(statsFolder, 'StatisticalSummary.png'));
                    print(fig, fullfile(statsFolder, 'StatisticalSummary_HiRes.png'), '-dpng', '-r300');
                    close(fig);
                    
                    logMessage(app, 'Statistical summary created successfully');
                end
            catch ME
                logMessage(app, sprintf('Error creating statistical summary: %s', ME.message));
            end
        end
        
        function createGroupBoxPlots(app, successfulResults, statsFolder)
            % Create box plots showing corrosion distribution by environment groups
            try
                environments = {successfulResults.environment};
                corrosionRatios = [successfulResults.corrosionRatio];
                
                % Get unique environments and their data
                uniqueEnvs = unique(environments);
                groupData = {};
                groupLabels = {};
                
                for i = 1:length(uniqueEnvs)
                    envMask = strcmp(environments, uniqueEnvs{i});
                    envRatios = corrosionRatios(envMask);
                    if length(envRatios) >= 2  % Need at least 2 points for meaningful box plot
                        groupData{end+1} = envRatios;
                        groupLabels{end+1} = uniqueEnvs{i};
                    end
                end
                
                if length(groupData) >= 2
                    fig = figure('Visible', 'off', 'Position', [100, 100, 1000, 600]);
                    
                    % Create box plot
                    boxData = [];
                    boxGroups = [];
                    for i = 1:length(groupData)
                        boxData = [boxData groupData{i}];
                        boxGroups = [boxGroups repmat(i, 1, length(groupData{i}))];
                    end
                    
                    boxplot(boxData, boxGroups, 'Labels', groupLabels);
                    title('Corrosion Distribution by Environment Groups', 'FontSize', 14, 'FontWeight', 'bold');
                    ylabel('Corrosion Ratio (%)', 'FontSize', 12);
                    xlabel('Environment Groups', 'FontSize', 12);
                    grid on;
                    
                    % Rotate x-axis labels for better readability
                    xtickangle(45);
                    
                    % Add statistics text
                    statsText = 'Statistics: ';
                    for i = 1:length(groupData)
                        statsText = [statsText sprintf('%s: μ=%.2f%%, σ=%.2f%% (n=%d)  ', ...
                            groupLabels{i}, mean(groupData{i}), std(groupData{i}), length(groupData{i}))];
                    end
                    
                    annotation('textbox', [0.02, 0.02, 0.96, 0.08], 'String', statsText, ...
                        'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black');
                    
                    saveas(fig, fullfile(statsFolder, 'GroupBoxPlots.png'));
                    print(fig, fullfile(statsFolder, 'GroupBoxPlots_HiRes.png'), '-dpng', '-r300');
                    close(fig);
                    
                    logMessage(app, 'Box plots created successfully');
                end
            catch ME
                logMessage(app, sprintf('Error creating box plots: %s', ME.message));
            end
        end
        
        function createCorrosionHeatmap(app, successfulResults, statsFolder)
            % Create heatmap showing corrosion patterns
            try
                steelNumbers = [successfulResults.carbonSteelNumber];
                environments = {successfulResults.environment};
                corrosionRatios = [successfulResults.corrosionRatio];
                
                % Create grid for heatmap
                uniqueEnvs = unique(environments);
                uniqueSteel = unique(steelNumbers);
                
                if length(uniqueEnvs) >= 2 && length(uniqueSteel) >= 2
                    % Create matrix for heatmap
                    heatmapData = NaN(length(uniqueEnvs), length(uniqueSteel));
                    
                    for i = 1:length(successfulResults)
                        envIdx = find(strcmp(uniqueEnvs, environments{i}));
                        steelIdx = find(uniqueSteel == steelNumbers(i));
                        heatmapData(envIdx, steelIdx) = corrosionRatios(i);
                    end
                    
                    fig = figure('Visible', 'off', 'Position', [100, 100, 1200, 800]);
                    
                    % Create heatmap
                    imagesc(heatmapData);
                    colormap(hot);
                    colorbar;
                    
                    % Set labels
                    set(gca, 'XTick', 1:length(uniqueSteel), 'XTickLabel', uniqueSteel);
                    set(gca, 'YTick', 1:length(uniqueEnvs), 'YTickLabel', uniqueEnvs);
                    
                    title('Corrosion Intensity Heatmap', 'FontSize', 14, 'FontWeight', 'bold');
                    xlabel('Carbon Steel Number', 'FontSize', 12);
                    ylabel('Environment Groups', 'FontSize', 12);
                    
                    % Add text annotations for values
                    for i = 1:size(heatmapData, 1)
                        for j = 1:size(heatmapData, 2)
                            if ~isnan(heatmapData(i, j))
                                text(j, i, sprintf('%.1f%%', heatmapData(i, j)), ...
                                    'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', 'white');
                            end
                        end
                    end
                    
                    saveas(fig, fullfile(statsFolder, 'CorrosionHeatmap.png'));
                    print(fig, fullfile(statsFolder, 'CorrosionHeatmap_HiRes.png'), '-dpng', '-r300');
                    close(fig);
                    
                    logMessage(app, 'Corrosion heatmap created successfully');
                end
            catch ME
                logMessage(app, sprintf('Error creating heatmap: %s', ME.message));
            end
        end
        
        function createCorrelationAnalysis(app, successfulResults, statsFolder)
            % Create correlation analysis between different parameters
            try
                steelNumbers = [successfulResults.carbonSteelNumber];
                corrosionRatios = [successfulResults.corrosionRatio];
                avgColors = [successfulResults.averageColor];
                
                if length(successfulResults) >= 5  % Need enough data for meaningful correlation
                    fig = figure('Visible', 'off', 'Position', [100, 100, 1200, 400]);
                    
                    % Subplot 1: Steel Number vs Corrosion
                    subplot(1, 3, 1);
                    scatter(steelNumbers, corrosionRatios, 50, 'filled', 'alpha', 0.7);
                    xlabel('Carbon Steel Number');
                    ylabel('Corrosion Ratio (%)');
                    title('Steel Number vs Corrosion');
                    grid on;
                    
                    % Add correlation coefficient
                    r1 = corrcoef(steelNumbers, corrosionRatios);
                    text(0.05, 0.95, sprintf('r = %.3f', r1(1,2)), 'Units', 'normalized', ...
                        'BackgroundColor', 'white', 'EdgeColor', 'black');
                    
                    % Subplot 2: Average Color vs Corrosion
                    subplot(1, 3, 2);
                    scatter(avgColors, corrosionRatios, 50, 'filled', 'alpha', 0.7);
                    xlabel('Average Color Value');
                    ylabel('Corrosion Ratio (%)');
                    title('Color vs Corrosion');
                    grid on;
                    
                    r2 = corrcoef(avgColors, corrosionRatios);
                    text(0.05, 0.95, sprintf('r = %.3f', r2(1,2)), 'Units', 'normalized', ...
                        'BackgroundColor', 'white', 'EdgeColor', 'black');
                    
                    % Subplot 3: Steel Number vs Average Color
                    subplot(1, 3, 3);
                    scatter(steelNumbers, avgColors, 50, 'filled', 'alpha', 0.7);
                    xlabel('Carbon Steel Number');
                    ylabel('Average Color Value');
                    title('Steel Number vs Color');
                    grid on;
                    
                    r3 = corrcoef(steelNumbers, avgColors);
                    text(0.05, 0.95, sprintf('r = %.3f', r3(1,2)), 'Units', 'normalized', ...
                        'BackgroundColor', 'white', 'EdgeColor', 'black');
                    
                    sgtitle('Parameter Correlation Analysis', 'FontSize', 14, 'FontWeight', 'bold');
                    
                    saveas(fig, fullfile(statsFolder, 'CorrelationAnalysis.png'));
                    print(fig, fullfile(statsFolder, 'CorrelationAnalysis_HiRes.png'), '-dpng', '-r300');
                    close(fig);
                    
                    logMessage(app, 'Correlation analysis created successfully');
                end
            catch ME
                logMessage(app, sprintf('Error creating correlation analysis: %s', ME.message));
            end
        end
        
        function createDistributionComparison(app, successfulResults, statsFolder)
            % Create distribution comparison across all groups
            try
                environments = {successfulResults.environment};
                corrosionRatios = [successfulResults.corrosionRatio];
                uniqueEnvs = unique(environments);
                
                if length(uniqueEnvs) >= 2
                    fig = figure('Visible', 'off', 'Position', [100, 100, 1000, 600]);
                    
                    colors = lines(length(uniqueEnvs));
                    hold on;
                    
                    legendEntries = {};
                    for i = 1:length(uniqueEnvs)
                        envMask = strcmp(environments, uniqueEnvs{i});
                        envRatios = corrosionRatios(envMask);
                        
                        if length(envRatios) >= 2
                            % Create histogram
                            [counts, centers] = hist(envRatios, 10);
                            counts = counts / sum(counts);  % Normalize
                            
                            plot(centers, counts, 'o-', 'LineWidth', 2, 'MarkerSize', 6, ...
                                'Color', colors(i,:), 'MarkerFaceColor', colors(i,:));
                            
                            legendEntries{end+1} = sprintf('%s (n=%d)', uniqueEnvs{i}, length(envRatios));
                        end
                    end
                    
                    hold off;
                    title('Corrosion Distribution Comparison', 'FontSize', 14, 'FontWeight', 'bold');
                    xlabel('Corrosion Ratio (%)', 'FontSize', 12);
                    ylabel('Normalized Frequency', 'FontSize', 12);
                    legend(legendEntries, 'Location', 'best');
                    grid on;
                    
                    saveas(fig, fullfile(statsFolder, 'DistributionComparison.png'));
                    print(fig, fullfile(statsFolder, 'DistributionComparison_HiRes.png'), '-dpng', '-r300');
                    close(fig);
                    
                    logMessage(app, 'Distribution comparison created successfully');
                end
            catch ME
                logMessage(app, sprintf('Error creating distribution comparison: %s', ME.message));
            end
        end
    end
    
    % Static method to run the app
    methods (Static)
        function runApp()
            CorrosionAnalyzerApp;
        end
    end
end