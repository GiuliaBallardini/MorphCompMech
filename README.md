# StatisticalAnalysis: Hairs contain calcium-enriched capsules that control their stiffness
Repository for quantitative analysis of hair morphology, composition, and mechanics

## Overview
This repository provides a comprehensive workflow for analyzing the morphological, compositional, and mechanical properties of various hair samples, including whiskers, untreated, and treated body hairs.

For related data (e.g., indentation, TEM, SEM), please refer to the Edmond data repository (repository will be available upon paper acceptance). 

This repository includes:
- MATLAB scripts for exploring relationships among morphological, mineral, and mechanical parameters following the methods reported in [Bala et al., 2011](https://www.sciencedirect.com/science/article/pii/S1751616111001196?casa_token=Wa4RIFd3AEQAAAAA:CsA3YNd1EJQKpA7qC8L3wAs4vqLc5vrTMEiSm2WxRmY1VI6cZdz-bQvbUyiXcXCAk8CRyCcCh5Y).
- Python–SPSS integrated scripts for automated General Linear Model (GLM) repeated measures analyses.

Full implementation details are described in the associated paper.

## Software requirements
- [SPSS](https://www.ibm.com/docs/en/spss-statistics/cd?topic=overview-download-installation-instructions) v29.0 (IBM, USA) with Python integration for GLM analyses.
    - Required Python libraries (typically preinstalled with SPSS):
        `spss` - SPSS Python integration
        `tkinter` - GUI dialogs
        `os` - File path management
- [MATLAB](https://de.mathworks.com/help/install/ug/install-products-with-internet-connection.html) version R2024b (MathWorks, USA) for regression, correlations, and curve fitting.

## MATLAB Analysis Pipeline
Used for regression, correlation, and curve fitting analyses and visualization.

### Workflow
- Dataset Selection — User interactively selects one of the `.mat` datasets.
- Normality Testing — Shapiro–Wilk test on each metric.
- Correlation Analysis — Computes Pearson correlations between all metrics.
- Visualization — Generates heatmaps of correlation matrices.
- Stepwise Regression — Identifies predictors for each target metric.

### Usage
1. Open MATLAB and navigate to the project folder.
2. Run the main script: `Analysis_Correlation_StepwiseRegression.mat`
3. When prompted, select one of the provided `.mat` datasets (or your own dataset with the same structure).

Each `.mat` file should contain the following variables:
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

## Python-SPSS Analysis  
Used for GLM between different hair types and position in the hair.

### Workflow
- Data Selection — Select the `.xlsx` file ato analyze. 
- Sheet Selection — Enter names of sheets for analysis.
- Automated GLM Analysis — Repeated measures run per sheet.
- Output Generation — Results exported as `.spv` (SPSS Viewer) and `.pdf` files in a selected folder.

### Usage
1. Open SPSS and open the 'Syntax_Analysis.sps'. 
2. Run the script (press `Ctrl + A`, then `Ctrl + R`)
3. Choose the Excel file to analyze via a file dialog.
4. Select an output folder for results via a file dialog.
5. Enter the sheet names as they appear in the Excel file (comma-separated).
6. Review results in the SPSS Viewer or in the exported PDF files.
   
Each `.xlsx` file should contain the following variables:
| Variable | Description |
|-----------|--------------|
| `HairType` | Categorical variable (text) containting the type of hair the data are related to. |
| `base`   | Numeric variable (measurements at base). |
| `tip`  |  Numeric variable (measurements at tip). |

### Included Datasets
| Dataset | Description |
|----------|--------------|
| **Data_Fig2.xlsx** | Morphological (thickness, CEC prevalence, Ca:S) of untreated body hair and whiskers. |
| **Data_Fig5.xlsx** | Mineral variables (CEC, Ca:S) and mechanical properties (*E*, *Hc*) of treated hair bases after Shindai extraction. |
| **Data_Fig5.xlsx** | Mineral variables (CEC, Ca:S) and mechanical properties (*E*, *Hc*) of treated hair tips after Shindai extraction. |

## Support
Feel free to contact us in case support is needed. Our names and contact information are listed at the bottom of this page.

## Contributing
Contributions are welcome! Please feel free to contribute improvements or report issues.

## Notes

## Licence

## Copyright

## Acknowledgements

## Contact
This code repository was implemented by [Giulia Ballardini](https://github.com/GiuliaBallardini) and [Andrew K. Schulz](https://github.com/Aschulz94).
