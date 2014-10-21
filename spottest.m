[fileName,pathName] = uigetfile('.spot', 'Open Spot File');
            M = csvread(strcat(pathName,fileName));
            
            c = figure(1);
            set(c, 'Position', [600 300 300 300]);
            contourf(M(1,2:end),M(2:end,1),M(2:end,2:end));
            xlabel('X position (cm)');
            ylabel('Y position (cm)');
            title(fileName);
            axis equal;
            
            Msize = size(M);
            l = 1;
            for i=2:Msize(2)
                for j=2:Msize(1)
                    x(l) = M(1,i);
                    y(l) = M(j,1);
                    z(l) = M(j,i);
                    l=l+1;
                end
            end
            
            SpotIntrp = scatteredInterpolant(x',y',z');
            
            nres = 1000;
            tx = min(x):((max(x)-min(x))/nres):max(x);
            ty = min(y):((max(y)-min(y))/nres):max(y);
            
            [qx,qy] = meshgrid(tx,ty);
            qz = SpotIntrp(qx,qy);
            
            figure(2)
            mesh(qx,qy,qz)
            hold on;
            axis([min(x) max(x) min(y) max(y) min(z) max(z)])
            
            numspots = 10;
            zbin = linspace(min(z),max(z),numspots);
            xybin = cell(1,numspots);
            eps = 0.005;
            
            for i=1:nres
                for j=1:nres
                    for k=1:numspots
                        diff = qz(i,j)-zbin(k);
                        if abs(diff) <= eps 
                            xybin{k} = cat(1,xybin{k},[qx(i,j) qy(i,j)]);
                            break
                        elseif diff < 0
                            break
                        end
                    end
                end
            end
            