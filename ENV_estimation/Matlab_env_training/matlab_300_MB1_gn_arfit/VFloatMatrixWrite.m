function VFloatMatrixWrite( filename, theMatrix)
%
% store matrix in binary speech vectors VFloat format on disk
%

fid=fopen(filename, 'wb');

[nr,ne] = size(theMatrix);
fwrite(fid, nr, 'int32');
for i=1:nr,
    fwrite(fid, ne, 'int32');
    fwrite(fid, theMatrix(i,:), 'float32');
end

fclose( fid);
