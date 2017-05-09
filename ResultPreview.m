function ResultPreview(MeasfileName)

A=dlmread(MeasfileName);


H=scatter3(A(:,1),A(:,2),A(:,3),10,A(:,3),'o','filled');
HChild=get(H,'Children');
set(HChild,'Markersize',0.75);
axis equal; xlabel('x (mm)'); ylabel('y (mm)'); zlabel('z (mm)');
axis equal;
daspect([1 1 0.01]);
view(2);
h=colorbar;
xlabel(h,'z (mm)');
end %ResultPreview
