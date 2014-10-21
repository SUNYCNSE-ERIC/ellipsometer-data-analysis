function B = intrpXY(X,Y)
	% INTRPXY - Interpolate data over full length(Y) x length(X) array with input data from axes

	d = zeros(length(Y),length(X));
	B = [];
	center = [(length(Y)+1)/2 (length(X)+1)/2];
	for i=1:length(Y)
		for j=1:length(X)
			d(i,j) = sqrt((i-center(1))^2 + (j-center(2))^2);
		end
	end

	scaleX = scaleDim(X);
	scaleY = scaleDim(Y);

	polyXl = polyfit(scaleX,X(1:floor(center(2))), 2);
	polyXr = polyfit(fliplr(scaleX), X(ceil(center(2)):length(X)), 2);

	polyYu = polyfit(scaleY,Y(1:floor(center(1))), 2);
	polyYd = polyfit(fliplr(scaleY), Y(ceil(center(1)):length(Y)), 2);

	for i=1:length(Y)
		for j=1:length(X)
			
			if i < center(1)
				polyY = polyYu;
			else
				polyY = polyYd;
			end

			if j < center(2)
				polyX = polyXl;
			else
				polyX = polyXr;
			end

			weights = fliplr(abs([i j]-center)./sum(abs([i j]-center)));
			b = d(i,j);
			if (i==center(1)) & (j==center(2))
				weights = [0.5 0.5];
			elseif i==center(1)
				weights = [1 0];
			elseif j==center(2)
				weights = [0 1];
			end
			B(i,j) = weights(1)*(polyY(1)*b^2+polyY(2)*b+polyY(3))+weights(2)*(polyX(1)*b^2+polyX(2)*b+polyX(3));
		end
	end
end

function S = scaleDim(X)
	% scaleDir - Create scale for interpolation

	c = (length(X)+1)/2;
	if mod(c,1)==0
		S = linspace(abs(1-c), 0, c);
	else
		S = linspace(abs(1-c), 0.5, length(X)/2);
	end

end