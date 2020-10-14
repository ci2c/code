%% Ensure XML file is a valid PRIDE series
function OK = isPRIDEseries(tree)
% Global PRIDE XML info
global PRIDE
% PRIDE_XML_HEADER PRIDE_XML_SERIES_HEADER PRIDE_XML_IMAGE_HEADER ...
%     PRIDE_XML_IMAGE_ARR_HEADER PRIDE_XML_IMAGE_ARR_HEADER PRIDE_XML_IMAGE_KEY_HEADER PRIDE_XML_ATTRIB_HEADER
% Sanity check
PRIDEheaderTag = tree.getElementsByTagName(PRIDE.XML_HEADER);
if ~(PRIDEheaderTag.getLength == 1) 
    error('ERROR - Unable to find PRIDE header - Aborting',filename);
end
% Get a list of all elements in the document
NodeList = tree.getElementsByTagName('*');
ElementsList = [];
for i=0:NodeList.getLength-1
    % Get individual element
    ElementsList{i+1} = char(NodeList.item(i).getNodeName());
end
% Check if tree elements are the same as PRIDE XML
CheckList = unique(ElementsList);
if ~(length(CheckList)==6 && ...
        strcmp(CheckList{1},PRIDE.XML_ATTRIB_HEADER) && ...
        strcmp(CheckList{2},PRIDE.XML_IMAGE_ARR_HEADER) && ...
        strcmp(CheckList{3},PRIDE.XML_IMAGE_HEADER) && ...
        strcmp(CheckList{4},PRIDE.XML_IMAGE_KEY_HEADER) && ...
        strcmp(CheckList{5},PRIDE.XML_HEADER) && ...
        strcmp(CheckList{6},PRIDE.XML_SERIES_HEADER) ...
        )
    error('XMLREC tree elements in file %s have changed.',filename);
else
    OK=1;
end
