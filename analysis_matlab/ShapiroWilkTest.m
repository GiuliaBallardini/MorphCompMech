function [H, pValue, W] = ShapiroWilkTest(x, alpha)
% ShapiroWilktest Shapiro-Wilk test for normality
%
% [H, pValue, W] = shapiroWilkTest(x, alpha)
%
% INPUTS:
%   x     - Data vector (3 <= n <= 5000)
%   alpha - Significance level (default: 0.05)
%
% OUTPUTS:
%   H      - 1 if reject normality, 0 if fail to reject
%   pValue - p-value of the test
%   W      - Shapiro-Wilk test statistic
%
% EXAMPLE:
%   x = randn(50, 1);
%   [H, p, W] = shapiroWilkTest(x, 0.05);

if nargin < 2
    alpha = 0.05;
end

x = x(:);
n = length(x);

if n < 3 || n > 5000
    error('Sample size must be between 3 and 5000.');
end

x = sort(x);

% --- Compute the 'a' coefficients via Royston (1992) approximation ---
m = norminv(((1:n)' - 3/8) / (n + 1/4));
m2 = m .^ 2;

% Weights for the linear combination
c = 1 / sqrt(m2' * m2);

% Shapiro-Wilk 'a' coefficients (simplified via normalized expected order stats)
a = zeros(n, 1);
an = c * m;          % full vector

% Only the upper half is needed
k = floor(n/2);
a(n:-1:n-k+1) =  an(1:k);
a(1:k)        = -an(1:k);

% W statistic
W = (a' * x)^2 / sum((x - mean(x)).^2);

% --- p-value via Royston (1992) log-normal approximation ---
pValue = swPValue(W, n);

H = (pValue < alpha);

end

% -------------------------------------------------------------------------
function p = swPValue(W, n)
% Approximation of the p-value based on Royston (1995)

if n <= 11
    % Small-sample polynomial approximation (Royston 1992)
    gamma = polyval([-2.273, 0.459], n);
    mu    = polyval([0.0038915, -0.083751, -0.31082, -1.5861], log(n));
    sigma = exp(polyval([0.00030302, -0.0082676, -0.4803], log(n)));
    z = (log(1 - W) - gamma - mu) / sigma;
else
    % Large-sample approximation
    mu    = polyval([0.0020322, -0.13606, -0.53584], log(n));
    sigma = exp(polyval([0.0030302,  -0.082676, -0.4803], log(n)));
    z = (log(1 - W) - mu) / sigma;
end

p = 1 - normcdf(z);
p = max(0, min(1, p));   % clamp to [0,1]

end