function [cost, grad] = softmaxCost(theta, numClasses, inputSize, lambda, data, labels)

% numClasses - the number of classes 
% inputSize - the size N of the input vector
% lambda - weight decay parameter
% data - the N x M input matrix, where each column data(:, i) corresponds to
%        a single test set
% labels - an M x 1 matrix containing the labels corresponding for the input data
%

% Unroll the parameters from theta
theta = reshape(theta, numClasses, inputSize);

numCases = size(data, 2);

groundTruth = full(sparse(labels, 1:numCases, 1));

% Change by Hasan. When training instances do not contain all the class
% labels greater than the max class label present.
if size(groundTruth,1)<numClasses
    groundTruth(end+1:numClasses,:) = 0;
end
cost = 0;

thetagrad = zeros(numClasses, inputSize);

%% ---------- YOUR CODE HERE --------------------------------------
%  Instructions: Compute the cost and gradient for softmax regression.
%                You need to compute thetagrad and cost.
%                The groundTruth matrix might come in handy.
h = theta * data;
h = bsxfun(@minus, h, max(h, [], 1));
h = exp(h);
h = bsxfun(@rdivide, h, sum(h,1));
cost = log(h).*groundTruth;
reg = sum(theta(:).^2);
cost = -sum(cost(:))/size(data, 2) + (lambda/2)*reg;


thetagrad = (data * (groundTruth - h)')';
thetagrad = -(1/size(data, 2)) * thetagrad + lambda*theta;


% ------------------------------------------------------------------
% Unroll the gradient matrices into a vector for minFunc
grad = thetagrad(:);
end

