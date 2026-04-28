# QuantizerNTDS-Semiglobal

## Description

QuantizerNTDS-Semiglobal is a project developed to illustrate the concepts presented in the paper
**"Semiglobal Switched Predictor-Feedback Stabilization of Nonlinear Systems with Input Delay and State/Input Quantization"** ([IEEE TAC](https://hal.science/hal-05023491)).

This project simulates:

- A nonlinear time-delay system subject to **state quantization** with a switched predictor-feedback law and a dynamic zoom variable.
- A nonlinear time-delay system subject to **input quantization** with a switched predictor-feedback law and a dynamic zoom variable.

For detailed equations, assumptions, and parameter choices, please refer to the associated paper and ([mathematical details](https://tucgr-my.sharepoint.com/:b:/g/personal/fkoudohode_tuc_gr/IQCoGetOVjLqRbc_9GSRV1PzAfJWCezM5ERkle7298em9BM?e=9DeQjZ)).

## Requirements

To run this project, you will need:

- MATLAB R2023b or later.

## Installation

Follow these steps to set up the project:

1. Download the project files from [QuantizerNTDS-Semiglobal GitHub Repository](https://github.com/Flo3221/QuantizerNTDS-Semiglobal).
2. Extract the contents to a directory of your choice.
3. Open MATLAB and navigate to the project directory using the `cd` command:

   ```
   cd /path/to/QuantizerNTDS-Semiglobal
   ```

## Usage

To use QuantizerNTDS-Semiglobal, follow these steps:

1. Open MATLAB and ensure you are in the project directory.
2. Run the main scripts:

   - For the nonlinear time-delay system with quantized predictor-feedback and **dynamic** zoom variable under **state quantization**:

     ```
     StateQuantization.m
     ```

   - For the nonlinear time-delay system with quantized predictor-feedback and **dynamic** zoom variable under **input quantization**:

     ```
     InputQuantization.m
     ```

3. Ensure that the `private` folder is in the same directory.  
   This folder contains routines used to solve initial–boundary value problems for first-order systems of hyperbolic partial differential equations (PDEs), following Shampine (2005).

### Functions

QuantizerNTDS-Semiglobal includes the following key functions.

#### Nonlinear time-delay system — state quantization

- `hpde.m` and `setup.m`:  
  Solve the transport PDE (actuator state) that appears in the ODE–PDE representation of the time-delay system.
- `run_sim`:  
  Simulates the closed-loop ODE–PDE system for one control mode (fixed zoom, dynamic zoom, or predictor-free).
- `zoom_mu`:  
  Implements the piecewise-constant zoom variable $\mu(t)$ used in the switched quantization scheme.
- `quantizer`:  
  Implements the uniform quantizer.

#### Nonlinear time-delay system — input quantization

- `hpde.m` and `setup.m`:  
  Solve the transport PDE (actuator state).
- `run_sim`:  
  Simulates the closed-loop ODE–PDE system for one control mode.
- `zoom_mu`:  
  Implements the piecewise-constant zoom variable $\mu(t)$.
- `quantizer`:  
  Implements the scalar input quantizer applied to the nominal predictor-feedback law $U_{\mathrm{nom}}(t)$.

## Examples

Refer to the following scripts for examples of how to use QuantizerNTDS-Semiglobal:

- `StateQuantization.m`  
  (Nonlinear time-delay system with dynamic zoom variable under state quantization.)
- `InputQuantization.m`  
  (Nonlinear time-delay system with dynamic zoom variable under input quantization.)

## Contributing

To contribute to QuantizerNTDS-Semiglobal, please follow these steps:

1. Fork the repository on GitHub.
2. Create a new branch for your feature or fix.
3. Make your changes and commit them.
4. Submit a pull request with a detailed description of your changes.

## License

This project is licensed under the CC BY-NC-ND license  
([`LICENSE`](https://creativecommons.org/licenses/by-nc-nd/4.0/)).

## Contact

For questions or feedback, please contact [fkoudohode@tuc.gr](mailto:fkoudohode@tuc.gr).

# Acknowledgements

Funded by the European Union (ERC, C-NORA, 101088147). Views and opinions expressed are however those of the authors only and do not necessarily reflect those of the European Union or the European Research Council Executive Agency. Neither the European Union nor the granting authority can be held responsible for them.

## Cite this work

If you use this code in your research, please cite:

```
@article{koudohode2025tac,
  title   = {Semiglobal Switched Predictor-Feedback Stabilization of Nonlinear
             Systems with Input Delay and State/Input Quantization},
  author  = {F. Koudohode and N. Bekiaris-Liberis},
  journal = {IEEE Transactions on Automatic Control},
  year    = {2025},
  note    = {To appear. Preprint: https://hal.science/hal-05023491}
}
```
