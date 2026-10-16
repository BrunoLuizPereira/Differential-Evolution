# Differential Evolution for Continuous Optimization

A simple, practical, and easy-to-use implementation of Differential Evolution (DE) for continuous optimization in **MATLAB and GNU Octave**.

The algorithm allows users to maximize their own objective functions within user-defined bounds, without requiring additional MATLAB toolboxes. It is suitable for students, researchers, engineers, and anyone interested in numerical optimization.

The implementation includes differential mutation, crossover, greedy selection, and convergence monitoring.

**Important:** The algorithm performs **maximization**. To solve a minimization problem, define the objective function as the negative of the function to be minimized.

## Requirements

- MATLAB or GNU Octave.
- No additional MATLAB toolboxes are required.

## Files

- `DifferentialEvolution.m` — main Differential Evolution function.
- `Main.m` — example script that configures and runs the algorithm.
- `ObjectiveFunction.m` — objective function used in the example.

Keep all three files in the same folder, or add their folder to the MATLAB or Octave path.

## Example

The provided `Main.m` script maximizes the objective function defined in `ObjectiveFunction.m`:

`f(x) = -x(1)^2 - x(2)^2 + 10`

The search bounds are:

- `-5 <= x(1) <= 2`
- `-5 <= x(2) <= 3`

The theoretical maximum is `10`, attained at `x = [0, 0]`.

To run the example, set the project folder as the current folder and execute:

```matlab
Main
```

The script displays the best decision vector found, its objective-function value, and the convergence curve.

## Using the Algorithm

The main function has the following syntax:

```matlab
[bestPosition, bestFitness, convergenceCurve] = DifferentialEvolution( ...
    objectiveFunction, bounds, maxIterations, numVectors, F, ...
    crossoverProbability, absConvCounterLimit, relConvCounterLimit);
```

The first two arguments are required:

- `objectiveFunction` — function handle that receives a row vector of decision variables and returns a scalar objective value.
- `bounds` — vector containing the lower and upper bounds of each decision variable in alternating order.

For example, for three decision variables:

```matlab
bounds = [lb1 ub1 lb2 ub2 lb3 ub3];
```

All subsequent arguments are optional and use the default values defined in `DifferentialEvolution.m` when omitted.

## Input Parameters

| Parameter | Description | Default |
|---|---|---:|
| `maxIterations` | Maximum number of iterations. | `100` |
| `numVectors` | Number of vectors in the population. | `50` |
| `F` | Differential perturbation factor. | `0.4` |
| `crossoverProbability` | Probability of selecting a mutant component during crossover. | `0.95` |
| `absConvCounterLimit` | Consecutive-iteration limit for the absolute convergence test. | `10000` |
| `relConvCounterLimit` | Consecutive-iteration limit for the relative convergence test. | `10000` |

## Algorithm Overview

- **Differential mutation:** generates mutant vectors using scaled differences between existing vectors.
- **Crossover:** combines each mutant vector with its corresponding target vector to generate a trial vector.
- **Greedy selection:** replaces a target vector with its trial vector when the trial achieves a higher objective-function value.

Decision vectors are internally represented in the normalized range `[0, 1]` and mapped to the user-defined bounds for objective-function evaluation. Mutant components outside the normalized range are clipped to the corresponding boundary.

## Output Arguments

- `bestPosition` — best decision vector found.
- `bestFitness` — objective-function value associated with `bestPosition`.
- `convergenceCurve` — best objective-function value recorded at each iteration.

## Stopping Criteria

The algorithm stops when the maximum number of iterations is reached or when both convergence tests satisfy their respective consecutive-iteration limits.

The implementation uses an absolute tolerance of `1e-5` and a relative threshold of `0.001` (0.1%). The corresponding counter limits can be configured through `absConvCounterLimit` and `relConvCounterLimit`.

Because Differential Evolution is a stochastic optimization method, results may vary between runs, and finding the global optimum is not guaranteed.

## License

This project is distributed under the MIT License. See the `LICENSE` file for details.
