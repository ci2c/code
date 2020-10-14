%% Update image information in XML
function outTree = addImageToXML(tree,imageStruct)
global PRIDE
% Check how many images exist
if (tree.getElementsByTagName(PRIDE.XML_IMAGE_KEY_HEADER).getLength<(imageStruct.Index+1))
    % Create new image node - copy first node
    oldNode = tree.getElementsByTagName(PRIDE.XML_IMAGE_HEADER);
    newNode = oldNode.item(0).cloneNode(true);
    parentNode = tree.getElementsByTagName(PRIDE.XML_IMAGE_ARR_HEADER);
    parentNode.item(0).appendChild(newNode);
else
    
end
PRIDEimageKeyInfoNode = tree.getElementsByTagName(PRIDE.XML_IMAGE_KEY_HEADER);
% Fill up existing image node
PRIDEimgKeyAttribList = PRIDEimageKeyInfoNode.item(imageStruct.Index).getElementsByTagName(PRIDE.XML_ATTRIB_HEADER);
% Fill up image key
tree = updateXMLwithElements(PRIDEimgKeyAttribList, tree, imageStruct);
% Fill up image info
PRIDEimageInfoNode = tree.getElementsByTagName(PRIDE.XML_IMAGE_HEADER);
PRIDEimgAttribList = PRIDEimageInfoNode.item(imageStruct.Index).getElementsByTagName(PRIDE.XML_ATTRIB_HEADER);
tree = updateXMLwithElements(PRIDEimgAttribList, tree, imageStruct);
outTree = tree;