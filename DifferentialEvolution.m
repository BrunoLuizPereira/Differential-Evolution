function [bestPosition, bestFitness, convergenceCurve] = DifferentialEvolution( ...
    objectiveFunction, bounds, maxIterations, numVectors, F, ...
    crossoverProbability, absConvCounterLimit, relConvCounterLimit)
%   Differential Evolution for continuous optimization.
%
%   [bestPosition, bestFitness, convergenceCurve] = DifferentialEvolution( ...
%       objectiveFunction, bounds, maxIterations, numVectors, F, ...
%       crossoverProbability, absConvCounterLimit, relConvCounterLimit)
%
%   Maximizes a user-defined objective function subject to variable bounds.
%   The objective function must accept a row vector of decision variables
%   and return a scalar value.
%
%   Decision vectors are represented internally in the normalized range
%   [0, 1] and mapped to the bounds before objective-function evaluation.
%
%   Required inputs:
%       objectiveFunction    Function handle to the objective to maximize.
%       bounds               Variable bounds in alternating order:
%                            [lb1 ub1 lb2 ub2 ...].
%
%   Optional inputs:
%       maxIterations        Maximum number of iterations (default: 100).
%       numVectors           Number of vectors in the population (default: 50).
%       F                    Differential perturbation factor (default: 0.4).
%       crossoverProbability Probability of selecting a mutant component
%                            during crossover (default: 0.95).
%       absConvCounterLimit  Consecutive-iteration limit for the absolute
%                            convergence test (default: 10000).
%       relConvCounterLimit  Consecutive-iteration limit for the relative
%                            convergence test (default: 10000).
%
%   Outputs:
%       bestPosition         Decision vector with the highest fitness.
%       bestFitness          Objective-function value at bestPosition.
%       convergenceCurve     Best fitness recorded at each iteration.
%
%   The algorithm performs maximization. To solve a minimization problem,
%   define the objective function as the negative of the function to minimize.

if nargin < 3
    maxIterations = 100;
end
if nargin < 4
    numVectors = 50;
end
if nargin < 5
    F = 0.4;
end
if nargin < 6
    crossoverProbability = 0.95;
end
if nargin < 7
    absConvCounterLimit = 10000;
end
if nargin < 8
    relConvCounterLimit = 10000;
end

numVariables = length(bounds) / 2;

% Extract the lower and upper bounds of each decision variable.
lowerBounds = bounds(1:2:end-1);
upperBounds = bounds(2:2:end);

% Initialize vectors in the normalized search space [0, 1].
vectors = zeros(numVectors, numVariables);
mutantVectors = vectors;
trialVectors = vectors;

% Allocate storage for objective-function values.
fitnessValues = zeros(numVectors, 1);
trialFitnessValues = fitnessValues;
decisionVariables = zeros(numVariables, 1);

% Generate the initial vectors.
for vectorIndex = 1:numVectors
    for variableIndex = 1:numVariables
        vectors(vectorIndex, variableIndex) = rand;
    end
end

% Evaluate the initial vectors in the original search space.
for vectorIndex = 1:numVectors
    for variableIndex = 1:numVariables
        decisionVariables(variableIndex) = ...
            (upperBounds(variableIndex) - lowerBounds(variableIndex)) * ...
            vectors(vectorIndex, variableIndex) + lowerBounds(variableIndex);
    end
    fitnessValues(vectorIndex) = objectiveFunction(decisionVariables);
end

% Initialize iteration and convergence monitoring.
iteration = 0;
continueOptimization = true;
absoluteConvergenceReached = false;
relativeConvergenceReached = false;
absoluteConvergenceCounter = 0;
relativeConvergenceCounter = 0;
previousBestFitness = inf;
bestFitnessHistory = zeros(1, maxIterations);

% Main Differential Evolution loop.
while continueOptimization
    iteration = iteration + 1;
    fprintf('Iteration: %d\n', iteration);

    % Differential mutation:
    % Add F times the difference between two randomly ordered vectors
    % to each current vector. Keep normalized components within [0, 1].
    firstRandomOrder = randperm(numVectors);
    secondRandomOrder = randperm(numVectors);

    for vectorIndex = 1:numVectors
        for variableIndex = 1:numVariables
            mutantVectors(vectorIndex, variableIndex) = ...
                vectors(vectorIndex, variableIndex) + F * ( ...
                vectors(firstRandomOrder(vectorIndex), variableIndex) - ...
                vectors(secondRandomOrder(vectorIndex), variableIndex));

            if mutantVectors(vectorIndex, variableIndex) < 0
                mutantVectors(vectorIndex, variableIndex) = 0;
            end
            if mutantVectors(vectorIndex, variableIndex) > 1
                mutantVectors(vectorIndex, variableIndex) = 1;
            end
        end
    end

    % Crossover:
    % Each trial vector takes components from the mutant vector with the
    % specified probability. At least one component comes from the mutant.
    for vectorIndex = 1:numVectors
        forcedVariable = randperm(numVariables);
        forcedVariable = forcedVariable(1);

        for variableIndex = 1:numVariables
            if rand < crossoverProbability || variableIndex == forcedVariable
                trialVectors(vectorIndex, variableIndex) = ...
                    mutantVectors(vectorIndex, variableIndex);
            else
                trialVectors(vectorIndex, variableIndex) = ...
                    vectors(vectorIndex, variableIndex);
            end
        end
    end

    % Greedy selection:
    % Replace a current vector only when its trial vector has higher fitness.
    for vectorIndex = 1:numVectors
        for variableIndex = 1:numVariables
            decisionVariables(variableIndex) = ...
                (upperBounds(variableIndex) - lowerBounds(variableIndex)) * ...
                trialVectors(vectorIndex, variableIndex) + lowerBounds(variableIndex);
        end

        trialFitnessValues(vectorIndex) = objectiveFunction(decisionVariables);
        if trialFitnessValues(vectorIndex) > fitnessValues(vectorIndex)
            vectors(vectorIndex, :) = trialVectors(vectorIndex, :);
            fitnessValues(vectorIndex) = trialFitnessValues(vectorIndex);
        end
    end

    % Check convergence using the best fitness in the current iteration.
    currentBestFitness = max(fitnessValues);

    if abs(currentBestFitness - previousBestFitness) < 1e-5
        absoluteConvergenceCounter = absoluteConvergenceCounter + 1;
        if absoluteConvergenceCounter >= absConvCounterLimit
            absoluteConvergenceReached = true;
        end
    else
        absoluteConvergenceCounter = 0;
        absoluteConvergenceReached = false;
    end

    if abs(currentBestFitness - previousBestFitness) / ...
            max(abs(currentBestFitness), 1e-10) < 0.001
        relativeConvergenceCounter = relativeConvergenceCounter + 1;
        if relativeConvergenceCounter >= relConvCounterLimit
            relativeConvergenceReached = true;
        end
    else
        relativeConvergenceCounter = 0;
        relativeConvergenceReached = false;
    end

    bestFitnessHistory(iteration) = currentBestFitness;
    previousBestFitness = currentBestFitness;

    if iteration >= maxIterations || ...
            (absoluteConvergenceReached && relativeConvergenceReached)
        continueOptimization = false;
    end
end

% Return the best decision vector and the recorded convergence history.
[bestFitness, bestVectorIndex] = max(fitnessValues);
bestPosition = (upperBounds - lowerBounds) .* ...
    vectors(bestVectorIndex, :) + lowerBounds;
convergenceCurve = bestFitnessHistory(1:iteration);

end
