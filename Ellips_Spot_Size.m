choice = menu('Thickness Loss Data Analysis Program (TLDAP)','Log Spot','View Spot','View Sample','View Sample Cross Section','Plot Spot Shape','Plot S Curve','Exit');

% Closes menu if the user chooses the exit open or hits the 'x'
while choice ~= 7 & choice ~= 0
    
    switch choice
        
        %Log Spot
        case 1 
            [fileName,pathName] = uigetfile('.txt', 'Open Ellipsometry Sample File');
            fileID = fopen(strcat(pathName, fileName));
            ellipsText = textscan(fileID,'%s',2,'delimiter','\n');
            ellipsData = textscan(fileID,'%f %f %f','delimiter','\t','CollectOutput',1);
            ellips = ellipsData{1,1};

            X1 = unique(ellips(:,1));
            tiger=X1;
            Y1 = unique(ellips(:,2));
            lion=Y1;
            z = griddata(ellips(:,1),ellips(:,2),ellips(:,3),X1,Y1');
            
            a = figure(1);
            set(a, 'Position', [600 300 200 600]);
            contourf(X1,Y1,z,min(min(z)):(60-min(min(z)))/10:60);
            colorbar;
            xlabel('X position (cm)');
            ylabel('Y position (cm)');
            title('Choose bounds of spot');
            axis([min(X1) max(X1) min(Y1) max(Y1)]);
            axis equal;
            [m,n] = ginput(2);
            
            if m(2) < m(1)
                m = flipud(m);
            end
            
            if n(2) < n(1)
                n = flipud(n);
            end
            
            [m1 m1] = min(abs(X1 - m(1)));
            [m2 m2] = min(abs(X1 - m(2)));
            [n1 n1] = min(abs(Y1 - n(1)));
            [n2 n2] = min(abs(Y1 - n(2)));
            X2 = X1(m1:m2);
            Y2 = Y1(n1:n2);
            
            b = figure(1);
            set(a, 'Position', [600 300 300 300]);
            contourf(X2,Y2,z(n1:n2,m1:m2));
            colorbar;
            xlabel('X position (cm)');
            ylabel('Y position (cm)');
            title({'Choose first 4 spots at background level','Choose final 5th spot for center of exposure spot'});
            axis([min(X2) max(X2) min(Y2) max(Y2)]);
            axis equal;
            [x,y] = ginput(5);
            points = [];
            dragon=[];
            godzilla=[];
         
            for i = 1:4
                [dino1,dino2] = min(abs(x(i)-X1));  %getting index of x co-ordinates, dino2 is the index
                [trex1,trex2] = min(abs(y(i)-Y1)); %getting index of y co-ordinates, trex2 is the index
                dragon = [dragon;z(trex2, dino2)]; %z of the picked points from the x and y indexes extracted earlier
                godzilla=[godzilla;x(i),y(i)]; %the picked X,Ys
            end
            pivot=[x(5), y(5)];
            
            %Weighted Averaging Start
          
            for i=1:4
                weight(i)=pdist([godzilla(i,:);pivot],'euclidean');
            end
            
            weight2=mean(weight);
            
            for i=1:4
                temp_weight(i)=weight(i)/weight2;
            end
            
            indvl_weight = temp_weight.^-1;
            
            mammoth=((transpose(indvl_weight)).*dragon);
            final_weight=sum(mammoth)/sum(indvl_weight);
            
            fprintf('---------------------------------------------------\n');
            disp('User picked four points with z:')
            disp(dragon)
            disp(points)
            disp('4 points weighted averaged wrt user-picked pivot spot')
            p = mean(dragon);
            
            fprintf('---------------------------------------------------\n');
            fprintf('THE FINAL WEIGHTED AVERAGE IS %f\n',final_weight);
            fprintf('---------------------------------------------------\n');
            
            %Weighted Averaging End
            
            prompt = {'Resist:','Beam Energy (eV):','Dose (uC/cm2):','Dark Loss (nm):'};
            dlg_title = 'Input Spot Exposure Settings';
            answer = inputdlg(prompt,dlg_title);
            resist = answer(1);
            energy = answer(2);
            dose = answer(3);
            d_loss = answer(4);
            
            set(b, 'PaperPositionMode','auto');
            print('-dpng','-r0',strcat('Ellipsometry DATA/',resist{1},'/',energy{1},'_',dose{1},'.png'));
            
            spot = [0 X2'];
            spot_temp = [Y2 z(n1:n2,m1:m2)];
            spot = [spot; spot_temp];
            
            data = [str2double(dose{1}) (p+str2double(d_loss))];
            
            dlmwrite(strcat('Ellipsometry DATA/',resist{1},'/',energy{1},'_',dose{1},'.spot'),spot);
            dlmwrite(strcat('Ellipsometry DATA/',resist{1},'/',energy{1},'.data'),data,'-append','newline', 'pc');
        
        %View Spot
        case 2
            [fileName,pathName] = uigetfile('.spot', 'Open Spot File');
            M = csvread(strcat(pathName,fileName));
            
            c = figure(1);
            set(c, 'Position', [600 300 300 300]);
            contourf(M(1,2:end),M(2:end,1),M(2:end,2:end));
            xlabel('X position (cm)');
            ylabel('Y position (cm)');
            title(fileName);
            axis([min(X2) max(X2) min(Y2) max(Y2)]);
            axis equal;
            waitfor(c);
        
        %View Sample
        case 3 
            [fileName,pathName] = uigetfile('.txt', 'Open Ellipsometry Sample File');
            fileID = fopen(strcat(pathName, fileName));
            ellipsText = textscan(fileID,'%s',2,'delimiter','\n');
            ellipsData = textscan(fileID,'%f %f %f','delimiter','\t','CollectOutput',1);
            ellips = ellipsData{1,1};

            X1 = unique(ellips(:,1));
            Y1 = unique(ellips(:,2));
            z = griddata(ellips(:,1),ellips(:,2),ellips(:,3),X1,Y1');
            
            d = figure(1);
            set(d, 'Position', [600 300 200 600]);
            contourf(X1,Y1,z,min(min(z)):(60-min(min(z)))/10:60);
            colorbar;
            xlabel('X position (cm)');
            ylabel('Y position (cm)');
            title(fileName);
            axis([min(X1) max(X1) min(Y1) max(Y1)]);
            axis equal;
            
            button = questdlg('Would you like to save an image of the sample?');
            if strcmp(button,'Yes')
                prompt = {'Resist:','Sample Name:'};
                dlg_title = 'Sample Settings';
                answer = inputdlg(prompt,dlg_title);
                resist = answer(1);
                sample = answer(2);
            
                set(d, 'PaperPositionMode','auto');
                print('-dpng','-r0',strcat('Ellipsometry DATA/',resist{1},'/',sample{1},'.png'));
            end
            
            waitfor(d);
            
        %View Sample Cross Section
        case 4
            [fileName,pathName] = uigetfile('.txt', 'Open Ellipsometry Sample File');
            fileID = fopen(strcat(pathName, fileName));
            ellipsText = textscan(fileID,'%s',2,'delimiter','\n');
            ellipsData = textscan(fileID,'%f %f %f','delimiter','\t','CollectOutput',1);
            ellips = ellipsData{1,1};

            X1 = unique(ellips(:,1));
            Y1 = unique(ellips(:,2));
            z = griddata(ellips(:,1),ellips(:,2),ellips(:,3),X1,Y1');
            
            e = figure(1);
            set(e, 'Position', [600 300 200 600]);
            contourf(X1,Y1,z,min(min(z)):(60-min(min(z)))/10:60);
            colorbar;
            xlabel('X position (cm)');
            ylabel('Y position (cm)');
            title(fileName);
            axis([min(X1) max(X1) min(Y1) max(Y1)]);
            axis equal;
            [m,n] = ginput(1);

            cross = interp2(X1,Y1',z,m,Y1);
            f = figure(1);
            set(f, 'Position', [600 300 600 600]);
            plot(Y1,cross);
            xlabel('Y position (cm)');
            ylabel('Thickness (nm)');
            axis([min(Y1) max(Y1) 0 60]);
            axis normal;
            
            button = questdlg('Would you like to save an image of the cross section?');
            if strcmp(button,'Yes')
                prompt = {'Resist:','Sample Name:'};
                dlg_title = 'Sample Settings';
                answer = inputdlg(prompt,dlg_title);
                resist = answer(1);
                sample = answer(2);
            
                set(f, 'PaperPositionMode','auto');
                print('-dpng','-r0',strcat('Ellipsometry DATA/',resist{1},'/',sample{1},'_Cross Section','.png'));
            end
            
            waitfor(f);
        
        %Plot Spot Shape
        case 5
            [fileName,pathName] = uigetfile('.spot', 'Open Spot Files', 'MultiSelect', 'on');
            [crossFileName,crossPathName] = uigetfile('.cross', 'Open Cross Section File');
            C = csvread(strcat(crossPathName,crossFileName));
            
            doseRange = [];
            left = [];
            right = [];
            
            for spot = fileName
                spot = spot{1};
                splitSpot = strread(spot,'%s','delimiter','_');
                energy = str2double(splitSpot{1});
                splitSpot = splitSpot{2};
                splitSpot = strread(splitSpot,'%s','delimiter','.');
                dose = str2double(strcat(splitSpot{1},'.',splitSpot{2}));
                xCross = find(C == dose);
                xCross = C(xCross,2);
        
                M = csvread(strcat(pathName,spot));
                xRange = M(1,2:end);
                yRange = M(2:end,1);
                yRange = yRange - (((max(yRange) - min(yRange)) / 2)+min(yRange));
                M = M(2:end,2:end);
                [xM xM] = min(abs(xRange - xCross));
                M = M(:,xM);
                M = M';
                
                i = figure(1);
                set(i, 'Position', [600 300 600 600]);
                plot(yRange, M);
                ylabel('Photoresist Thickness (nm)');
                xlabel('Y position (cm)');
                axis normal;
                hold all;
            end
            
            [a,thickness] = ginput(1);
            
            for spot = fileName
                spot = spot{1};
                splitSpot = strread(spot,'%s','delimiter','_');
                energy = str2double(splitSpot{1});
                splitSpot = splitSpot{2};
                splitSpot = strread(splitSpot,'%s','delimiter','.');
                dose = str2double(strcat(splitSpot{1},'.',splitSpot{2}));
                xCross = find(C == dose);
                xCross = C(xCross,2);
        
                M = csvread(strcat(pathName,spot));
                xRange = M(1,2:end);
                yRange = M(2:end,1);
                M = M(2:end,2:end);
                [xM xM] = min(abs(xRange - xCross));
                M = M(:,xM);
                M = M';
                [xi,yi] = polyxpoly(yRange,M,[min(yRange) max(yRange)],[thickness thickness]);
                if isempty(xi) == 0
                    doseRange = [doseRange, dose];
                end
                left = [left (-(max(xi) - min(xi)) / 2)];
                right = [right ((max(xi) - min(xi)) / 2)];
            end
            
            doseRange = abs(doseRange - max(doseRange));
            doseRange = [doseRange doseRange];
            leftRight = [left right];
            
            gussianFit = fit(leftRight',doseRange','gauss2');
            coeff = coeffvalues(gaussianFit);
            FWHM = coeff(3) / 2.35482;
            msgbox(strcat('FWHM value is ',num2str(FWHM * 10),' mm'));
            
            hold off;
            g = figure(1);
            set(g, 'Position', [600 300 600 600]);
            plot(f,leftRight,doseRange);
            ylabel('Y position (cm)');
            xlabel('Dose Range (AU)');
            axis normal;
            
            
        %Plot S Curve
        case 6
            doseRange = [];
            thicknessLoss = [];
            background = [];
            
            [fileName,pathName] = uigetfile('.spot', 'Open Spot Files', 'MultiSelect', 'on');
            [dataFileName,dataPathName] = uigetfile('.data', 'Open Cross Section File');
            C = csvread(strcat(dataPathName,dataFileName));
            
            prompt = {'Nth minimum value, n = '};
            dlg_title = 'Thickness Loss Statistics Settings';
            answer = inputdlg(prompt,dlg_title);
            median = str2double(answer{1});
            
            for spot = fileName
                spot = spot{1};
                splitSpot = strread(spot,'%s','delimiter','_');
                energy = str2double(splitSpot{1});
                splitSpot = splitSpot{2};
                splitSpot = strread(splitSpot,'%s','delimiter','.');
                dose = str2double(strcat(splitSpot{1},'.',splitSpot{2}));
                doseRange = [doseRange, dose];
                M = csvread(strcat(pathName,spot));
                M = M(2:end,2:end);
                
                [svals,idx] = sort(sort(M,1),2);
                thicknessLoss = [thicknessLoss, svals(median)];
                
                xData = find(C == dose,1);
                background = [background, C(xData,2)];
            end
            
            thicknessLoss = background - thicknessLoss;
            
            h = figure(1);
            set(h, 'Position', [600 300 1000 600]);
            semilogx(doseRange,thicknessLoss,'bo');
            xlabel('Dose (uC/cm2)');
            ylabel('Thickness Loss (nm)');
            title(strcat(num2str(energy), ' eV'));
            axis([min(doseRange) max(doseRange) -5 65]);
            
            button = questdlg('Would you like to save an image of the S curve?');
            if strcmp(button,'Yes')
                prompt = {'Resist:','Beam Energy (eV):'};
                dlg_title = 'Sample Settings';
                answer = inputdlg(prompt,dlg_title);
                resist = answer(1);
                energy = answer(2);
            
                set(h, 'PaperPositionMode','auto');
                print('-dpng','-r0',strcat('Ellipsometry DATA/',resist{1},'/',energy{1},'_sCurve','.png'));
            end
            
            dlmwrite(strcat('Ellipsometry DATA/',resist{1},'/',energy{1},'_sCurve.txt'),[doseRange' thicknessLoss']);
            
            waitfor(g);           
    end
    
    %Reopen menu if finished with previous selection
    choice = menu('Thickness Loss Data Analysis Program (TLDAP)','Log Spot','View Spot','View Sample','View Sample Cross Section','Plot Spot Shape','Plot S Curve','Exit');
    
end

fclose('all');