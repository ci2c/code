function write_annotation(filename, vertices, label, ct)
% write_annotation(filename, vertices, label, ct)
%
% Only writes version 2...
%
% vertices expected to be simply from 0 to number of vertices - 1;
% label is the vector of annotation
%
% ct is a struct
% ct.numEntries = number of Entries
% ct.orig_tab = name of original ct
% ct.struct_names = list of structure names (e.g. central sulcus and so on)
% ct.table = n x 5 matrix. 1st column is r, 2nd column is g, 3rd column
% is b, 4th column is flag, 5th column is resultant integer values
% calculated from r + g*2^8 + b*2^16 + flag*2^24. flag expected to be all 0

fp = fopen(filename, 'w', 'b');

% first write vertices and label

count = fwrite(fp, int32(length(label)), 'int');
if(count~=1)
   error('write_annotation: Writing #vertices/labels not successful!!');
end

temp = zeros(length(label)*2,1);
temp(1:2:end) = vertices;
temp(2:2:end) = label;
temp = int32(temp);

count = fwrite(fp, int32(temp), 'int');
if(count~=length(temp))
   error('write_annotation: Writing labels/vertices not successful!!');
end

%Write that ct exists
count = fwrite(fp, int32(1), 'int');
if(count~=1)
   error('write_annotation: Unable to write flag that ct exists!!');
end

%write version number
count = fwrite(fp, int32(-2), 'int');
if(count~=1)
    error('write_annotation: Unable to write version number!!');
end

%write number of entries
count = fwrite(fp, int32(ct.numEntries), 'int');
if(count~=1)
    error('write_annotation: Unable to write number of entries in ct!!');
end

%write original table
orig_tab = [ct.orig_tab char(0)];
count = fwrite(fp, int32(length(orig_tab)), 'int');
if(count~=1)
    error('write_annotation: Unable to write length of ct source!!');
end

count = fwrite(fp, orig_tab, 'char');
if(count~=length(orig_tab))
    error('write_annotation: Unable to write orig_tab!!');
end

%write number of entries
count = fwrite(fp, int32(ct.numEntries), 'int');
if(count~=1)
    error('write_annotation: Unable to write number of entries in ct!!');
end

%write ct
for i = 1:ct.numEntries
    count = fwrite(fp, int32(i-1), 'int');
    if(count~=1)
        error('write_annotation: Unable to write structure number!!');
    end
    
    structure_name = [ct.struct_names{i} char(0)];
    count = fwrite(fp, int32(length(structure_name)), 'int');
    if(count~=1)
        error('write_annotation: Unable to write length of structure name!!');
    end

    count = fwrite(fp, structure_name, 'char');
    if(count~=length(structure_name))
        error('write_annotation: Unable to write structure name!!');
    end
    
    count = fwrite(fp, int32(ct.table(i, 1)), 'int');
    if(count~=1)
       error('write_annotation: Unable to write red color'); 
    end

    count = fwrite(fp, int32(ct.table(i, 2)), 'int');
    if(count~=1)
       error('write_annotation: Unable to write blue color'); 
    end
    
    count = fwrite(fp, int32(ct.table(i, 3)), 'int');
    if(count~=1)
       error('write_annotation: Unable to write green color'); 
    end
    
    count = fwrite(fp, int32(ct.table(i, 4)), 'int');
    if(count~=1)
       error('write_annotation: Unable to write padded color'); 
    end
end

fclose(fp);

