clear all; close all;

addpath(genpath('./tools/UGM'));
addpath('./tools/softmax/');
addpath('./tools/minFunc/');
addpath('./tools/cvx/');
run ./tools/cvx/cvx_setup % Required one time
run ./tools/cvx/cvx_startup

pc.type = 'c3d';
pc.dataset = 'virat';
load(sprintf('./data/allEvents_%s_%s.mat', pc.dataset, pc.type));
%% Parameters
pc.numSeq = length(allEvents);
pc.numClasses = 12; 
pc.lambda = 1e-4;
pc.numObjectClasses = 6;
pc.delta = 0.8;
pc.K = 70;
pc.inputSize = size(allEvents{1}.features, 1);

pc.withOP = 1;
pc.pBins = 5;
pc.ovBins = 6;
pc.aa_thr_t = 800;
pc.aa_thr_s = 1000;
pc.ao_thr = 800;
pc.coFreqAA_a = 1;
pc.coFreqAA_m = 5;
pc.contextAP_a = 1;
pc.contextAP_m = 5;
pc.coFreqAO_a = 1;
pc.coFreqAO_m = 5;
pc.ONodeTweak = 0.01;
pc.PNodeTweak = 0.01;

pc.numBatch = 5;
pc.initBatch = 0.1;
pc.trainSeq = 1:176;
pc.testSeq = setdiff(1:pc.numSeq, pc.trainSeq);

%% Arrange test data
run arrange_test_data.m

%% Arrange train data
run make_batches_virat.m

%% experimenting with different teacher selections
% pc.strongTeacher = 0;
% pc.weakTeacher = 0;
% run incremental_learning_context.m

% pc.strongTeacher = 1;
% pc.weakTeacher = 0;
% run incremental_learning_context.m

pc.strongTeacher = 1;
pc.weakTeacher = 1;
run incremental_learning_context.m

% pc.strongTeacher = -1;
% pc.weakTeacher = 1;
% run incremental_learning_context.m