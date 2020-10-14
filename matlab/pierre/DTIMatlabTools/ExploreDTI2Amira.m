function ExploreDTI2Amira(TractStructure,fname);
%ExploreDTI2Amira
%A simple function to write an .ami file with the
%information contained in a tract created using
%Explore DTI.
%
%Use:  just type ExploreDTI2Amira(tract,'tractname.ami');


file = fopen(fname, 'w');
numLines=length(TractStructure);

numVertex=0;
for t=1:numLines
   thisLine=cell2mat(TractStructure(t));   
   numVertex=numVertex+length(thisLine); 
end

% Header.
fprintf(file, '#AmiraMesh ASCII 1.0\n\n');
fprintf(file, 'define Lines %d\n', numVertex+numLines);
fprintf(file, 'define Vertices %d\n', numVertex);
fprintf(file, 'Parameters {\n');
fprintf(file, 'ContentType "HxLineSet"\n}\n');
fprintf(file, 'Vertices { float[3] Coordinates } = @1\n');
fprintf(file, 'Vertices { float Data } = @2\n');
fprintf(file, 'Lines { int LineIdx } = @3\n\n');


fprintf(file, '@1 #xyz coordinates\n');
for t=1:numLines
    thisLine=double(cell2mat(TractStructure(t)));
    for u=1:length(thisLine)
        fprintf(file,'%f %f %f\n',thisLine(u,1),thisLine(u,2),thisLine(u,3));  
    end
end


fprintf(file, '\n\n');
fprintf(file, '@2 #Vertex values\n');
% AT THIS POINT ALL VERTICES HAVE A VALUE OF ONE.  It is possible to put FA
% ADC or any value in this section.
values=ones(1,numVertex);
fprintf(file,'%d ',values);  



fprintf(file, '\n\n');
fprintf(file, '@3 #Line Indices\n');

index=0;
for t=1:numLines
    thisLine=double(cell2mat(TractStructure(t)));
    lastIndex=length(thisLine)+index-1;
    indices=meshgrid(index:lastIndex,1);
    fprintf(file,'%d ',indices);
    fprintf(file,'-1\n');     
    index=lastIndex+1;
end



fclose(file);
disp('Done');






