function [g,rang] = DYNOT4D__ngaussian(x,pos,wid,n)
%  ngaussian(x,pos,wid) = peak centered on x=pos, half-width=wid
%  x may be scalar, vector, or matrix, pos and wid both scalar
% Shape is Gaussian when n=1. Becomes more rectangular as n increases.
%  T. C. O'Haver, 2006
% Example: ngaussian([1 2 3],1,2,1) gives result [1.0000    0.5000    0.0625]
g = exp(-((double(x)-pos)./(0.6006.*wid)) .^(2*round(n)));
rang = zeros(size(g));
rang((abs(x-pos) <= wid/2)) = 1; 