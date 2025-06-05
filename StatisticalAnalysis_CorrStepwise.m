clear
clc

%% Analysis on the sampled matrices

filename='HairDataMatrix_Fig2_SampledDataset.mat';
% filename='RootDataMatrix_Fig5_SampledDataset.mat';
% filename='PointDataMatrix_Fig5_SampledDataset.mat';

%Loading data
load(filename)



%%
n_metrics = length(names);

for i = 1:n_metrics

    % Testing for normality - Shapiro-Wilk test
    % reminder: p<0.05 = NO normally distributed
    [~, norm_p(i)] = swtest(metrics{i}(:), 0.05);

    % Pearson's correlation coefficient between matrices
    for j = i:n_metrics
        [corr_r(i,j), corr_p(i,j)] = corr(metrics{i}, metrics{j}, 'Type', 'Pearson');
        %fprintf('Pearson correlation between %s and %s: r = %.4f, p= %.4f \n', names{i}, names{j}, corr_r(i,j), corr_p(i,j));
    end

end

% plot correlation map
plot_correlation_map(corr_r, [-1 1], labels, 'Pearson correlation coefficient');


%% Stepwise regression

for i = 1:n_metrics
    
    response = metrics{i};

    % Extract predictors: concatenate all other metrics row-wise
    predictor_idx = setdiff(1:n_metrics, i);
    predictors = cell2mat(metrics(predictor_idx));
    predictors_name = labels(predictor_idx);

    % Perform stepwise regression
    mdl = stepwiselm(predictors, response,'PredictorVars',labels(predictor_idx));
    fprintf('Stepwise regression model for Matrix %s:\n', labels{i});
    % disp(mdl);
    if mdl.NumPredictors ~=0
        % find the indecesof the predictors for the following analysis
        for j =1:mdl.NumPredictors
            [idx(j), ~] = find(strcmp(predictors_name,mdl.PredictorNames(j)));
        end

        % Compute standardize regression coefficent (beta)
        Z_X = zscore(predictors(:,idx)); % Standardized predictors
        Z_Y = zscore(response); % Standardized response

        b_std = regress(Z_Y, [ones(size(Z_X,1),1), Z_X]) % Compute standardized betas
        mdl.PredictorNames
        % b_std(1) - standardize intercept
        % b_std(2:end) - standardize coefficients

        % store the beta coefficients
        eval(['b_',names{i},'=b_std;'])
    end
    
    % store the models
    eval(['mdl_',names{i},'=mdl;'])

    clear predictor_idx idx
end



%%
function plot_correlation_map(temp, var_limit, labels, plot_title)

% define start and stop color of colormap
startColor   = [156, 140, 189] / 255;
middleColor = [255, 255, 255] / 255;
endColor   = [208, 169, 55] / 255;

% Number of colormap levels
N = 256; 

% Generate linearly interpolated colormap
cmap1 = [linspace(startColor(1), middleColor(1), N/2)', ...
    linspace(startColor(2), middleColor(1), N/2)', ...
    linspace(startColor(3), middleColor(1), N/2)'];
cmap2 = [linspace(middleColor(1), endColor(1), N/2)', ...
    linspace(middleColor(1), endColor(2), N/2)', ...
    linspace(middleColor(1), endColor(3), N/2)'];

% if positive and negative: merge the two colormap, otherwise use just one
% to have always white as 0
if var_limit(1)<0
    cmap=[cmap1; cmap2];
else
    cmap=flip(cmap2);
end


temp(triu(true(size(temp)), 1)==0) = NaN; % Set triangular to NaN
figure('units','normalized','position',[0.2 0.2 0.3 0.4])
h = heatmap(temp, 'Colormap', colormap(cmap));
h.CellLabelFormat = '%.2f'; % Format text with 2 decimal places
h.ColorLimits = var_limit;
h.MissingDataColor = [.5 .5 .5];
h.XDisplayLabels=labels;
h.YDisplayLabels=labels;
title(plot_title)

end
