close all; clear all;
addpath /Users/Hasan/works/export_fig

probs = [
    0.7 0.1 0.1 0.05;
    0.4 0.35 0.1 0.1;
    0.5 0.4 0.05 0;
    0.4 0.2 0.1 0.1;
    0.8 0.1 0.1 0;
    0.5 0.3 0.1 0.1;
    0.4 0.25 0.1 0.1;
    0.6 0.3 0.1 0;
    0.9 0.05 0.05 0
    ];
e = entropy(probs');

h = figure(1);
set(h, 'Position', [150, 500, 200,120]);
for i = 1:size(probs,1)
    bar(probs(i,:));
    xlim([0.5 4.5]);
    export_fig(sprintf('al_example_plots/p1_%d.png', i), '-transparent');
end

probs = [0.8 0.1 0.1 0;
    1 0 0 0;
    1 0 0 0;
    0.8 0.1 0 0;
    0.9 0.1 0 0;
    0.9 0.05 0.04 0;
    1 0 0 0;
    0.8 0.1 0.1 0;
    0.9 0.05 0.05 0
    ];
e2 = entropy(probs');

h = figure(1);
set(h, 'Position', [150, 500, 200,120]);
for i = 1:size(probs,1)
    bar(probs(i,:));
    xlim([0.5 4.5]);
    export_fig(sprintf('al_example_plots/p2_%d.png', i), '-transparent');
end

h = figure(1);
set(h, 'Position', [150, 500, 800, 100]);
bar(e)
xlim([0.5 9.5]);
ylim([0 max(e)]);
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
export_fig('al_example_plots/entropy.png', '-transparent');

bar(e2)
ylim([0 max(e)]);
xlim([0.5 9.5]);
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
export_fig('al_example_plots/entropy2.png', '-transparent');

