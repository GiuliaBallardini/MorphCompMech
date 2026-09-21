% Performs statistical analysis on sampled data matrices:
%   1. Tests each metric for normality (Shapiro-Wilk test).
%   2. Estimates pairwise Pearson correlations via bootstrapping, with
%      95% percentile confidence intervals and two-tailed p-values.
%   3. Visualizes the correlation matrix as a color-coded heatmap,
%      with significant entries (p < 0.05) displayed in bold.
%   4. Runs a two-stage bootstrap stepwise regression for each metric:
%        Stage 1 – Bootstrap Inclusion Frequency (BIF) to identify
%                  stable predictors (BIF > 50%).
%        Stage 2 – Percentile CIs on standardized betas for stable
%                  predictors only.
%
% Input:
%   A .mat file containing:
%     metrics  – 1×n_metrics cell array; each cell is a numeric matrix
%                (observations × columns/subjects).
%     labels   – 1×n_metrics cell array of display names (strings).
%     names    – 1×n_metrics cell array of valid field-name strings used
%                as struct keys in the results output.
%
% Output:
%   Printed tables (console) with:
%     - Normality p-values (Shapiro-Wilk).
%     - Pairwise correlation coefficients with 95% CIs and p-values.
%     - BIF tables per response metric.
%     - Standardized beta tables for stable predictors.
%   results  – struct; one field per metric containing BIF, betas, CIs,
%              and quality flags.
%   A correlation heatmap figure.
%
% Dependencies:
%   ShapiroWilkTest.m  – Shapiro-Wilk test (available on MATLAB File Exchange).
%
% -------------------------------------------------------------------------

clear
clc

%% --- 0. Dataset selection ---

% Allow user to select dataset interactively
[filename, filepath] = uigetfile('*.mat', 'Select a sampled dataset (.mat)');
if isequal(filename,0)
    error('No file selected. Analysis aborted.');
else
    load(fullfile(filepath, filename));
    disp(['Dataset selected: ',filename])
end

n_metrics = length(metrics);


%% --- 1. Normality test ---

norm_p = zeros(1, n_metrics);   % pre-allocate p-value vector

for i = 1:n_metrics
    % Flatten the full metric matrix to a column vector before testing
    [~, norm_p(i)] = ShapiroWilkTest(metrics{i}(:), 0.05);
end

%% --- 2. Bootstrap Pearson correlations ---

% For each metric pair (i, j):
% - n_boot bootstrap samples are drawn: n_min rows per column,
%   with replacement, then flattened into a single vector.
% - The bootstrap distribution of r gives the point estimate (median),
%   95% percentile CI, and a two-tailed p-value (proportion of
%   bootstrap r values on the opposite side of zero, doubled).

rng(42);            % fixed seed for reproducibility
n_boot = 5000;      % number of bootstrap iterations
n_min = 5;          % rows resampled per column per iteration

% Pre-allocate output matrices
corr_r     = zeros(n_metrics);
corr_p     = zeros(n_metrics);
corr_ci_lo = zeros(n_metrics);
corr_ci_hi = zeros(n_metrics);

for i = 1:n_metrics

    for j = i:n_metrics

        n_cols_i = size(metrics{i}, 2);
        n_cols_j = size(metrics{j}, 2);

        boot_r = zeros(n_boot, 1); % stores r for each bootstrap sample

        for b = 1:n_boot

            % Resample metric i: n_min rows per column → flatten
            x = zeros(n_min * n_cols_i, 1);
            for c = 1:n_cols_i
                idx = randsample(size(metrics{i}, 1), n_min, true);
                x((c-1)*n_min+1 : c*n_min) = metrics{i}(idx, c);
            end

            % Resample metric j: n_min rows per column → flatten
            y = zeros(n_min * n_cols_j, 1);
            for c = 1:n_cols_j
                idx = randsample(size(metrics{j}, 1), n_min, true);
                y((c-1)*n_min+1 : c*n_min) = metrics{j}(idx, c);
            end

            boot_r(b) = corr(x, y, 'Type', 'Pearson');
        end

        % Point estimate and 95% percentile CI
        corr_r(i,j)     = median(boot_r);
        corr_ci_lo(i,j) = prctile(boot_r, 2.5);
        corr_ci_hi(i,j) = prctile(boot_r, 97.5);

        % Two-tailed p-value: proportion of bootstrap r values that cross zero
        obs_r = median(boot_r);
        if obs_r >= 0
            corr_p(i,j) = 2 * mean(boot_r <= 0);
        else
            corr_p(i,j) = 2 * mean(boot_r >= 0);
        end

        % Mirror lower triangle
        corr_r(j,i)     = corr_r(i,j);
        corr_p(j,i)     = corr_p(i,j);
        corr_ci_lo(j,i) = corr_ci_lo(i,j);
        corr_ci_hi(j,i) = corr_ci_hi(i,j);
    end
