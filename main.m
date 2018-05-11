addpath(genpath('YALMIP-master'))
addpath(genpath('mosek'))

dimx = 3;
d = 1; % dim of y
N = 1000; % total number of point
scale = 100; % scale of y & z
noise = 0.1; % variance of noise (before scaled)

DNF = [0,2;1,3]; % (x1 and x2) or (not x1 and not x2);
wstar = (rand(1,d)*2-1) * 5;

% 1. generate raw data;
[datax, datayz, mu] = getData_raw(dimx, d, N, scale, noise, DNF, wstar);
% 2. preprocess;
epsilon = 0.1; % a small fraction of mu that we can suffer
[lossMat, T, termIndex] = preprocessing(datax, datayz, mu, epsilon);
% 3. list-regression;
r0 = d; 
rfinal = 0.2;
S = 1;
[U, W, remainingIndex] =  listreg(lossMat, T, mu, N, r0, rfinal, S, epsilon);
% 4. greedy set cover
threshold = scale^2 * noise; % threshold for error
[UCans] = setcover(datax, datayz, U, W, mu, termIndex, rfinal, remainingIndex, epsilon, threshold);


% plotting
colors = [ 31, 120, 180; ...
           51, 160,  44; ...
          227,  26,  28; ...
          166, 206, 227; ...
          252, 146, 114; ...
          251, 106,  74; ...
          239,  59,  44; ...
          203,  24,  29; ...
          165,  15,  21] / 255;

c = 1;
if length(UCans) > 0
    
    for i = 1:length(UCans)
        disp(UCans{i});
    end
    
    % plot true line
    y = -scale:scale;
    zstar = wstar*y;
    l1 = plot(y,zstar);
    legendarr = [l1];
    legendtexts = ['true line'];
    hold on;
    nonselected = true(1,size(datax,1));
    % plot all possible weights and datapoints
    %selectedColor = unifrnd(0,1,1,3);
    for i = 1:size(UCans,2)
        %color = unifrnd(0,1,1,3);
        
        z = UCans{i}.u*y;
        l2 = plot(y,z,'--', 'Color', colors(c,:)); 
        legendarr = [legendarr; l2];
        ithtext = string(strcat(int2str(i), 'th predicted line'));
        legendtexts = [legendtexts; ithtext];
    
        % first plot data in termIndex(UCans{1}.c,:)
        selectedData = sum(termIndex(UCans{i}.c,:),1)>0;
        selectedy = datayz(selectedData,1:end-1);
        selectedz = datayz(selectedData,end);
        l3 = plot(selectedy,selectedz,'.', 'Color', colors(c,:));c = c+1;
        legendarr = [legendarr; l3];
        ithtext = string(strcat(int2str(i), 'th selected data'));
        legendtexts = [legendtexts; ithtext];
        % plot other points
        nonselected(selectedData) = false;
    end
    color = unifrnd(0,1,1,3);
    nonselectedy = datayz(nonselected,1:end-1);
    nonselectedz = datayz(nonselected,end); 
    l4 = plot(nonselectedy,nonselectedz,'.','Color',colors(c,:));
    legendarr = [legendarr; l4];
    legendtexts = [legendtexts; 'non-selected data'];
    legend(legendarr, legendtexts);
else
    disp('U == 0 !!!!!boom!!!!!!!');
end
