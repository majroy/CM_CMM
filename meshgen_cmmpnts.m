% err = meshgen_cmmpnts(Zmeas,PPgm,GPakFName,Measfile,p,status)
% Generates a Mitutoyo PPgm.agw COSMOS ascii script file with instructions
% to measure points on a surface in peck mode suitable for contour 
% measurements.
%
% This function does the following:
% 1) Writes an ascii GEOPAK file containing appropriate commands for each
% point. This includes instructions on how to perform the measurement, as
% well as the frequency to write from MCOSMOS to an external text file.
% 2) Will parse a measurement file in the event of a system crash and will 
% write a new GEOPAK file for points that still remain.
%
% INPUTS:
% -Zmeas: standoff height to start henpeck measurement
% -PPgm: string containing full path to where the *agw file will be written
% -GPakFName: what the program will be called in MCOSMOS (<8 characters)
% -p: N x 2 list of coordinates
% -status: either 'new' or 'recover'
%               'new' - an existing measurement file does not exist
%               'recover' - read the corresponding measurment file and
%               write a program containing the points that are missing (NOT
%               IMPLEMENTED!!!)
%
% OUTPUTS:
% Output is a *.agw file which contains all necessary commands
%
% USE:
% Command line from a m-file. No GUI support.
%
% OTHER NOTES
% Based on code by Greg Johnson (2008) which populated a *agw file with a
% rectangular grid of data based on an outline.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MJR 15_06_14 First version
% MJR 15_07_23 Removed standoff variable
function err = meshgen_cmmpnts(Zmeas,PPgm,GPakFName,MeasFile,p,status)
if nargin~=6
    fprintf('\nError in specifiing meshgen_cmmpnts parameters, quitting.\n')
    err=1; return;
else
    disp('Processing the following:')
    fprintf('Writing part program(s) to: %s.agw\n',PPgm);
    fprintf('Measurements will be written to: %s\n',MeasFile);
    fprintf('MCOSMOS alias: %s\n',GPakFName);
    err =0;
end

zclearance=Zmeas+100; %clearance height off of the surface
zmeasurement=Zmeas; %probe measurement start point

% try
%     fid=fopen(OutlineFile,'r');
%     pnts=textscan(fid,'%f %f %f');
%     fclose(fid);
%     x=pnts{1}; y=pnts{2}; z=pnts{3};
%     clear pnts
% catch BadFile
%     if strcmp(BadFile.identifier, 'MATLAB:FileIO:InvalidFid')
%       fprintf( ...
%          '\nCannot open file %s. Quitting.\n', ...
%          OutlineFile);
%      return
%     end
% end

fprintf('\nGenerating part program program...\n')
fid=openPartProgram(PPgm,GPakFName);
discreteheaderPartProgram(fid,zmeasurement,zclearance)
points=1;
contourndx=1;
totalnumlines=0;

disp('Generating code...');
fprintf(...
      'Number of measurement points: %d\n',length(p));
  fprintf(...
      '%1.1f seconds/pnt: est. time is %3.3f hrs\n',...
      26.71/10,length(p)*26.71/10/3600);
for point=1:size(p,1)
    fprintf(fid,'PTMEAS/CART,%3.3f,%3.3f,''ZMEASUREMENT'',VECCOMP,0,0,-1\n',...
      p(point,1),p(point,2));
  totalnumlines=totalnumlines+1;
  if points>100
       fprintf(fid,'ENDMES\n');
       if contourndx==1  % overwrite any exisiting file
        fprintf(fid,'CONTOUR/EXPORT,"Scan",NUMBER=1,"%s"\n',MeasFile);
        else  % append to existing file
        fprintf(fid,'CONTOUR/EXPORT,"Scan",NUMBER=1,"%s",APPEND\n',...
            MeasFile);
      end
      fprintf(fid,'CONTOUR/MEAS, "Scan", NUMBER=1\n');
      points=1;
      contourndx=contourndx+1;
      % *** next line also changed from +2 to +1
      totalnumlines=totalnumlines+1;
    else
      points=points+1;
  end
end
  if points~=1
    fprintf(fid,'ENDMES\n');
    if contourndx==1  % overwrite any exisiting file
      fprintf(fid,'CONTOUR/EXPORT,"Scan",NUMBER=1,"%s"\n',MeasFile);
    else  % append to existing file
      fprintf(fid,'CONTOUR/EXPORT,"Scan",NUMBER=1,"%s",APPEND\n',...
            MeasFile);
    end

  end
  closePartProgram(fid)
  fprintf('Number of lines in last program ~= %d\n',totalnumlines);    




function fid=openPartProgram(partprogram,GPakFName)
%% start part program
fid=fopen([partprogram '.agw'],'w+');
fprintf(fid,'$$ Matlab generated scan lines\n');
fprintf(fid,'\n');
fprintf(fid,['FILNAM/ "' GPakFName '"\n']);
fprintf(fid,'\n');
fprintf(fid,'SNSLCT/1\n');
fprintf(fid,'DATSET/MCS\n');

fprintf(fid,'CNCON / MESVEL = DEFALT, POSVEL = HIGH, APPRCH = 0.3\n');
fprintf(fid,'\n');
end

function discreteheaderPartProgram(fid,zmeasurement,zclearance)
fprintf(fid,'CONTOUR/MEAS, "Scan", NUMBER=1\n');
fprintf(fid,'\n');
fprintf(fid,'ASSIGN/''ZMEASUREMENT''="%f",FIXP=4\n',zmeasurement);
fprintf(fid,'ASSIGN/''ZCLEAR''="%f",FIXP=4\n',zclearance);
fprintf(fid,'DRIVE/ZAXIS,''ZCLEAR''\n');

fprintf(fid,'\n');
end


function closePartProgram(fid)
fprintf(fid,'ENDFIL\n');
fclose(fid);
end

end %meshgen_cmmpnts