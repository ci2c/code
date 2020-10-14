% Generate image key for data navigation
function [numImages, imageIndx, imageDims] = createXMLImageIndx(tree)
global PRIDE
PRIDEimageInfoNode = tree.getElementsByTagName(PRIDE.XML_IMAGE_KEY_HEADER);
% Extract unique index per image
numImages = PRIDEimageInfoNode.getLength;
for imgNo = 0:PRIDEimageInfoNode.getLength-1
    PRIDEimgKeyNode = PRIDEimageInfoNode.item(imgNo);
    PRIDEimgKeyAttribList = PRIDEimgKeyNode.getElementsByTagName(PRIDE.XML_ATTRIB_HEADER);
    attribsStruct = [];
    for attribNum = 0:PRIDEimgKeyAttribList.getLength-1
        elim = PRIDEimgKeyAttribList.item(attribNum);
        attribsStruct = getAttribFromElim(elim,attribsStruct);
    end
    imgKeyStruct(imgNo+1) = attribsStruct;
    if (strcmp(attribsStruct.Label_Type,'-'))
        attribsStruct.Label_Type = 'o';
    end
    keyString = ['key_' num2str(attribsStruct.Slice) '_'  num2str(attribsStruct.Echo)...
        '_'  num2str(attribsStruct.Dynamic) '_'  num2str(attribsStruct.Phase)...
        '_'  num2str(attribsStruct.BValue) '_'  num2str(attribsStruct.Grad_Orient)...
        '_'  char(attribsStruct.Label_Type) '_'  char(attribsStruct.Type)...
        '_'  char(attribsStruct.Sequence)...
        ];
    imageIndx.(keyString)= attribsStruct.Index;
end
imageDims = attribsStruct;