end

% Visualize correlation matrix (bold = p < 0.05)
plot_correlation_map_bold(corr_r, [-1 1], labels, ...
    'Pearson correlation coefficient', false, corr_p)

%% --- 3. Bootstrap stepwise regression ---

% For each metric used as the response variable:
%
%   Stage 1 – BIF (Bootstrap Inclusion Frequency)
%     Runs stepwiselm on n_boot bootstrap samples.  The proportion of
%     iterations in which each predictor is retained estimates its BIF.
%     Predictors with BIF > threshold are considered "stable".
%
%   Stage 2 – Standardized beta estimation (stable predictors only)
%     Fits OLS on z-scored data for each bootstrap sample.  Percentile
%     CIs (2.5–97.5%) are computed from the bootstrap distribution of
%     standardized betas. Degenerate distributions are flagged.

rng(42);            % fixed seed for reproducibility
threshold = 0.50;   % BIF threshold to declare a predictor "stable"
results = struct(); % stores all per-metric outputs

for i = 1:n_metrics

    response      = metrics{i};
    predictor_idx = setdiff(1:n_metrics, i); % all metrics except response
    pred_names    = labels(predictor_idx);
    n_preds       = length(predictor_idx);
    n_cols_resp   = size(response, 2);

    %% Stage 1 — Bootstrap inclusion frequency
    inclusion_count = zeros(1, n_preds);
    n_valid_boot    = 0;  % count successful iterations

    for b = 1:n_boot

        y_boot = sample_flatten(response, n_min); % Resample response

        % Resample each predictor and align lengths
        X_boot = zeros(length(y_boot), n_preds);
        for p = 1:n_preds
            pred_col = metrics{predictor_idx(p)};
            col_vals = sample_flatten(pred_col, n_min);
            min_len  = min(length(col_vals), length(y_boot));
            X_boot(1:min_len, p) = col_vals(1:min_len);
        end
        try
            % Forward/backward stepwise selection (linear, no interactions)
            mdl_boot = stepwiselm(X_boot, y_boot,     ...
                'PredictorVars', pred_names,           ...
                'Upper',         'linear',             ...
                'Lower',         'constant',           ...
                'Verbose',       0);

            % Record which predictors were retained
            for p = 1:n_preds
                if any(strcmp(mdl_boot.PredictorNames, pred_names{p}))
                    inclusion_count(p) = inclusion_count(p) + 1;
                end
            end
            n_valid_boot = n_valid_boot + 1;
        catch
            continue;  % skip ill-conditioned samples
        end
    end

    % Compute BIF relative to successful iterations
    inclusion_freq = inclusion_count / n_valid_boot;

    % Print BIF table
    fprintf('\n=== %s ===\n', labels{i});
    fprintf('\nPredictor inclusion frequency (%d valid iterations):\n', ...
        n_valid_boot);
    for p = 1:n_preds
        marker = '  ';
        if inclusion_freq(p) > threshold
            marker = ' *';  % flag stable predictors
        end
        fprintf('  %-20s %5.1f%%%s\n', ...
            pred_names{p}, inclusion_freq(p)*100, marker);
    end
    fprintf('  (* = stable, BIF > %.0f%%)\n', threshold*100);

    % Identify stable predictors
    stable_idx   = find(inclusion_freq > threshold);
    stable_names = pred_names(stable_idx);

    % Store BIF results
    results.(names{i}).pred_names     = pred_names;
    results.(names{i}).inc_freq       = inclusion_freq;
    results.(names{i}).n_valid_boot   = n_valid_boot;

    % If no stable predictors found, report and skip Stage 2
    if isempty(stable_idx)
        fprintf('\n  No stable predictors found (all BIF <= %.0f%%).\n', ...
            threshold*100);
        fprintf('  Reporting BIF only — no beta estimation performed.\n');
        results.(names{i}).stable_predictors = {};
        results.(names{i}).betas             = [];
        results.(names{i}).ci                = [];
        continue;
    end

    fprintf('\n  Stable predictors: ');
    fprintf('%s ', stable_names{:});
    fprintf('\n');

    %% Stage 2: Percentile CI on standardized betas
    n_stable = length(stable_idx);
    n_betas  = n_stable + 1;          % +1 for intercept (not reported)
    boot_b   = NaN(n_boot, n_betas);  % % pre-allocate; NaN = failed iter

    for b = 1:n_boot

        y_boot = sample_flatten(response, n_min);

        % Resample stable predictors only
        X_boot = zeros(length(y_boot), n_stable);
        for p = 1:n_stable
            pred_col = metrics{predictor_idx(stable_idx(p))};
            col_vals = sample_flatten(pred_col, n_min);
            min_len  = min(length(col_vals), length(y_boot));
            X_boot(1:min_len, p) = col_vals(1:min_len);
        end

        try
            Z_X = zscore(X_boot);
            Z_Y = zscore(y_boot);

            % Skip if any column collapsed to a constant (zscore → NaN)
            if any(~isfinite(Z_X(:))) || any(~isfinite(Z_Y))
                continue;
            end

            boot_b(b, :) = regress(Z_Y, [ones(size(Z_X,1),1), Z_X])';
        catch
            continue;  % skip ill-conditioned samples
        end
    end

    % Remove iterations that failed (any NaN in the row)
    boot_b_clean = boot_b(~any(isnan(boot_b), 2), :);
    n_valid_s2   = size(boot_b_clean, 1);

    fprintf('\n  Stage 2: %d/%d valid bootstrap iterations for beta estimation.\n', ...
        n_valid_s2, n_boot);

    if n_valid_s2 < 100
        fprintf('  WARNING: fewer than 100 valid iterations — beta estimates unreliable.\n');
    end

    % Compute point estimates and percentile CIs (intercept at k=1 is skipped)
    b_median = zeros(1, n_betas);
    b_ci_lo  = zeros(1, n_betas);
    b_ci_hi  = zeros(1, n_betas);
    b_flag   = false(1, n_betas);  % flag degenerate distributions

    for k = 2:n_betas  % k=1 is intercept — always 0 after zscore, skip
        b_vals      = boot_b_clean(:, k);
        b_median(k) = median(b_vals);
        b_ci_lo(k)  = prctile(b_vals, 2.5);
        b_ci_hi(k)  = prctile(b_vals, 97.5);

        % Flag degenerate: near-zero variance or median outside its own CI
        if std(b_vals) < 1e-6 || ...
                b_median(k) < b_ci_lo(k) || b_median(k) > b_ci_hi(k)
            b_flag(k) = true;
        end
    end

    % Print beta table
    fprintf('\n  Standardized betas [95%% percentile CI] — exploratory:\n');
    fprintf('  %-20s  %7s  %7s  %7s  %s\n', ...
        'Predictor', 'beta', 'CI_lo', 'CI_hi', 'Note');
    fprintf('  %s\n', repmat('-', 1, 60));

    for p = 1:n_stable
        k    = p + 1;
        note = '';
        if b_flag(k)
            note = '  [!] degenerate — interpret with caution';
        end
        fprintf('  %-20s  %+7.3f  %+7.3f  %+7.3f%s\n', ...
            stable_names{p}, b_median(k), b_ci_lo(k), b_ci_hi(k), note);
    end

    % Store regression results
    results.(names{i}).stable_predictors = stable_names;
    results.(names{i}).betas             = b_median(2:end);   % exclude intercept
    results.(names{i}).ci                = [b_ci_lo(2:end);   % 2 x n_stable
        b_ci_hi(2:end)];
    results.(names{i}).beta_flag         = b_flag(2:end);     % degenerate flags
    results.(names{i}).n_valid_stage2    = n_valid_s2;

    clear predictor_idx stable_idx stable_names inclusion_count
