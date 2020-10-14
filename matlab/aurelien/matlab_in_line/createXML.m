%% Create new XML using template and update series and image info
% first try series info
function outTree = createXML(seriesStruct)
global PRIDE
% Load template
tree = xmlread(PRIDE.XML_TEMPLATE);
% Sanity check
OK = isPRIDEseries(tree);
% Fill template with series information
PRIDEseriesInfoNode = tree.getElementsByTagName(PRIDE.XML_SERIES_HEADER);
PRIDEseriesAttribList = PRIDEseriesInfoNode.item(0).getElementsByTagName(PRIDE.XML_ATTRIB_HEADER);
tree = updateXMLwithElements(PRIDEseriesAttribList, tree, seriesStruct);
% Add images to the template

%% Return 
outTree=tree;
% %% Update XML with elements
% function tree = updateXMLwithElements(elimList, tree, seriesStruct)
% numAttributes = elimList.getLength;
% for attribNum = 0:numAttributes-1
%     elim = elimList.item(attribNum);
%     tree = setAttribFromElim(elim, tree, seriesStruct);
% end
% %% Get attributes of the element from a structre
% function tree = setAttribFromElim(elim, tree, seriesStruct)
% attribsList = elim.getAttributes();
% % Get name of the element
% elimName = char(getAttrValue(attribsList.getNamedItem('Name')));
% elimName(isspace(char(elimName)))='_';
% % Get type of the element
% elimNodeType = getAttrValue(attribsList.getNamedItem('Type'));
% % Get length of the attribute value array
% if isempty(attribsList.getNamedItem('ArraySize'))
%     elimNodeArrL = 1;
% else
%     elimNodeArrL = getAttrValue(attribsList.getNamedItem('ArraySize'));
% end
% % Get enumeration type of the element
% if isempty(attribsList.getNamedItem('EnumType'))
%     elimNodeEnum = '';
% else
%     elimNodeEnum = getAttrValue(attribsList.getNamedItem('EnumType'));
% end
% % Set values of the element
% % elimNodeValue = getAttrValue(elim);
% elimNodeValue = seriesStruct.(elimName);
% if elimNodeArrL==1
%     elimValue = convertTypeToString(elimNodeValue, elimNodeType, elimNodeEnum);
%     setAttrValue(tree, elim, elimValue);
% else
%     elimValue = convertTypeToString(elimNodeValue(1), elimNodeType, elimNodeEnum);
%     for i=2:length(elimNodeValue)
%         elimValue = [elimValue ' ' convertTypeToString(elimNodeValue(i), elimNodeType, elimNodeEnum)];
%     end
%     setAttrValue(tree, elim, elimValue);
% end
% %% Get value of the attribute
% function value = getAttrValue(attribNode)
% valueAttribNode = attribNode.getFirstChild;
% if(valueAttribNode.getNodeType == 3) 
%     value = valueAttribNode.getData;
% end
% %% Covert element type to proper PRIDE string
% function value = convertTypeToString(elimNodeValue, elimNodeType, elimNodeEnum)
% switch char(elimNodeType)
%     case {'String', 'Date', 'Time', 'Boolean', 'Enumeration'}
%         value = elimNodeValue;
% %     case 'Int16'
% %         value = int16(elimNodeValue);
%     case {'Int16', 'Int32', 'UInt16', 'UInt32'}
%         value = num2str(elimNodeValue);
%     case 'Float'
%         value = num2str(elimNodeValue,'%.4E');
%     case 'Double'
%         value = num2str(elimNodeValue,'%.8E');
% %     case 'UInt16'
% %         value = uint16(str2num(elimNodeValue));
% %     case 'UInt32'
% %         value = uint32(str2num(elimNodeValue));
%     otherwise
%         value = char(elimNodeValue);
% end
% %% Set value of the attribute
% function setAttrValue(tree, elim, elimValue)
% if (elim.hasChildNodes )
%     valueAttribNode = elim.getFirstChild;
%     valueAttribNode.setData(elimValue);
% else
%     elim.appendChild(tree.createTextNode(elimValue));
% end