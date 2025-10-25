# Statistical analysis: Hairs contain calcium-enriched capsules that control their stiffness
Repository for quantitative analysis of hair morphology, composition, and mechanics.

## Overview
This repository provides a comprehensive workflow for analyzing the morphological, compositional, and mechanical properties of various cat (*Felis catus*) hair samples, including whiskers, untreated, and chemical treated body hairs.

For related data (e.g., indentation, TEM, SEM), please refer to the Edmond data repository (repository will be available upon paper acceptance). 

This repository includes:
- MATLAB scripts for exploring relationships among morphological, mineral, and mechanical parameters following the methods reported in [Bala et al., 2011](https://www.sciencedirect.com/science/article/pii/S1751616111001196?casa_token=Wa4RIFd3AEQAAAAA:CsA3YNd1EJQKpA7qC8L3wAs4vqLc5vrTMEiSm2WxRmY1VI6cZdz-bQvbUyiXcXCAk8CRyCcCh5Y).
- Python–SPSS integrated scripts for automated General Linear Model (GLM) repeated measures analyses.

The full implementation details are described in the associated paper (the link will be available upon paper acceptance). 

## Software requirements
- [SPSS](https://www.ibm.com/docs/en/spss-statistics/cd?topic=overview-download-installation-instructions) v29.0 (IBM, USA) with Python integration for GLM analyses.
    - Required Python libraries (typically preinstalled with SPSS):
        `spss` - SPSS Python integration
        `tkinter` - GUI dialogs
        `os` - File path management
- [MATLAB](https://de.mathworks.com/help/install/ug/install-products-with-internet-connection.html) version R2024b (MathWorks, USA) for regression, correlations, and curve fitting.

## Variable description  

<small><small>

| Variable Names | Description | Units | Type of property |
|----------|--------------|--------------|--------------|
| Thickness | Cuticule wall thickness | µm | Morphological |
| IF |  The amount of keratin intermediate filament in the hair cortex  | Area percent | Morphological |
| Hollow | The amount of porous hollow in the hair cortex | Area percent | Morphological |
| CEC | The amount of calcium-enriched capsules in the hair cortex | Area percent | Mineral |
| Ca:S | The amount of Calcium compared to the amount of Sulfur in different individual CEC Percent | Unitless | Mineral |
| E | Modulus of elasticity | GPa | Mechanical |
| Hc | Hardness (GPa) | GPa | Mechanical |

</small></small>

In this repository we have utilized CEC as a variable name for CEC prevelence in the cortex of hair cross-sections. This is slightly different where CEC stands for calcium-enriched capsules. 

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

<small><small>

| Variable | Description |
|-----------|--------------|
| `metrics` | Cell array containing matrices (one per metric). |
| `names`   | Internal variable names corresponding to each metric (see Table above). |
| `labels`  | Display labels for use in plots and tables. |

### Included Datasets
| Dataset | Description |
|----------|--------------|
| DataFig2_Hair_Table1.mat | Morphological (cuticle thickness, IF prevalence, hollow prevalence), mineral (CEC prevalence, Ca:S) and mechanical (E, Hc) data of untreated body hair and whiskers. |
| DataFig5_Base_Table3.mat | Mineral variables (CEC, Ca:S) and mechanical properties (E, Hc) of treated hair bases after Shindai extraction. |
| DataFig5_Base_Table4.mat | Mineral variables (CEC, Ca:S) and mechanical properties (E, Hc) of treated hair tips after Shindai extraction. |

</small></small>

## Python-SPSS Analysis  
Used for GLM between different hair types and positions in the hair.

### Workflow
- Data Selection — Select the `.xlsx` file to analyze. 
- Sheet Selection — Enter names of sheets for analysis.
- Automated GLM Analysis — Repeated measures run per sheet.
- Output Generation — Results exported as `.spv` (SPSS Viewer) and `.pdf` files in a selected folder.

### Usage
1. Open SPSS and open the `{...}_Analysis.sps`. 
2. Run the script (press `Ctrl + A`, then `Ctrl + R`)
3. Choose the Excel file of the data to analyze `{...}_Data.xlsx` via a file dialog.
4. Select an output folder for results via a file dialog.
5. Enter the sheet names as they appear in the Excel file (comma-separated).
6. Review results saved in the SPSS Viewer or in the exported PDF files (the file will be named after the sheet name).

### Factor Description and Included Dataset 

<small><small>

| Variable | Description | Values of variable |
|----------|--------------|--------------|
| Depth | Indentation contact depth (nm) | 50, 100, 200, 400, 700 |
| HairType | Domestic cat hair type | untreated body hair, whisker |
| Position | Position along the hair length | base, tip |
| Time | Shindai extraxtion time (h) | 0, 72, 120 |
	
| Dataset | Description | Analysis |
|----------|--------------|--------------|
| Morphological_Position_Data.xlsx | Morphological (thickness) and mineral (CEC, Ca:S) variables of untreated body hair and whiskers. | Difference between hair type and position. |
| Mechanical_Depth_Data.xlsx | Mechanical variables (E, Hc) from indentation of untreated body hair and whiskers. | Difference between position and depth. |
| Mineral_Time_Analysis.xlsx | Mineral variables (CEC, Ca:S) of treated hair after Shindai extraction. | Difference between position and time. |
| Mechanical_Time_Data.xlsx | Mechanical variables (E, Hc) from indentation of treated hair after Shindai extraction. | Difference between position, time, and depth.|

</small></small>

## Support
Feel free to contact us if you need support. Our names and contact information are listed at the bottom of this page.

## Contributing
Feel free to suggest improvements or report issues.

## Notes
If you encounter any problems or questions about specific parts of the codebase, don't hesitate to raise an issue. Always provide as much context as possible.

 > 
> 
```bibtex
@misc{ballardini_minmechstats_2025,
	address = {minmechstats},
	title = {StatisticalAnalysis: Hairs contain calcium-enriched capsules that control their stiffness},
	author = {Ballardini, Giulia and Schulz, Andrew K.},
	howpublished = {Submitted},
	year = {2025},
}

```


## Licence
This project is licensed under the GNU GPL version 3 - see the [LICENSE](https://github.com/LawSmith408/WhiskerAnalyses/blob/main/LICENSEd) file for details.

## Copyright

© 2025, Max Planck Society 

## Acknowledgements
The authors thank the International Max Planck Research School for Intelligent Systems, [IMPRS-IS](https://imprs.is.mpg.de/) for supporting GB and AKS. We thank J. Burns and [J.-C. Passy](https://github.com/jcpassy) for their assistance in preparing the content for this GitHub. The authors thank N. Rokhmanova for her [ARIADNE repo](https://github.com/nrokh/ARIADNE) inspiring this ReadMe. Thanks to [Katherine J. Kuchenbecker](https://is.mpg.de/~kjk) for support and feedback.

## Contact
This code repository was implemented by [Giulia Ballardini](https://github.com/GiuliaBallardini) and [Andrew K. Schulz](https://github.com/Aschulz94).
