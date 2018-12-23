function x = branchBound(Q,f,K)

n = size(Q,1);

r = max(sum(abs(Q))) + 0.01;
l = zeros(n,1);
u = ones(n,1);

cvx_begin quiet
variable z(n)
minimize( 0.5*z'*(Q+r*eye(n))*z + z'*f - K*r)
subject to
l <= z <= u
z'*ones(n,1) == K
cvx_end
LBPos = 1;
LB = 0.5*z'*(Q+r*eye(n))*z + z'*f - K*r;

queue(1).x = z;
queue(1).c = -1*ones(1,n);                                                 % Denotes which elements are 0 or 1 with -1 denoting that no constraints on that variable
queue(1).fval = 0.5*z'*(Q+r*eye(n))*z + z'*f - K*r;

while ~isempty(queue)
    
    % POP Action
    z = queue(end).x; z = round(z*100)/100;
    c = queue(end).c;
    queue(end) = [];
    
    % Quit if all entries are binary
    if sum(z==1)==K && sum(z==0)==n-K
        x = z;
        break;
    end
    
    [~,pos] = min(abs(z-0.5));
    
    % Branch 1
    tc = c; tc(pos(1)) = 0;
    if (sum(tc==1)) <= K        % Branch if onstraint satisfied
        ind = find(tc~=-1);
        cvx_begin quiet
        variable x(n)
        minimize( 0.5*x'*(Q+r*eye(n))*x + x'*f - K*r)
        subject to
        l <= x <= u
        x'*ones(n,1) == K
        x(ind) == tc(ind)'
        cvx_end       
        
        fval = 0.5*x'*(Q+r*eye(n))*x + x'*f - K*r;
        
        % PUSH Action
        L = length(queue);
        queue(L+1).x = x;
        queue(L+1).c = tc;
        queue(L+1).fval = fval;
        if fval < LB
            LBPos = L+1;
            LB = fval;            
            x = round(x*100)/100;
            if sum(x==1)==K && sum(x==0)==n-K
                break;
            end
        end
    end
    
    % Branch 2
    tc = c; tc(pos(1)) = 1;
    if (sum(tc==1)) <= K        % Branch if onstraint satisfied
        ind = find(tc~=-1);
        cvx_begin quiet
        variable x(n)
        minimize( 0.5*x'*(Q+r*eye(n))*x + x'*f - K*r)
        subject to
        l <= x <= u
        x'*ones(n,1) == K
        x(ind) == tc(ind)'
        cvx_end
        
        fval = 0.5*x'*(Q+r*eye(n))*x + x'*f - K*r;
        
        % PUSH Action
        L = length(queue);
        queue(L+1).x = x;
        queue(L+1).c = tc;
        queue(L+1).fval = fval;
        if fval < LB
            LBPos = L+1;
            LB = fval;            
            x = round(x*100)/100;
            if sum(x==1)==K && sum(x==0)==n-K
                break;
            end
        end
        
    end
    
end
