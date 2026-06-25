function [H, pValue, W] = ShapiroWilkTest(x, alpha)
% SHAPIRO_WILK  Shapiro-Wilk / Shapiro-Francia test for normality.
%
%   [H, pValue, W] = ShapiroWilkTest(X)
%   [H, pValue, W] = ShapiroWilkTest(X, ALPHA)
%
%   Tests the null hypothesis that the data X comes from a normal
%   distribution with unspecified mean and variance.
%
%   When kurtosis(X) > 3 (leptokurtic), the Shapiro-Francia variant is
%   used, which is more powerful for heavy-tailed samples.
%   Otherwise the standard Shapiro-Wilk W test is used.
%
% INPUTS
%   X     - vector of observations (3 <= n <= 5000, NaNs are ignored)
%   ALPHA - significance level (scalar, default = 0.05)
%
% OUTPUTS
%   H      - 0: do not reject normality  |  1: reject normality
%   pValue - probability of observing W this extreme under H0
%   W      - Shapiro-Wilk (or Shapiro-Francia) test statistic
%
% IMPLEMENTATION NOTES
%   This function is an independent implementation based solely on the
%   primary literature listed below. No third-party MATLAB code was used
%   or adapted.
%
% REFERENCES
%   [1] Royston P. (1992). "Approximating the Shapiro-Wilk W-test for
%       non-normality." Statistics and Computing, 2, 117-119.
%
%   [2] Royston P. (1993a). "A pocket-calculator algorithm for the
%       Shapiro-Francia test for non-normality: an application to
%       medicine." Statistics in Medicine, 12, 181-184.
%
%   [3] Royston P. (1993b). "A toolkit for testing non-normality in
%       complete and censored samples." The Statistician, 42, 37-43.
%
%   [4] Royston P. (1995). "Remark AS R94." Applied Statistics, 44,
%       547-551.
%
%   [5] Shapiro S.S. & Wilk M.B. (1965). "An analysis of variance test
%       for normality (complete samples)." Biometrika, 52, 591-611.
%
% LICENSE
%   This file may be freely used, modified, and distributed.
%   Please cite the references above in any publication.
%
% -------------------------------------------------------------------------

%--- Input validation -----------------------------------------------------

if nargin < 2 || isempty(alpha)
    alpha = 0.05;
end

if ~isscalar(alpha) || alpha <= 0 || alpha >= 1
    error('shapiro_wilk:badAlpha', ...
          'ALPHA must be a scalar strictly between 0 and 1.');
end

if ~isvector(x)
    error('shapiro_wilk:badInput', 'X must be a vector.');
end

x = x(:);               % column vector
x = x(~isnan(x));       % remove NaNs

n = numel(x);

if n < 3
    error('shapiro_wilk:tooSmall', ...
          'X must contain at least 3 non-NaN observations.');
end
if n > 5000
    warning('shapiro_wilk:tooLarge', ...
            'Results may be inaccurate for n > 5000.');
end

%--- Sort data and compute expected normal order statistics ---------------
% Blom (1958) approximation for expected values of order statistics,
% as used throughout Royston (1992, 1993b, 1995).

