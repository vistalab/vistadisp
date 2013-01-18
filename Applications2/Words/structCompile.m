function newStruct = structCompile(masterStruct)
% By feeding in a structure consisting of multiple substructures, one can
% combine them into a single, extended structure file.  Take for example
% two structures, fontParams and movieParams.  One would initially pack
% them into a master structure, manually or via a command like struct (ex:
% masterStruct = struct('fontParams',fontParams,'movieParams',movieParams).
% Once this is processed by structCompile, the resulting structure will be
% a combination of the fields within fontParams and movieParams.
%
% Author: rfb 9/26/08

structList = fieldnames(masterStruct);
nStructList = length(structList);

newStruct = masterStruct.(structList{1});
for i=2:nStructList
    subStructList = fieldnames(masterStruct.(structList{i}));
    nSubStructList = length(subStructList);
    for ii=1:nSubStructList
        newStruct.(subStructList{ii}) = masterStruct.(structList{i}).(subStructList{ii});
    end
end

    
    
    
    