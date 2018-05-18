addpath(genpath('YALMIP-master'));
addpath(genpath('mosek'));

dimx = 3;
d = 2; % dim of y
N = 1000; % total number of point
scale = 1; % scale of y & z
noise = 0.1; % variance of noise (before scaled)

r0 = 10 * d; 
rfinal = 0.1 * d;
S = 0.01;
padded_maxiter = 10;
quad_maxiter = 10;
epsilon = 0.1; % a small fraction of mu that we can suffer
threshold = 0;%trueError * dimx^2; % threshold for error, not using this feature
mu = 0.5;

% 1. generate raw data;
[datax, datayz] = getData_sin_new(N, scale, noise);
% 2. preprocess;
[lossMat, T, termIndex, DNFtable, DNFmat] = preprocessing(datax, datayz, mu, epsilon);
% 3. list-regression;
N_new = sum(T);
mu_new = mu * (N/N_new);
[U, W, remainingIndex] =  listreg_autoshift(lossMat, T, mu_new, N_new, r0, rfinal, S, epsilon, padded_maxiter, quad_maxiter);
% 4. greedy set cover
[UCans] = setcover(datax, datayz, U, W, mu, termIndex, rfinal, remainingIndex, epsilon, threshold);


disp('trueError');
disp(trueError);

DNFstring = printPlantedDNF(DNF);
printUCans(UCans, DNFtable);
disp('planted DNF:');
disp(DNFstring);


    % plot true line
if length(UCans) > 0  

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

    y = -pi:pi;
    yhat = [ones(1,length(y)); y];
    legendarr = [];
    legendtexts = [];

    nonselected = true(1,size(datax,1));
    % plot all possible weights and datapoints
    %selectedColor = unifrnd(0,1,1,3);
    for i = size(UCans,2):-1:1
        c = i;
        %color = unifrnd(0,1,1,3);
        z = UCans{i}.u*yhat;
        l2 = plot(y,z,'--', 'Color', colors(c,:)); 
        if i == 3
           hold on;
        end
        legendarr = [legendarr; l2];
        ithtext = string(strcat(int2str(i), 'th predicted line'));
        legendtexts = [legendtexts; ithtext];
    
        % first plot data in termIndex(UCans{1}.c,:)
        selectedData = sum(termIndex(UCans{i}.c,:),1)>0;
        selectedy = datayz(selectedData,2);
        selectedz = datayz(selectedData,end);
        l3 = plot(selectedy,selectedz,'.', 'Color', colors(c,:));
        legendarr = [legendarr; l3];
        ithtext = string(strcat(int2str(i), 'th selected data'));
        legendtexts = [legendtexts; ithtext];
        % plot other points
        nonselected(selectedData) = false;
        if i == 1
            p = patch('vertices', [-pi/2, -3; -pi/2, 3; pi/2, 3; pi/2, -3], ...
                       'faces', [1, 2, 3, 4], ...
                       'FaceColor', colors(c,:), ...
                       'FaceAlpha', 0.2, ...
                       'EdgeColor', [169,169,169] / 255);
        elseif i == 2
            p = patch('vertices', [0, -3; 0, 3; 3.5, 3; 3.5, -3], ...
               'faces', [1, 2, 3, 4], ...
               'FaceColor', colors(c,:), ...
               'FaceAlpha', 0.1, ...
               'EdgeColor', [169,169,169] / 255);
        else
            p = patch('vertices', [-3.5, -3; -3.5, 3; 0, 3; 0, -3], ...
                'faces', [1, 2, 3, 4], ...
                'FaceColor', colors(c,:), ...
                'FaceAlpha', 0.1, ...
                'EdgeColor', [169,169,169] / 255);
        end
        legendarr = [legendarr; p];
        ithtext = string(strcat(int2str(i), 'th selected term'));
        legendtexts = [legendtexts; ithtext];
    end   
  
    if sum(nonselected) > 0 
        color = unifrnd(0,1,1,3);
        nonselectedy = datayz(nonselected,2);
        nonselectedz = datayz(nonselected,end);
    
        l4 = plot(nonselectedy,nonselectedz,'.','Color',colors(c,:));
        legendarr = [legendarr; l4];
        legendtexts = [legendtexts; 'non-selected data'];   
    end
    lgd = legend(legendarr, legendtexts);
    lgd.FontSize = 14;
    xl = xlabel('regression variable Y');
    set(xl, 'FontSize', 14);
    yl = ylabel('regression label Z');
    set(yl, 'FontSize', 14);
    tl = title('Z = sin(Y) + noise');
    set(tl, 'FontSize', 14);    
    xlim([-3.5,3.5]);
else
    disp('U == 0 !!!!!boom!!!!!!!');
end