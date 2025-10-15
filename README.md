# StatisticalAnalysis: Hairs contain calcium-enriched capsules that control their stiffness

## Overview
This repository contains a workflow for analyzing the morphological, compositional, and mechanical properties of hair samples, including whiskers, untreated and treated body hairs.
For related data (e.g., indentation, TEM, SEM), please refer to the Edmond data repository (repository will be available upon paper acceptance). 
This repository contains scripts for investigating the difference between different hair type, position along the hair length, and specific parameters of the data considered.
Additionally, Matlab analysis includes pipeline to investigate the relationships among morphological, mineral and mechanical parameters extracted from different techniques following the mthods reported in [Bala et al., 2011](https://www.sciencedirect.com/science/article/pii/S1751616111001196?casa_token=Wa4RIFd3AEQAAAAA:CsA3YNd1EJQKpA7qC8L3wAs4vqLc5vrTMEiSm2WxRmY1VI6cZdz-bQvbUyiXcXCAk8CRyCcCh5Y).

Full implementation details are described in the associated paper.

## Feature 

## Software Requirements
- [SPSS](https://www.ibm.com/docs/en/spss-statistics/cd?topic=overview-download-installation-instructions) v29.0 (IBM, USA) for GLM analyses.  
- [MATLAB](https://de.mathworks.com/help/install/ug/install-products-with-internet-connection.html) version R2024b (MathWorks, USA) for regression, correlations, and curve fitting.

## MATLAB Analysis Pipeline
Run the main script ('Analysis_Correlation_StepwiseRegression.m') to perform statistical analysis and visualization of metric matrices.

### Workflow
- Dataset Selection — User interactively selects one of the .mat datasets.
- Normality Testing — Shapiro–Wilk test on each metric.
- Correlation Analysis — Computes Pearson correlations between all metrics.
- Visualization — Generates heatmaps of correlation matrices.
- Stepwise Regression — Identifies predictors for each target metric.

### Usage
1. Open MATLAB and navigate to the project folder.
2. Run the main script: Analysis_Correlation_StepwiseRegression
3. When prompted, select one of the provided .mat datasets (or your own dataset with the same structure).

Each .mat file should contain the following variables:

| Variable | Description |
|-----------|--------------|
| `metrics` | Cell array containing matrices (one per metric). |
| `names`   | Internal variable names corresponding to each metric. |
| `labels`  | Display labels for use in plots and tables. |

### Included Datasets
| Dataset | Description |
|----------|--------------|
| **DataFig2_Hair_Table1.mat** | Morphological (cuticle thickness, IF prevalence, hollow prevalence, CEC prevalence, Ca:S) and mechanical (elastic modulus *E*, hardness *Hc*) data of untreated body hair and whiskers. |
| **DataFig5_Base_Table3.mat** | Mineral variables (CEC, Ca:S) and mechanical properties (*E*, *Hc*) of treated hair bases after Shindai extraction. |
| **DataFig5_Base_Table4.mat** | Mineral variables (CEC, Ca:S) and mechanical properties (*E*, *Hc*) of treated hair tips after Shindai extraction. |

## SPSS Analysis (coming soon) 
Planned SPSS analysis files will include:
- `.sav` datasets for statistical modeling.
- `.spv` output files (SPSS Viewer).
- Additional documentation to reproduce equivalent SPSS statistical analyses.

## Support
Feel free to contact us in case support is needed. Our names and contact information are listed at the bottom of this page.

## Contributing
Please feel free to contribute improvements or report issues.

## Notes

## Licence

## Copyright

## Acknowledgements

## Contact
This code repository was implemented by [Giulia Ballardini](https://github.com/GiuliaBallardini) and [Andrew K. Schulz](https://github.com/Aschulz94).
