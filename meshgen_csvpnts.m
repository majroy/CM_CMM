% err = meshgen_cmmpnts(Zmeas,PPgm,p,status)
% Generates a csv file containing measurement locations for import to
% PC-DMIS or other coordinate measurement machines
%
% INPUTS:
% -Zmeas: standoff height to start henpeck measurement
% -PPgm: string containing full path to where the *csv file will be written
% -p: N x 2 list of coordinates
% -status: either 'new' or 'recover'
%               'new' - an existing measurement file does not exist
%               'recover' - read the corresponding measurment file and
%               write a program containing the points that are missing (NOT
%               IMPLEMENTED!!!)
%
% OUTPUTS:
% Output is a *.csv file which contains measurement start points and
% approach vectors.
%
% USE:
% Command line from a m-file.
%
% OTHER NOTES
% Based on code by Greg Johnson (2008) which populated a *agw file with a
% rectangular grid of data based on an outline.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MJR 15_06_14 First version
% MJR 15_07_23 Removed standoff variable
% MJR 19_03_12 Changed output to csv format N by [x,y,z,i=0,j=0,k=-1]
function err = meshgen_csvpnts(Zmeas,PPgm,p,status)
if nargin~=4
    fprintf('\nError in specifying meshgen_csvpnts parameters, quitting.\n')
    err=1; return;
else
    fprintf('Writing list of measurement points to %s.csv\n',PPgm);
    err =0;
end

%create measurement matrix
p_output = zeros(size(p,1),6); %initialize
p_output(:,end)=-1; %measurement direction
p_output(:,1:2)=p; %x,y location
p_output(:,3)=Zmeas;

%use csvwrite 
try
	csvwrite(strcat(PPgm,'.csv'),p_output);
catch
	warning('Failed to write csv file.');
	return
end

fprintf('List written.\n')

end %meshgen_csvpnts