function fx_plot_correlation_map(temp, var_limit, labels, plot_title, showDiag)
%PLOT_CORRELATION_MAP  Visualize a correlation (or similarity) matrix as a heatmap.
%
%   plot_correlation_map(temp, var_limit, labels, plot_title, showDiag)
%
%   Inputs:
%       temp        - Square numeric matrix (e.g., correlation matrix).
%       var_limit   - Two-element vector specifying the color scale limits
%                     [min, max]. Use [−1, 1] for correlations.
%       labels      - Cell array of strings for axis tick labels.
%       plot_title  - String with the title of the plot.
%       showDiag    - (optional) Logical flag:
%                       true  → show diagonal values (default)
%                       false → replace diagonal with dark gray (NaN)
%
%   This function:
%       • Builds a custom diverging colormap with white centered at 0
%       • Plots the matrix as a heatmap with formatted labels
%       • Hides the diagonal and replaces it with dark gray squares
%         (since diagonal values are always 1 in correlation matrices)
%       • Ensures square layout for better visual interpretation
%
%   Example:
%       corrMat = corr(randn(30,5));
%       plot_correlation_map(corrMat, [-1 1], {'A','B','C','D','E'}, 'Correlation Map')

%% Handle optional input
if nargin < 5
    showDiag = true; % default
end

%% Define custom colormap
% Start, middle, and end colors (RGB normalized to [0,1])
startColor   = [156, 140, 189] / 255; % purple 
middleColor = [255, 255, 255] / 255;  % white (zero)
endColor   = [208, 169, 55] / 255;    % gold 
N = 256;  % Number of colormap levels

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

%% Prepare data for plotting
% Copy the data so original isn't changed
temp_plot = temp;

% Optionally mask diagonal
if ~showDiag
    temp_plot(1:size(temp_plot,1)+1:end) = NaN;
end

%% Create heatmap
figure('units','normalized')
axis equal
h = heatmap(temp_plot, 'Colormap', colormap(cmap));
h.CellLabelFormat = '%.2f'; % Format text with 2 decimal places
h.ColorLimits = var_limit;
h.MissingDataColor = [.5 .5 .5];
h.XDisplayLabels=labels;
h.YDisplayLabels=labels;
title(plot_title)

% Remove the automatic colorbar and replace it
cb = findall(gcf,'Type','Colorbar'); % find heatmap colorbar
delete(cb)                            % remove it

colormap(cmap)                        % apply custom colormap to figure
h.caxis(var_limit)                      % enforce same limits
colorbar                              % add a clean colorbar (ignores NaN)

end