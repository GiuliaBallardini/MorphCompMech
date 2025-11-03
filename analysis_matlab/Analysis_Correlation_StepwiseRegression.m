%% Matrix Analysis Pipeline
% This script performs statistical analysis on sampled data matrices:
%   1. Tests each metric for normality (Shapiro-Wilk test).
%   2. Computes Pearson correlations between all metrics.
%   3. Visualizes correlation maps.
%   4. Performs stepwise regression to identify predictors of each metric.
% -------------------------------------------------------------------------

close all
clear
clc

%% Select and load dataset

% Allow user to select dataset interactively
[filename, filepath] = uigetfile('*.mat', 'Select a sampled dataset (.mat)');
if isequal(filename,0)
    error('No file selected. Analysis aborted.');
else
    load(fullfile(filepath, filename));
    disp(['Dataset selected: ',filename])
end

n_metrics = length(names);

% Required variables in .mat file:
%   - metrics : cell array of matrices (a cell per metric)
%   - names   : internal names for each metric
%   - labels  : display names for figures/outputs

% Our Dataset: 
% DataFig2_Hair_Table1: morphological (cuticle thickness, prevalence of intermediate filament - IF, 
%   prevalence of hollow, prevalence of CEC, Ca:S) and mechanical parameters 
%   (modulus of elasticity - E, hardness - Hc) of untreated body hair and whiskers
% DataFig5_Base_Table3: mineral variables (CEC and Ca:S) and the mechanical
%   properties (E and Hc) of treated (Shindai extraction) body hair bases
% DataFig5_Base_Table4: mineral variables (CEC and Ca:S) and the mechanical
%   properties (E and Hc) of treated (Shindai extraction) body hair tips

%% Normality test (Shapiro-Wilk) and correlation analysis

norm_p = zeros(1, n_metrics);           % p-values from normality tests
corr_r = zeros(n_metrics, n_metrics);   % correlation coefficients
corr_p = zeros(n_metrics, n_metrics);   % p-values for correlations

for i = 1:n_metrics

    % --- Normality test ---
    % reminder: p<0.05 → NOT normally distributed
    [~, norm_p(i)] = swtest(metrics{i}(:), 0.05);

    % --- Pearson correlation between metrics ---
    for j = i:n_metrics
        [corr_r(i,j), corr_p(i,j)] = corr(metrics{i}, metrics{j}, 'Type', 'Pearson');
        corr_r(j,i) = corr_r(i,j);  % ensure symmetry
        corr_p(j,i) = corr_p(i,j);
    end
    
end

% Plot correlation coefficient matrix
fx_plot_correlation_map(corr_r, [-1 1], labels, ...
    'Pearson correlation coefficient', false);

% (Optional: plot p-value map)
% plot_correlation_map(corr_p, [0 1], labels, 'p-value');

%% Stepwise regression analysis

results = struct();

for i = 1:n_metrics

    fprintf('\nStepwise regression model for metric: %s\n', labels{i});

    % Response variable: current metric
    response = metrics{i};

    % Extract predictors:  all other metrics
    predictor_idx = setdiff(1:n_metrics, i);
    predictors = cell2mat(metrics(predictor_idx));
    predictors_name = labels(predictor_idx);

    % Fit stepwise regression model
    mdl = stepwiselm(predictors, response,'PredictorVars', predictors_name);

    if mdl.NumPredictors ~=0
        % Identify selected predictors
        idx = zeros(1, mdl.NumPredictors);
        for j =1:mdl.NumPredictors
            [idx(j), ~] = find(strcmp(predictors_name,mdl.PredictorNames(j)));
        end

        % --- Standardized regression coefficients (betas) ---
        Z_X = zscore(predictors(:,idx)); % Standardized predictors
        Z_Y = zscore(response);          % Standardized response

        b_std = regress(Z_Y, [ones(size(Z_X,1),1), Z_X]); % betas
        % b_std(1) - standardize intercept
        % b_std(2:end) - standardize coefficients

        terms{1} = 'Intercept';
        for kk=1:length(mdl.PredictorNames)
            terms{1+kk} = mdl.PredictorNames{kk};
        end

        % Display the beta coefficient
        fprintf('Standardized coefficients (beta):\n');
        disp(table(terms', b_std, 'VariableNames', {'Predictor','Beta'}));

        % Store coefficients and predictor names
        results.(names{i}).Betas.Terms = terms;
        results.(names{i}).Betas.Values = b_std;

        clear b_std terms
    end
    results.(names{i}).mdl=mdl;

    clear predictor_idx idx mdl
end

disp('Analysis completed')

%% Save

save('AnalysisResults.mat', 'results');
disp('Results saved to AnalysisResults.mat');