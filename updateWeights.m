function[c_p] = updateWeights(c, wh, datay,dataz,T,Yh)
    % ??? Yh ???
    %define variables for optimization
    [m,d] = size(wh);
    N = sum(T);

    %need to define the size of a
    mu = 0.1;
    z = zeros(1,m);
    c_p = zeros(1,m);


    for i = 1:m
        ai = sdpvar(1, m, 'full');
        wt = sdpvar(1, d,'full');
        
        % objective
        Obj = (dataz(i)-wt*datay(i,:)').^2; %f_i(wt)
        
        %define our constraint;
        %wt = sum(subs(a(i,j)*w(j), j, 1:m));
        
        Cons = [wt == ai*wh;
                sum(ai) == 1; %sum(subs(a(i,k),k,1:m)) == 1;
                0 <= ai <= 2/(mu*N)*T(i)]; %2/(alpha*d) >= a(i,:) >= 0
        
        diagnostics = optimize(Cons, Obj);
        %ai_v = double(ai);
        wt_v = double(wt);
        z(i) = (dataz(i)-wt_v*datay(i,:)').^2 - (dataz(i)-wh(i,:)*datay(i,:)').^2;

    end

    %diagnostics = optimize(Cons, Obj);
    %once we get \tilde(w) from the solution of the optimization, we can get
    %z_i
    %wt_v = double(wt);
    %for p = 1:m
    %    z(p) = f_i(wt_v(p)) - f_i(wh(p));
    %end
    % z_max = max(z));

    z_max = max(z(c.*T'~=0));
    c_p = c .* ((z_max - z)/z_max);
    %for i = 1:m
    %    c_p(i) = c(i)*( (z_max - z(i))/z_max );
    %end
end