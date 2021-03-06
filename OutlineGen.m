close all
clear all

clc

self_restraint=1; %set to 0/false if there aren't any self-restraint features

% 
filenames={'outline_top1.txt','outline_top2.txt','outline_top3.txt'...
    'outline_top4.txt','outline_top5.txt','outline_top6.txt',...
    'outline.txt'};
key={'k-','k-','k-','k-','k-','k-','b-'};
zmax=0;

if self_restraint

figure;hold on;
for j=1:length(filenames)
    A{j}=dlmread(filenames{j});
    plot3(A{j}(:,1),A{j}(:,2),A{j}(:,3),key{j});
    %find high point on surface
    if max(A{j}(:,3))>zmax
        zmax=max(A{j}(:,3));
    end
end

axis equal; xlabel('x (mm)'); ylabel('y (mm)'); zlabel('z (mm)');
view([-30 30]); daspect([1 1 0.1]); set(gcf,'color','w');
lc=1; %line count
for j=1:6
B=abs(diff(A{j}(:,3)));

%find the edges of the self-restraint features
ind1=find(B>0.05,1,'first');
ind2=find(B>0.05,1,'last');

if j==1
    linepnts{lc}(1,:)=A{j}(ind1-1,1:2);
    linepnts{lc+1}(1,:)=A{j}(ind2+1,1:2);
end
if j==2
    linepnts{lc}(2,:)=A{j}(ind1-1,1:2);
    linepnts{lc+1}(2,:)=A{j}(ind2+1,1:2);
end
if j==3
    linepnts{lc}(3,:)=A{j}(ind1-1,1:2);
    linepnts{lc+1}(3,:)=A{j}(ind2+1,1:2);
end

if j==4
    lc=3;
    linepnts{lc}(1,:)=A{j}(ind1-1,1:2);
    linepnts{lc+1}(1,:)=A{j}(ind2+1,1:2);
end

if j==5
    linepnts{lc}(2,:)=A{j}(ind1-1,1:2);
    linepnts{lc+1}(2,:)=A{j}(ind2+1,1:2);
end

if j==6
    linepnts{lc}(3,:)=A{j}(ind1-1,1:2);
    linepnts{lc+1}(3,:)=A{j}(ind2+1,1:2);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Do first island
[a,b,c,~]=linefit(linepnts{1}(:,1),linepnts{1}(:,2));

%create line segment consisting of the 1.1 min/max y value
miny=min(A{end}(:,2)); maxy=max(A{end}(:,2));
% As per Xuanang Liu:
if maxy > 0
	maxy=1.1*maxy;
else
	maxy=0.9*maxy;
end
if miny > 0
	miny=0.9*miny;
else
	miny=1.1*miny;
end
y=[miny maxy];

%original code didn't handle negative values for y
% miny=min(A{end}(:,2)); maxy=max(A{end}(:,2));
% miny=0.9*miny; maxy=1.1*maxy;
% y=[miny maxy];


x=-b/a.*y-c/a;

X=poly2poly([x; y],[A{end}(:,1)'; A{end}(:,2)']);
X=X(:,1:2)';


%find the points closest to the points identified by X

for j=1:size(X,1);
    distance = sqrt((A{end}(:,1)-X(j,1)).^2+(A{end}(:,2)-X(j,2)).^2 );
    [~,ind]=min(distance);
    I(j)=ind;
    plot(A{end}(ind,1),A{end}(ind,2),'kx');
end
outline{1}=[A{end}(1:I(1),1:3);A{end}(I(2):end,1:3)];
plot(outline{1}(:,1),outline{1}(:,2),'r-');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Do second island
[a,b,c,~]=linefit(linepnts{2}(:,1),linepnts{2}(:,2));
x=-b/a.*y-c/a;
X=poly2poly([x; y],[A{end}(:,1)'; A{end}(:,2)']);


[a,b,c,~]=linefit(linepnts{3}(:,1),linepnts{3}(:,2));
x=-b/a.*y-c/a;
X2=poly2poly([x; y],[A{end}(:,1)'; A{end}(:,2)']);

X=[X(:,1:2)';X2(:,1:2)']; clear X2;
plot(X(:,1),X(:,2),'ro');

for j=1:size(X,1);
    distance = sqrt((A{end}(:,1)-X(j,1)).^2+(A{end}(:,2)-X(j,2)).^2 );
    [~,ind]=min(distance);
    I(j)=ind;
    
end

outline{2}=[A{end}(I(1):I(3),1:3);A{end}(I(4):I(2),1:3);A{end}(I(1),1:3)];

clear I;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Do third island
[a,b,c,~]=linefit(linepnts{4}(:,1),linepnts{4}(:,2));
x=-b/a.*y-c/a;
X=poly2poly([x; y],[A{end}(:,1)'; A{end}(:,2)']);
X=X(:,1:2)';


for j=1:size(X,1);
    distance = sqrt((A{end}(:,1)-X(j,1)).^2+(A{end}(:,2)-X(j,2)).^2 );
    [~,ind]=min(distance);
    I(j)=ind;
    plot(A{end}(ind,1),A{end}(ind,2),'kx');
end
outline{3}=[A{end}(I(1):I(2),1:3);A{end}(I(1),1:3)];

else %no self restraint, just a single outline

figure;hold on;
j=1;
A{j}=dlmread(filenames{end});
plot3(A{j}(:,1),A{j}(:,2),A{j}(:,3),key{j});
%find high point on surface
if max(A{j}(:,3))>zmax
    zmax=max(A{j}(:,3));
end
outline=A;
end %self_restraint

% plot it
figure; hold on;
for j=1:length(outline)
    plot(outline{j}(:,1),outline{j}(:,2),'k-');
    cent=mean(outline{j}(:,1:2));
    cent(1)=(min(outline{j}(:,1))+max(outline{j}(:,1)))/2;
    t=text(cent(1),cent(2),num2str(j));
    set(t,'HorizontalAlignment','center');
end
axis equal; axis tight
xlabel('x (mm)'); ylabel('y (mm)');
set(gcf,'color','w');

%create .mat file with the outlines
save(sprintf('Discretized_%s.mat',filenames{end}(1:end-4)),'outline','zmax','self_restraint');