end

%% --- Helper functions ---

function v = sample_flatten(metric_matrix, n_min)
% Resample n_min rows per column (with replacement) and
% flatten to a single column vector.
%
%   v = sample_flatten(metric_matrix, n_min)
%
%   Parameters
%   ----------
%   metric_matrix : numeric matrix (n_rows × n_cols)
%   n_min         : number of rows to draw per column
%
%   Returns
%   -------
%   v : column vector of length (n_min × n_cols)

[n_rows, n_cols] = size(metric_matrix);
v = zeros(n_min * n_cols, 1);
for c = 1:n_cols
    idx = randsample(n_rows, n_min, true);
    v((c-1)*n_min+1 : c*n_min) = metric_matrix(idx, c);
end
end

function plot_correlation_map_bold(temp, var_limit, labels, plot_title, showDiag, corr_p)
%PLOT_CORRELATION_MAP_BOLD  Heatmap of a correlation matrix with optional
%                            bold text for significant entries.
%
%   plot_correlation_map_bold(temp, var_limit, labels, plot_title)
%   plot_correlation_map_bold(..., showDiag)
%   plot_correlation_map_bold(..., showDiag, corr_p)
%
%   Parameters
%   ----------
%   temp       : n×n correlation matrix
%   var_limit  : [min max] color scale limits (e.g. [-1 1])
%   labels     : 1×n cell array of axis tick labels
%   plot_title : string; figure title
%   showDiag   : logical; if false, diagonal cells are grayed out (default: true)
%   corr_p     : n×n p-value matrix; entries with p < 0.05 are bolded.
%                Omit or pass [] to disable bold formatting.

