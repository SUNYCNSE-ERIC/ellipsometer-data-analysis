 [fileName,pathName] = uigetfile('.txt', 'Open Ellipsometry Sample File');
            fileID = fopen(strcat(pathName, fileName));
            ellipsText = textscan(fileID,'%s',2,'delimiter','\n');
            ellipsData = textscan(fileID,'%f %f %f','delimiter','\t','CollectOutput',1);
            ellips = ellipsData{1,1};
            
            x = ellips(:,1);
            y = ellips(:,2);
            z = ellips(:,3);
            
            F=scatteredInterpolant(x,y,z);
            nres = 1000;
            tx = min(x):((max(x)-min(x))/nres):max(x);
            ty = min(y):((max(y)-min(y))/nres):max(y);
            
            [qx,qy] = meshgrid(tx,ty);
            qz = F(qx,qy);
            
            figure(1)
            mesh(qx,qy,qz)
            hold on;
            axis([min(x) max(x) min(y) max(y) min(z) max(z)])
            