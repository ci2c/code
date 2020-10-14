% Extract image info from the PRIDE series
function imageStruct = getXMLImageInfo(tree)
global PRIDE
PRIDEimageInfoNode = tree.getElementsByTagName(PRIDE.XML_IMAGE_HEADER);
PRIDEimageAttribList = PRIDEimageInfoNode.item(0).getElementsByTagName(PRIDE.XML_ATTRIB_HEADER);
imageStruct = buildStructureFromElements(PRIDEimageAttribList);