% --- Default ----
if nargin < 5
    showDiag = true;
end
if nargin < 6
    corr_p = [];  % no p-value matrix provided → no bold
end

% --- Define custum colormap (purple → white → gold) ---
startColor  = [156, 140, 189] / 255; % purple
middleColor = [255, 255, 255] / 255; % white
endColor    = [208, 169,  55] / 255; % gold
N = 256;

cmap1 = [linspace(startColor(1),  middleColor(1), N/2)', ...
    linspace(startColor(2),  middleColor(2), N/2)', ...
    linspace(startColor(3),  middleColor(3), N/2)'];
cmap2 = [linspace(middleColor(1), endColor(1), N/2)', ...
    linspace(middleColor(2), endColor(2), N/2)', ...
    linspace(middleColor(3), endColor(3), N/2)'];

if var_limit(1) < 0
    cmap = [cmap1; cmap2]; % full diverging map
else
    cmap = flip(cmap2); % sequential map for positive-only range
end

% --- Prepare data ---
temp_plot = temp;
if ~showDiag
    temp_plot(1:size(temp_plot,1)+1:end) = NaN; % NaN out diagonal
end

n = size(temp_plot, 1);
nanMask = isnan(temp_plot);

% --- Draw heatmap ---
figure('units','normalized','Position',[0.1 0.1 0.6 0.5]);
ax = axes;

% imagesc does not render NaN; temporarily fill with 0 for rendering
temp_masked = temp_plot;
temp_masked(nanMask) = 0;
imagesc(temp_masked, var_limit);
colormap(cmap);
colorbar;

% Gray out NaN (diagonal) cells
hold on;
for r = 1:n
    for c = 1:n
        if nanMask(r,c)
            fill([c-.5 c+.5 c+.5 c-.5], [r-.5 r-.5 r+.5 r+.5], ...
                [.5 .5 .5], 'EdgeColor','none');
        end
    end
end

% --- Overlay text labels (bold if p<0.05) ---
for r = 1:n
    for c = 1:n
        if nanMask(r,c)
            continue; % skip grayed-out cells
        end

        val = temp_plot(r,c);
        txt = sprintf('%.2f', val);

        % Bold text when p < 0.05
        isSig = ~isempty(corr_p) && corr_p(r,c) < 0.05;
        fw = 'bold';
        if ~isSig
            fw = 'normal';
        end

        text(c, r, txt, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment',   'middle', ...
            'FontWeight', fw, ...
            'FontSize',   9, ...
            'Color',      [0 0 0]);
    end
end

% --- Axes formatting ---
axis equal tight;
ax.XTick = 1:n;
ax.YTick = 1:n;
ax.XTickLabel = labels;
ax.YTickLabel = labels;
ax.XTickLabelRotation = 45;
ax.TickLength = [0 0];
title(plot_title);
box on;
end