x      = sort(x);
mtilde = norminv(((1:n)' - 3/8) / (n + 1/4));   % eq. used in [1,3,4]

%--- Branch: Shapiro-Francia (leptokurtic) vs Shapiro-Wilk ---------------

if kurtosis(x) > 3

    % =====================================================================
    % SHAPIRO-FRANCIA TEST  [2][3]
    % Better power for leptokurtic (heavy-tailed) distributions.
    % =====================================================================

    % Weights: normalised expected order statistics  [2, p. 182]
    weights = mtilde / sqrt(mtilde' * mtilde);

    % W' statistic  [2, p. 182]
    W = (weights' * x)^2 / sum((x - mean(x)).^2);

    % Normalising transformation for W'  [2, p. 183]
    nu    = log(n);
    u1    = log(nu) - nu;
    u2    = log(nu) + 2 / nu;
    mu    = -1.2725 + 1.0521 * u1;
    sigma =  1.0308 - 0.26758 * u2;

    % Normalised statistic and p-value (upper tail)  [2, p. 183]
    z      = (log(1 - W) - mu) / sigma;
    pValue = 1 - normcdf(z);

else

    % =====================================================================
    % SHAPIRO-WILK TEST  [1][3][4]
    % Better power for platykurtic (light-tailed) distributions.
    % =====================================================================

    % -- Compute the 'a' weight vector ------------------------------------
    %
    % The two extreme weights a(n) and a(n-1) are corrected via polynomial
    % approximations fitted by Royston (1992, p.117) and (1993b, p.38).
    % The remaining weights follow from the normalisation constraint.

    c = mtilde / sqrt(mtilde' * mtilde);  % normalised order stats
    u = 1 / sqrt(n);                      % convenient shorthand

    % Polynomial coefficients from Royston (1992, p.117) and (1993b, p.38)
    % for the two largest-magnitude weights:
    pc1 = [-2.706056,  4.434685, -2.071190, -0.147981,  0.221157,  c(n)  ];
    pc2 = [-3.582633,  5.682633, -1.752461, -0.293762,  0.042981,  c(n-1)];

    weights    = zeros(n, 1);
    weights(n) =  polyval(pc1, u);
    weights(1) = -weights(n);

    if n == 3
        % Special closed form for n = 3  [1, p.117]
        weights(1) = -1/sqrt(2);
        weights(3) =  1/sqrt(2);
        phi = 1;

    elseif n <= 5
        % Only the outermost pair is corrected; phi normalises the rest
        weights(n-1) =  polyval(pc2, u);
        weights(2)   = -weights(n-1);
        phi = (mtilde'*mtilde ...
               - 2*mtilde(n)^2 ...
               - 2*mtilde(n-1)^2) ...
            / (1 - 2*weights(n)^2 - 2*weights(n-1)^2);
        weights(3) = mtilde(3) / sqrt(phi);   % only one middle element

    else
        % n >= 6: two outermost pairs corrected; middle block normalised
        weights(n-1) =  polyval(pc2, u);
        weights(2)   = -weights(n-1);
        phi = (mtilde'*mtilde ...
               - 2*mtilde(n)^2 ...
               - 2*mtilde(n-1)^2) ...
            / (1 - 2*weights(n)^2 - 2*weights(n-1)^2);
        weights(3:n-2) = mtilde(3:n-2) / sqrt(phi);
    end

    % -- W statistic  [5, eq.1] -------------------------------------------
    W = (weights' * x)^2 / sum((x - mean(x)).^2);

    % -- Normalising transformation and p-value ---------------------------
    %
    % Three separate approximations depending on sample size,
    % from Royston (1992, p.118) and (1993b, p.40, Table 1).

    ln_n = log(n);

    if n == 3
        % Exact result for n = 3  [1, p.117] derived from [5]
        pValue = 6/pi * (asin(sqrt(W)) - asin(sqrt(3/4)));
        H = (pValue < alpha);
        return;                    % early return; no further transformation

    elseif n <= 11
        % Polynomial fits in n (not log n)  [1, p.118], [3, p.40 Table 1]
        pc3 = [-0.0006714,  0.0250540, -0.39978,  0.54400];
        pc4 = [-0.0020322,  0.0627670, -0.77857,  1.38220];
        pc7 = [ 0.459,     -2.273];

        mu    = polyval(pc3, n);
        sigma = exp(polyval(pc4, n));
        gamma = polyval(pc7, n);

        % Transformation avoiding rounding near W = 1  [1, p.118]
        z = (-log(gamma - log(1 - W)) - mu) / sigma;

    else
        % Polynomial fits in log(n) for n > 11  [1, p.118], [3, p.40]
        pc5 = [ 0.00389150, -0.083751, -0.31082, -1.5861];
        pc6 = [ 0.00303020, -0.082676, -0.48030];

        mu    = polyval(pc5, ln_n);
        sigma = exp(polyval(pc6, ln_n));

        z = (log(1 - W) - mu) / sigma;
    end

    % p-value from upper tail of N(0,1)  [1, p.119]
    pValue = 1 - normcdf(z);

end

% Clamp to valid probability range (floating-point safety)
pValue = max(0, min(1, pValue));

% Hypothesis decision
H = (pValue < alpha);

end