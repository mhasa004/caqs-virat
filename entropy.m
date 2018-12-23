% Entropy: Returns entropy (in bits) of each column of 'X'
%
% H = Entropy(X)
%
% H = row vector of calculated entropies (in bits)
% X = data to be analyzed
%
% Theory can be found in the following link - 
% http://en.wikipedia.org/wiki/Entropy_(information_theory)

function H = entropy(X)

% Add a jitter for numerical stability
X = X + 1e-6;

% Establish size of data
m = size(X,2);

% Housekeeping
H = zeros(1,m);

for Column = 1:m,
    P = X(:,Column);
    % P = sort(P,'descend');
    % P = P(1:3);
    H(Column) = -sum(P .* log2(P));
end