addpath(genpath('YALMIP-master'))
addpath(genpath('mosek'))

dimx = 5;
d = 5; % dim of y
N = 10000; % total number of point
scale = 10; % scale of y & z
noise = 0.1; % variance of noise (before scaled)

% zongyi's hardcode DNF
DNF = [0,2;
      1,3]; % (not x1 and not x2) or (not x1 and x3);
% DNF = randi([0,2*dimx-1],4,2);
% which is [2,8] after coded.
mu = 0.5;
r0 = 10 * d; 
rfinal = 0.1 * d;
S = 0.1;
padded_maxiter = 10;
quad_maxiter = 10;
epsilon = 0.1; % a small fraction of mu that we can suffer
threshold = 0;%trueError * dimx^2; % threshold for error, not using this feature

%wstar = scale * ((rand(1,d)*2)-1);
wstar = scale * (randi([0,1],1,d)*2-1);
disp(' ');
disp('wstar');
disp(wstar);

% 1. generate raw data;
[datax, datayz, trueError] = getData_raw(dimx, d, N, mu, scale, noise, DNF, wstar);
% 2. preprocess;
[lossMat, T, termIndex] = preprocessing(datax, datayz, mu, epsilon);
% 3. list-regression;
N_new = sum(T);
mu_new = mu * (N/N_new);
[U, W, remainingIndex] =  listreg_autoshift(lossMat, T, mu_new, N_new, r0, rfinal, S, epsilon, padded_maxiter, quad_maxiter);
% 4. greedy set cover
[UCans] = setcover(datax, datayz, U, W, mu, termIndex, rfinal, remainingIndex, epsilon, threshold);



if length(UCans) > 0
    for i = 1:length(UCans)
        disp(UCans{i});
    end
end

save('output')

%     % plot true line
% if length(UCans) > 0  

% colors = [ 31, 120, 180; ...
%            51, 160,  44; ...
%           227,  26,  28; ...
%           166, 206, 227; ...
%           252, 146, 114; ...
%           251, 106,  74; ...
%           239,  59,  44; ...
%           203,  24,  29; ...
%           165,  15,  21] / 255;
% 
% c = 1;
% 
%     y = -scale:scale;
%     zstar = wstar(1)*y;
%     l1 = plot(y,zstar);
%     legendarr = [l1];
%     legendtexts = ['true line'];
%     hold on;
%     nonselected = true(1,size(datax,1));
%     % plot all possible weights and datapoints
%     %selectedColor = unifrnd(0,1,1,3);
%     for i = 1:size(UCans,2)
%         %color = unifrnd(0,1,1,3);
%         
%         z = UCans{i}.u*y;
%         l2 = plot(y,z,'--', 'Color', colors(c,:)); 
%         legendarr = [legendarr; l2];
%         ithtext = string(strcat(int2str(i), 'th predicted line'));
%         legendtexts = [legendtexts; ithtext];
%     
%         % first plot data in termIndex(UCans{1}.c,:)
%         selectedData = sum(termIndex(UCans{i}.c,:),1)>0;
%         selectedy = datayz(selectedData,1);
%         selectedz = datayz(selectedData,end);
%         l3 = plot(selectedy,selectedz,'.', 'Color', colors(c,:));c = c+1;
%         legendarr = [legendarr; l3];
%         ithtext = string(strcat(int2str(i), 'th selected data'));
%         legendtexts = [legendtexts; ithtext];
%         % plot other points
%         nonselected(selectedData) = false;
%     end
%     if sum(nonselected) > 0 
%         color = unifrnd(0,1,1,3);
%         nonselectedy = datayz(nonselected,1);
%         nonselectedz = datayz(nonselected,end);
%     
%         l4 = plot(nonselectedy,nonselectedz,'.','Color',colors(c,:));
%         legendarr = [legendarr; l4];
%         legendtexts = [legendtexts; 'non-selected data'];   
%     end
%     legend(legendarr, legendtexts);
% else
%     disp('U == 0 !!!!!boom!!!!!!!');
% end
