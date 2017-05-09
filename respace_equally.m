% respace points equally around a given 2D hull B which is a Nx2 matrix of
% points, and xNew and yNew are new coordinates. Returns the perimeter of 
% the hull.Order is preserved.
function [Hull,Perimeter]=respace_equally(B,pitch)
%Get total distance between each point and then take cumulative sum;
%parametric coordinate that makes small steps for points close together and
%larger for ones further apart.
distance = sqrt(sum(diff(B,1,1).^2,2));  %# Distance between subsequent points
s = [0; cumsum(distance)];               %# Parametric coordinate

%Solve for the perimeter
Perimeter=sum(distance);
nPts=round(Perimeter/pitch);

%interpolate for a new set of points equally spaces along lines joining
%points
sNew = linspace(0,s(end),nPts).';   %'# nPts evenly spaced points from 0 to s(end)
xNew = interp1q(s,B(:,1),sNew);     %# Interpolate new x values
yNew = interp1q(s,B(:,2),sNew);     %# Interpolate new y values
Hull=[xNew yNew];

%if the original points have to be in the new range of points (ie if size
%xNew>xOld) then do the following:
if length(xNew)>nPts
    [~,sortIndex] = sort([s; sNew]);  %# Sort all the parametric coordinates
    xAll = [B(:,1); xNew];               %# Collect the x coordinates
    xAll = xAll(sortIndex);              %# Sort the x coordinates
    yAll = [B(:,2); yNew];               %# Collect the y coordinate
    yAll = yAll(sortIndex);              %# Sort the y coordinates
    Hull=[xAll yAll];
end