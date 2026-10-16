clc
clear
close all

%% Search-space bounds
% Bounds are provided as [lower1 upper1 lower2 upper2 ...].
bounds = [-5 +2 -5 +3];

%% Differential Evolution parameters
maxIterations = 100;
numVectors = 50;
F = 0.4;
crossoverProbability = 0.95;

%% Run Differential Evolution
[bestPosition, bestFitness, convergenceCurve] = ...
    DifferentialEvolution(@ObjectiveFunction, bounds, ...
    maxIterations, numVectors, F, crossoverProbability);

%% Display results
fprintf('Best decision vector:\n');
disp(bestPosition)

fprintf('Best objective-function value: %.6f\n', bestFitness);

%% Plot the convergence curve
figure
plot(convergenceCurve, 'LineWidth', 1.5)
xlabel('Iteration')
ylabel('Best Objective-Function Value')
title('Differential Evolution Convergence')
grid on
box on
