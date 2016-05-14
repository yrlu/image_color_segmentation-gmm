		dirstruct = dir('Test_set/*.png');
		for i = 1:length(dirstruct),
			% Read one test image 
			im = imread(strcat('Test_set/',dirstruct(i).name));
            subplot(1,2,1), imshow(im);
			% Your computations here!
			[x,y,d, BW, cc, bb] = detect_barrel(im);
            
            
			% Display results:
			% (1) Segmented image
			% (2) Barrel center 
			% (3) Distance of barrel 
			% You may also want to plot and display other diagnostic information 
 
            if size(cc,1) ~= 0
                hold on;
                plot(x, y, 'b+');
                hold on;
                rectangle('Position',[bb.BoundingBox(1),bb.BoundingBox(2),bb.BoundingBox(3),bb.BoundingBox(4)],...
                     'EdgeColor','y','LineWidth',1 );
            end
            disp 'Estimated distance:', d
            subplot(1,2,2), imshow(BW);
			hold off;
			pause(0.1);
%             saveas(1, 'file', 'png')
            print('-dpng','-r288',strcat('outputs/', dirstruct(i).name));
%             imwrite(BW,strcat('outputs/', dirstruct(i).name));
            
		end