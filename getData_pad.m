% dataset = zeros(100, 11);
% dataset(:,1:10) = 2*rand(100,10)-1;
% w = ones(10,1);
% noise = normrnd(0,0.2,10,1);
% dataset(1:10,end) = dataset(1:10,1:10) * w + noise;
% dataset(11:end,end) = 2*rand(90,1)-1;
% 
% T = ones(100,1);
% 
% test l2 distance
% w_star = [1,1];
% W = [-1,-1;0,0;1,1;2,2;3,3];
% m = 5;
% w_star = repmat(w_star,m,1);
% D = sqrt(sum((w_star - W).^2,2));

testcase = 7;

if (testcase == 1)
    % test case 1: 1-d
    r1 = normrnd(0,5,50,1);
    r2 = normrnd(100,5,50,1);
    r3 = normrnd(200,5,50,1);
    w = [r1;r2;r3];
    n = 150;
    delta = 0.1;
    I = 1/4;
    tau = 2*5;
    rho = 1+1/delta*log(n/I);
    [P,k] = padded(w, rho, tau);
    plot(w,ones(150,1),'+')

elseif (testcase == 2)
    % test case 2: 2-d
    r1 = mvnrnd([0,0],5*eye(2),50);
    r2 = mvnrnd([100,100],5*eye(2),50);
    r3 = mvnrnd([200,200],5*eye(2),50);
    w = [r1;r2;r3];
    %figure
    %plot(w(:,1),w(:,2),'+')
    n = 150;
    delta = 0.1;
    I = 1/4;
    tau = 2.5;
    rho = 1+1/delta*log(n/I);
    [P,k] = padded(w, rho, tau);
    % size of each cell
    for i = 1:size(P,2)
        fprintf('size of cell %i: %i*%i\n', i, size(P{i}.value,1),size(P{i}.value,2));
    end
    
elseif (testcase == 3)
    r1 = unifrnd(0,200,100,2);
    r3 = mvnrnd([100,100],5*eye(2),50);
    w = [r1;r3];
    n = 150;
    delta = 0.1;
    I = 1/4;
    tau = 2.5;
    rho = 1+1/delta*log(n/I);
    [P,k] = padded(w, rho, tau);
    % size of each cell
    figure
    for i = 1:size(P,2)
        hold on;
        plot(P{i}.value(:,1),P{i}.value(:,2),'+','Color',unifrnd(0,1,1,3))
        fprintf('size of cell %i: %i*%i\n', i, size(P{i}.value,1),size(P{i}.value,2));
    end
elseif (testcase == 4)
    % test case 2: 10-d
    d = 10;
    r1 = mvnrnd(zeros(1,d),5*eye(d),50);
    r2 = mvnrnd(100*ones(1,d),5*eye(d),50);
    r3 = mvnrnd(200*ones(1,d),5*eye(d),50);
    w = [r1;r2;r3];
    n = 150;
    delta = 0.1;
    I = 1/4;
    tau = 2.5;
    rho = 1+1/delta*log(n/I);
    [P,k] = padded(w, rho, tau);
    % size of each cell
    figure
    for i = 1:size(P,2)
        hold on;
        plot(P{i}.value(:,1),P{i}.value(:,2),'+','Color',unifrnd(0,1,1,3))
        fprintf('size of cell %i: %i*%i\n', i, size(P{i}.value,1),size(P{i}.value,2));
    end
elseif (testcase == 5)
    d = 10;
    r1 = unifrnd(0,200,100,d);
    r3 = mvnrnd(100*ones(1,d),5*eye(d),50);
    w = [r1;r3];
    n = 150;
    delta = 0.1;
    I = 1/4;
    tau = 5;
    rho = 1+1/delta*log(n/I);
    [P,k] = padded(w, rho, tau);
    % size of each cell
    figure
    for i = 1:size(P,2)
        hold on;
        plot(P{i}.value(:,1),P{i}.value(:,2),'+','Color',unifrnd(0,1,1,3))
        fprintf('size of cell %i: %i*%i\n', i, size(P{i}.value,1),size(P{i}.value,2));
    end
    
elseif (testcase == 6) 
    % plot clusters with num points >= 10
    % testing circle drawing function
    d = 10;
    %r1 = unifrnd(0,200,100,d);
    %r3 = mvnrnd(100*ones(1,d),5*eye(d),50);
    %w = [r1;r3];
    r1 = mvnrnd(zeros(1,d),5*eye(d),50);
    r2 = mvnrnd(100*ones(1,d),5*eye(d),50);
    r3 = mvnrnd(200*ones(1,d),5*eye(d),50);
    w = [r1;r2;r3];
    n = 150;
    delta = 0.1;
    I = 1/4;
    tau = 2.5;
    rho = 1+1/delta*log(n/I);
    [P,k, Cr] = padded(w, rho, tau);
    % size of each cell
    figure
    for i = 1:size(P,2)
        hold on;
        color = unifrnd(0,1,1,3);
        plot(P{i}.value(:,1),P{i}.value(:,2),'+','Color',color)
        fprintf('size of cell %i: %i*%i\n', i, size(P{i}.value,1),size(P{i}.value,2));
        
        % plot the cluster if there are at least 10 points in the cluster
        if size(P{i}.value,1) >= 10
            w_star = Cr{i}(1:end-1);
            radius = Cr{i}(end);
            viscircles([w_star(1),w_star(2)],radius,'LineStyle','--','LineWidth', 0.5,'Color',color);
        end
    end
    
    elseif (testcase == 7)
    d = 10;
    r1 = unifrnd(0,200,100,d);
    r3 = mvnrnd(100*ones(1,d),5*eye(d),50);
    w = [r1;r3];
    n = 150;
    delta = 0.1;
    I = 1/4;
    tau = 5;
    rho = 1+1/delta*log(n/I);
    [P,k, Cr] = padded(w, rho, tau);
    % size of each cell
    figure
    for i = 1:size(P,2)
        hold on;
        color = unifrnd(0,1,1,3);
        plot(P{i}.value(:,1),P{i}.value(:,2),'+','Color',color)
        fprintf('size of cell %i: %i*%i\n', i, size(P{i}.value,1),size(P{i}.value,2));
        
        % plot the cluster if there are at least 10 points in the cluster
        if size(P{i}.value,1) >= 10
            w_star = Cr{i}(1:end-1);
            radius = Cr{i}(end);
            viscircles([w_star(1),w_star(2)],radius,'LineStyle','--','LineWidth', 0.5,'Color',color);
        end
    end
    

end

%viscircles([100,100],10,'LineWidth', 0.5,'Color','blue')

