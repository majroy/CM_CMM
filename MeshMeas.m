close all
clear all
clc


P=5; %Seed spacing, in mm
xyOff=0.1; %outline offset in mm
redo=true;
refine=0; %Mesh can be refined from P to 
% to P/2 when refine=0 at x=mean(x) over a line described by refine= an Nx2
% matrix of x,y values. For no refinement, set equal to an empty set.
OutlineGenFile='Discretized_outline.mat';


%handle directories - make them if they don't exist
Pdir='Programs';
Rdir='Results';

if exist(Pdir,'dir') ~= 7
    mkdir(Pdir);
end

if exist(Rdir,'dir') ~= 7
    mkdir(Rdir);
end
    
%handle file names NOTE CHARACTER LIMITS ON GPakFName
GPakFName='MyGPakFName'; %what appears in MCOSMOS
MeasFileName = 'MyMeasFileName.txt';

PPgm = fullfile(Pdir,'MyPartProgram'); %*.agw file extension
MeasFile=GetFullPath(fullfile(Rdir,MeasFileName));

load(OutlineGenFile);

%Delete the existing mesh file if it exists and if redo is true.
if redo
    if exist(strcat(GPakFName,'MeshIntermediate.mat'),'file') ==2 
        delete(strcat(GPakFName,'MeshIntermediate.mat'));
    end
end

%for timing
tic

%check if a mesh file exists, skip to loading it if it's found.
if exist(strcat(GPakFName,'MeshIntermediate.mat'),'file') ~=2 
    fprintf('\nNo mesh file found...\n');

if self_restraint
    runs=3;
else
    runs=1;
end

for J=1:runs
%first island
contour=outline{J};

%have to convert to int64 for clipper, use an arbitrary scaling factor
scale=2^15;
Inpol.x=int64(contour(:,1)*scale); Inpol.y=int64(contour(:,2)*scale);
Outpol=clipper(Inpol,-(xyOff)*scale,1); %pull in proximity of the edge by a small amount

%convert Outpol back to reals
xOff=[Outpol(1).x; Outpol(1).x(1)]/scale;
yOff=[Outpol(1).y; Outpol(1).y(1)]/scale;

plot(xOff,yOff,'b-'); hold on;

%respace the outline according to the pitch (ie seed the outline by length)
[contour,Perimeter]=respace_equally([xOff yOff],P);
plot(contour(:,1),contour(:,2),'k-');


%find longest axis of the outline, extract midpoints (as needed)
bbox=[min(contour(:,1)) min(contour(:,2));...
    max(contour(:,1)) max(contour(:,2))];
if J==2 && ~isempty(refine)
if refine(1)==0;
    aspect=diff(bbox);
[~,i]=min(aspect);
if i==1 %then the specimen is longest in the y direction
    tp=[bbox(1,1),bbox(1,2)+aspect(2)/2; bbox(2,1),bbox(2,2)-aspect(2)/2];
else %the specimen is longest in the x direction
    tp=[bbox(1,1)+aspect(1)/2,bbox(1,2); bbox(2,1)-aspect(1)/2,bbox(2,2)];
end
for j=1:2
    D=contour-ones(size(contour,1),1)*tp(j,:);
    [~,idx]=min(sum(D.^2,2));
    tp(j,:)=contour(idx,:);
end
else
    tp=refine;
end


fstats=@(p,t) fprintf('%d nodes, %d elements, min quality %.2f\n', ...
                      size(p,1),size(t,1),min(simpqual(p,t)));

fprintf('Now meshing, %0.3f mm target spacing.\nUsing %d seeds on a perimeter of %0.3f mm ...\n', ...
    Perimeter/size(contour,1),size(contour,1), Perimeter);

fd=@(p) dpoly(p,contour);
fh=@(p) min(P/2+P*0.01*abs(dpoly(p,tp)),P);


[p,t]=distmesh2d(fd,fh,P/2,bbox,...
    contour);
fstats(p,t);
else
fstats=@(p,t) fprintf('%d nodes, %d elements, min quality %.2f\n', ...
                      size(p,1),size(t,1),min(simpqual(p,t)));
fprintf('Now meshing, %0.3f mm target spacing.\nUsing %d seeds on a perimeter of %0.3f mm ...\n', ...
    Perimeter/size(contour,1),size(contour,1), Perimeter);
[p,t]=distmesh2d(@dpoly,@huniform,P,bbox,...
    contour,contour);

fstats(p,t);
end

all_contour{J}=contour; all_Perimeter{J}=Perimeter; all_p{J}=p; all_t{J}=t;
clear contour Perimeter p t;
end %for
save(strcat(GPakFName,'MeshIntermediate.mat'),...
    'all_contour','all_Perimeter','all_p','all_t');
else
    fprintf('\nLoading mesh file...\n');
    load(strcat(GPakFName,'MeshIntermediate.mat'))

end

figure; axis equal; axis off; hold on
for island=1:runs

patch('vertices',all_p{island},...
    'faces',all_t{island},'edgecol','k','facecol',[.8,.9,1]);
end

%mash all the points back together again
if self_restraint
    p=[all_p{1};all_p{2};all_p{3}];
else
    p=all_p{:};
end

%%uncomment the following to preview the data
% for j=1:length(p)
%     if mod(j,100)==0
%         plot(p(1:j,1),p(1:j,2),'r.');
%         drawnow;
%     end
% end
toc

meshgen_cmmpnts(zmax+1.5,PPgm,GPakFName,MeasFile,p,'new')
