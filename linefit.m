function [ a, b, c, fitness] = linefit( x, y )
% This function finds the best fitting parameters of a 2D line with
% 'ax+by+c=0' equation and it returns the value of the sum of the 
% squares of the distances of the n points from the line as fitness score.
% - inputs:
%         x................... 1xN array
%         - x coordinates of points
%         y................... 1xN array
%         - y coordinates of points
% - output:
%         a, b, c and fitness.......... scalar
%         - a, b and c are the estimated line parameters.
%         - fitness is the minimized value of the objective function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MJR 15_07_22 Modified from ORTHO2DLINEFIT.m, author unknown
[mx nx ] = size(x);
[my ny ] = size(y);

if(mx ~= my || nx ~= ny)
  error('x and y must have the same size');
end

if(nx ~= 1 && mx ~= 1)
  error('x and y must be either column vector or row vector');
end

r = length(x);

s = sum(x);
t = sum(y);

u = sum(x.^2);
v = sum(x.*y);
w = sum(y.^2);

rvst = r*v - s*t;
s2t2rvrw = s^2-t^2-r*u+r*w;

if(rvst == 0.0 && s2t2rvrw == 0.0)
  c = 0;
  b = rand;
  a = -b*t/s;
  fitness = sum( (a*x+b*y+c).^2 / (a^2 + b^2) );
elseif(rvst == 0.0)
  a = 0;
  b = 1;
  c = -t/r;
  Sa = sum( (a*x+b*y+c).^2 / (a^2 + b^2) );
  a = 1;
  b = 0;
  c = -s/r;
  Sb = sum( (a*x+b*y+c).^2 / (a^2 + b^2) );
  if(Sa < Sb)
    a = 0;
    b = 1;
    c = -t/r;
    fitness = Sa;
  else
    a = 1;
    b = 0;
    c = -s/r;
    fitness = Sb;
  end
else
  Q = s2t2rvrw / rvst;
  p = roots([1 -Q -1]); % p = -a/b
  q = (s*p-t)/r; % q = c/b
  S1 = sum( (-p(1)*x+y+q(1)).^2 / (p(1)^2 + 1) );
  S2 = sum( (-p(2)*x+y+q(2)).^2 / (p(2)^2 + 1) );
  if(S1 < S2)
    b = rand;
    a = -p(1)*b;
    c = q(1)*b;
    fitness = S1;
  else
    b = rand;
    a = -p(2)*b;
    c = q(2)*b;
    fitness = S2;
  end    
end
  
end