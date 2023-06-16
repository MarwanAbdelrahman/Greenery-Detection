classdef Final_GUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        upload                     matlab.ui.control.Image
        map                        matlab.ui.control.Image
        date                       matlab.ui.control.Label
        cal                        matlab.ui.control.Image
        UIAxes                     matlab.ui.control.UIAxes
        ExportButton               matlab.ui.control.Button
        DroneheightEditFieldLabel  matlab.ui.control.Label
        DroneheightEditField       matlab.ui.control.NumericEditField
        FocallengthEditFieldLabel  matlab.ui.control.Label
        FocallengthEditField       matlab.ui.control.NumericEditField
        Image                      matlab.ui.control.Image
        ButtonGroup                matlab.ui.container.ButtonGroup
        DefaultButton              matlab.ui.control.RadioButton
        CostumButton               matlab.ui.control.RadioButton
        PlantsButton               matlab.ui.control.Button
        panel                      matlab.ui.container.Panel
        Image2                     matlab.ui.control.Image
        Image3                     matlab.ui.control.Image
        Image4                     matlab.ui.control.Image
        Image5                     matlab.ui.control.Image
        Image6                     matlab.ui.control.Image
        Image7                     matlab.ui.control.Image
        Label                      matlab.ui.control.Label
        WarnningPanel              matlab.ui.container.Panel
        ShowdeadareasButton        matlab.ui.control.Button
        ShowdiseasesButton         matlab.ui.control.Button
        SensorhightEditFieldLabel  matlab.ui.control.Label
        SensorhightEditField       matlab.ui.control.NumericEditField
        SensorwidthEditFieldLabel  matlab.ui.control.Label
        SensorwidthEditField       matlab.ui.control.NumericEditField
        RunFASAButton              matlab.ui.control.Button
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Image clicked function: upload
        function uploadImageClicked(app, event)
             global CIR R G B NIR sh sw fl da pc NDVIdead NDVIpoor NDVIgood NDVIgreat Threshold
            [name,path]=uigetfile({'*.tif'},"Farm image");
            CIR=imread([path,name]);
            app.map.Enable="on";
            app.Image.Visible="off";
            imshow(CIR(:,:,1:3),'Parent',app.UIAxes)
            R   = double(CIR(:,:,1));
            G   = double(CIR(:,:,2));
            B   = double(CIR(:,:,3));
            NIR = double(CIR(:,:,4));
            app.date.Text=date;
            
        end

        % Image clicked function: map
        function mapImageClicked(app, event)
            global CIR R G B NIR sh sw fl da pc NDVIdead NDVIpoor NDVIgood NDVIgreat Threshold 
            NDVI = (NIR-R)./(NIR+R);
            GCI  = (NIR)./(G)-1;
            SIPI = (NIR-B)./(NIR-R);
            Threshold = zeros(size(CIR,1),size(CIR,2),3);
            r     = zeros(size(CIR,1),size(CIR,2));
            g     = zeros(size(CIR,1),size(CIR,2));
            b     = zeros(size(CIR,1),size(CIR,2));
            NDVIdead  = NDVI>=-1&NDVI<=0;
            NDVIpoor  = NDVI>0&NDVI<0.33;
            NDVIgood  = NDVI>0.33&NDVI<0.66;
            NDVIgreat = NDVI>=0.66&NDVI<=1;
            warn=;
            r(NDVIdead)=208;
            g(NDVIdead)=34;
            b(NDVIdead)=15;
            r(NDVIpoor)=218;
            g(NDVIpoor)=181;
            b(NDVIpoor)=33;
            r(NDVIgood)=253;
            g(NDVIgood)=253;
            b(NDVIgood)=3;
            r(NDVIgreat)=147;
            g(NDVIgreat)=191;
            b(NDVIgreat)=0;
            Threshold(:,:,1)=r;
            Threshold(:,:,2)=g;
            Threshold(:,:,3)=b;
            Warn=0;
            Diseases_low  = SIPI>0 & SIPI<0.8;
            Diseases_high = SIPI>1.8 & SIPI<2;
            Diseases      = Diseases_low | Diseases_high;
            if all(NDVIdead==0,'all') && all(Diseases==0,'all')
                
            elseif any(NDVIdead~=0,'all')
                
                Warn=Warn+1;
                if any(Diseases==1,'all')
                    
                    Warn=Warn+1;
                end
            end
        end
        imshow(Threshold,'Parent',app.UIAxes)
        app.Label.text=string(warn);
        switch warn
        case 1
            disp("Congrats!! your plant is in a good health.")
            disp("Hooray! Zero Warnings.")
        case 2
            if warn == 3
                app.ShowdeadareasButton.visable='on';
            end
            
        case 3
            app.ShowdiseasesButton.visable='on';
    end
        end

        % Button pushed function: ExportButton
        function ExportButtonPushed(app, event)
            global CIR  G B NIR sh sw fl da pc NDVIdead NDVIpoor NDVIgood  Threshold
            GSD_h = (da*10*sh)/(fl*0.1*size(CIR,1));
            GSD_w = (da*10*sw)/(fl*0.1*size(CIR,2));
            GSD   = (GSD_h>GSD_w)*GSD_h+(GSD_w>GSD_h)*GSD_w;
            [r_good,c_good] = find(NDVIgood==1);
            [r_poor,c_poor] = find(NDVIpoor==1);
            Coordinates = [round([r_good,c_good]*GSD,5);round([r_poor,c_poor]*GSD,5)];
            Water_needed = round([(1-NDVI(NDVIgood))*pc;(1-NDVI(NDVIpoor))*pc],5);
            SAP_amount   = round(Water_needed/301,5);
            GCI_Fert     = [GCI(NDVIgood);GCI(NDVIpoor)];
            Fertilizers  = round(Water_needed./(0.46*Water_needed./((3.82+(max(GCI,[],'all')))-GCI_Fert)),5);
            imwrite(Threshold/255,'Colorized Threshold Map.jpg')
            Data = table(Coordinates,Water_needed,SAP_amount,Fertilizers);
            writetable(Data,'Coordinates.xlsx')
            
        end

        % Button pushed function: PlantsButton
        function PlantsButtonPushed(app, event)
              global pc          
            app.panel.Visible="off";
            pc=0.6806944444
        end

        % Image clicked function: Image2
        function Image2Clicked(app, event)
            global pc          
            app.panel.Visible="off";
            pc=1.12666667
        end

        % Image clicked function: Image3
        function Image3Clicked(app, event)
             global pc          
            app.panel.Visible="off";
            pc=1.06525
        end

        % Image clicked function: Image4
        function Image4Clicked(app, event)
              global pc          
            app.panel.Visible="off";
            pc=0.938889
        end

        % Image clicked function: Image6
        function Image6Clicked(app, event)
                global pc          
            app.panel.Visible="off";
            pc=0.7041666667
        end

        % Selection changed function: ButtonGroup
        function ButtonGroupSelectionChanged(app, event)
            global sh sw fl da 
            if app.DefaultButton.Value==1
                sh  = 8.0;
                sw  = 13.2;
                fl  = 8.8;
                da  = 4500;
                app.DroneheightEditField.Enable="off";
                app.DroneheightEditField.Value=4500;
                app.FocallengthEditField.Enable="off";
                app.FocallengthEditField.Value=8.8;
                app.SensorhightEditField.Enable="off";
                app.SensorhightEditField.value=8.0;
                app.SensorwidthEditField.Enable="off";
                app.SensorwidthEditField.Value=13.2;
            else              
                app.DroneheightEditField.Enable="on";
                app.DroneheightEditField.Value=0;
                app.FocallengthEditField.Enable="on";
                app.FocallengthEditField.Value=0;
                app.SensorhightEditField.Enable="on";
                app.SensorwidthEditField.Enable="on";
                sh  = app.SensorhightEditField.value;
                sw  = app.SensorwidthEditField.vslue;
                fl  = app.FocallengthEditField.value;
                da  = app.DroneheightEditField.value;
            end
        end

        % Callback function
        function Image7Clicked(app, event)
            app.noti.Visible="on";
            
        end

        % Image clicked function: Image7
        function Image7Clicked2(app, event)
            app.WarnningPanel.Visible="on";
        end

        % Button pushed function: ShowdiseasesButton
        function ShowdiseasesButtonPushed(app, event)
            imshow(~Diseases)
        end

        % Button pushed function: ShowdeadareasButton
        function ShowdeadareasButtonPushed(app, event)
            imshow(~NDVIdead)
        end

        % Button pushed function: RunFASAButton
        function RunFASAButtonPushed(app, event)
            Project_Final_Demo
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 693 480];
            app.UIFigure.Name = 'UI Figure';

            % Create upload
            app.upload = uiimage(app.UIFigure);
            app.upload.ImageClickedFcn = createCallbackFcn(app, @uploadImageClicked, true);
            app.upload.Position = [560 31 100 100];
            app.upload.ImageSource = 'upload.png';

            % Create map
            app.map = uiimage(app.UIFigure);
            app.map.ImageClickedFcn = createCallbackFcn(app, @mapImageClicked, true);
            app.map.Enable = 'off';
            app.map.Tooltip = {'View the NDVI map'};
            app.map.Position = [41 31 100 100];
            app.map.ImageSource = 'unnamed.png';

            % Create date
            app.date = uilabel(app.UIFigure);
            app.date.Position = [555 430 95 22];
            app.date.Text = '';

            % Create cal
            app.cal = uiimage(app.UIFigure);
            app.cal.Position = [508 423 45 36];
            app.cal.ImageSource = 'calendar.png';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.PlotBoxAspectRatio = [1.69321533923304 1 1];
            app.UIAxes.YTick = [0 0.2 0.4 0.6 0.8 1];
            app.UIAxes.Visible = 'off';
            app.UIAxes.Position = [21 164 490 299];

            % Create ExportButton
            app.ExportButton = uibutton(app.UIFigure, 'push');
            app.ExportButton.ButtonPushedFcn = createCallbackFcn(app, @ExportButtonPushed, true);
            app.ExportButton.Tooltip = {'Save image for the map'};
            app.ExportButton.Position = [533 157 100 22];
            app.ExportButton.Text = 'Export';

            % Create DroneheightEditFieldLabel
            app.DroneheightEditFieldLabel = uilabel(app.UIFigure);
            app.DroneheightEditFieldLabel.HorizontalAlignment = 'right';
            app.DroneheightEditFieldLabel.Position = [511 323 74 22];
            app.DroneheightEditFieldLabel.Text = 'Drone height';

            % Create DroneheightEditField
            app.DroneheightEditField = uieditfield(app.UIFigure, 'numeric');
            app.DroneheightEditField.Limits = [0 Inf];
            app.DroneheightEditField.Enable = 'off';
            app.DroneheightEditField.Position = [600 323 48 22];
            app.DroneheightEditField.Value = 450;

            % Create FocallengthEditFieldLabel
            app.FocallengthEditFieldLabel = uilabel(app.UIFigure);
            app.FocallengthEditFieldLabel.HorizontalAlignment = 'right';
            app.FocallengthEditFieldLabel.Position = [511 289 71 22];
            app.FocallengthEditFieldLabel.Text = 'Focal length';

            % Create FocallengthEditField
            app.FocallengthEditField = uieditfield(app.UIFigure, 'numeric');
            app.FocallengthEditField.Enable = 'off';
            app.FocallengthEditField.Position = [600 289 48 22];
            app.FocallengthEditField.Value = 14;

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [35 144 469 280];
            app.Image.ImageSource = 'photo.png';

            % Create ButtonGroup
            app.ButtonGroup = uibuttongroup(app.UIFigure);
            app.ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
            app.ButtonGroup.Position = [534 356 100 53];

            % Create DefaultButton
            app.DefaultButton = uiradiobutton(app.ButtonGroup);
            app.DefaultButton.Text = 'Default';
            app.DefaultButton.Position = [11 26 60 22];
            app.DefaultButton.Value = true;

            % Create CostumButton
            app.CostumButton = uiradiobutton(app.ButtonGroup);
            app.CostumButton.Text = 'Costum';
            app.CostumButton.Position = [11 4 65 22];

            % Create PlantsButton
            app.PlantsButton = uibutton(app.UIFigure, 'push');
            app.PlantsButton.ButtonPushedFcn = createCallbackFcn(app, @PlantsButtonPushed, true);
            app.PlantsButton.Position = [533 188 100 22];
            app.PlantsButton.Text = 'Plants';

            % Create panel
            app.panel = uipanel(app.UIFigure);
            app.panel.ForegroundColor = [0.149 0.149 0.149];
            app.panel.TitlePosition = 'centertop';
            app.panel.Title = 'Choose plant';
            app.panel.Visible = 'off';
            app.panel.BackgroundColor = [0.902 0.902 0.902];
            app.panel.FontName = 'Arial Narrow';
            app.panel.FontWeight = 'bold';
            app.panel.FontSize = 18;
            app.panel.Position = [198 113 297 256];

            % Create Image2
            app.Image2 = uiimage(app.panel);
            app.Image2.ImageClickedFcn = createCallbackFcn(app, @Image2Clicked, true);
            app.Image2.Position = [11 114 100 109];
            app.Image2.ImageSource = 'wheet.png';

            % Create Image3
            app.Image3 = uiimage(app.panel);
            app.Image3.ImageClickedFcn = createCallbackFcn(app, @Image3Clicked, true);
            app.Image3.Position = [199 129 93 94];
            app.Image3.ImageSource = 'tom.png';

            % Create Image4
            app.Image4 = uiimage(app.panel);
            app.Image4.ImageClickedFcn = createCallbackFcn(app, @Image4Clicked, true);
            app.Image4.Position = [11 15 90 100];
            app.Image4.ImageSource = 'corn.png';

            % Create Image5
            app.Image5 = uiimage(app.panel);
            app.Image5.Position = [192 5 100 100];
            app.Image5.ImageSource = 'pot.png';

            % Create Image6
            app.Image6 = uiimage(app.panel);
            app.Image6.ImageClickedFcn = createCallbackFcn(app, @Image6Clicked, true);
            app.Image6.Position = [100 60 100 100];
            app.Image6.ImageSource = 'peas.png';

            % Create Image7
            app.Image7 = uiimage(app.UIFigure);
            app.Image7.ImageClickedFcn = createCallbackFcn(app, @Image7Clicked2, true);
            app.Image7.Position = [11 430 34 36];
            app.Image7.ImageSource = 'not.png';

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.FontSize = 18;
            app.Label.FontWeight = 'bold';
            app.Label.FontColor = [1 0 0];
            app.Label.Position = [35 451 25 22];
            app.Label.Text = '0';

            % Create WarnningPanel
            app.WarnningPanel = uipanel(app.UIFigure);
            app.WarnningPanel.ForegroundColor = [0.851 0.3255 0.098];
            app.WarnningPanel.Title = 'Warnning';
            app.WarnningPanel.Visible = 'off';
            app.WarnningPanel.FontName = 'Franklin Gothic Book';
            app.WarnningPanel.FontAngle = 'italic';
            app.WarnningPanel.FontWeight = 'bold';
            app.WarnningPanel.Position = [182 11 340 124];

            % Create ShowdeadareasButton
            app.ShowdeadareasButton = uibutton(app.WarnningPanel, 'push');
            app.ShowdeadareasButton.ButtonPushedFcn = createCallbackFcn(app, @ShowdeadareasButtonPushed, true);
            app.ShowdeadareasButton.Position = [12.5 59 114 22];
            app.ShowdeadareasButton.Text = 'Show dead areas';

            % Create ShowdiseasesButton
            app.ShowdiseasesButton = uibutton(app.WarnningPanel, 'push');
            app.ShowdiseasesButton.ButtonPushedFcn = createCallbackFcn(app, @ShowdiseasesButtonPushed, true);
            app.ShowdiseasesButton.Position = [197 59 111 22];
            app.ShowdiseasesButton.Text = 'Show diseases';

            % Create SensorhightEditFieldLabel
            app.SensorhightEditFieldLabel = uilabel(app.UIFigure);
            app.SensorhightEditFieldLabel.HorizontalAlignment = 'right';
            app.SensorhightEditFieldLabel.Position = [512 259 73 22];
            app.SensorhightEditFieldLabel.Text = 'Sensor hight';

            % Create SensorhightEditField
            app.SensorhightEditField = uieditfield(app.UIFigure, 'numeric');
            app.SensorhightEditField.Enable = 'off';
            app.SensorhightEditField.Position = [600 259 48 22];

            % Create SensorwidthEditFieldLabel
            app.SensorwidthEditFieldLabel = uilabel(app.UIFigure);
            app.SensorwidthEditFieldLabel.HorizontalAlignment = 'right';
            app.SensorwidthEditFieldLabel.Position = [513 227 75 22];
            app.SensorwidthEditFieldLabel.Text = 'Sensor width';

            % Create SensorwidthEditField
            app.SensorwidthEditField = uieditfield(app.UIFigure, 'numeric');
            app.SensorwidthEditField.Enable = 'off';
            app.SensorwidthEditField.Position = [600 227 48 22];

            % Create RunFASAButton
            app.RunFASAButton = uibutton(app.UIFigure, 'push');
            app.RunFASAButton.ButtonPushedFcn = createCallbackFcn(app, @RunFASAButtonPushed, true);
            app.RunFASAButton.Position = [169 444 203 22];
            app.RunFASAButton.Text = 'Run FASA';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Final_GUI

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end