
%% Create a structure from elements
function attribsStruct = buildStructureFromElements(elimList)
numAttributes = elimList.getLength;
attribsStruct = [];
for attribNum = 0:numAttributes-1
    elim = elimList.item(attribNum);
    attribsStruct = getAttribFromElim(elim,attribsStruct);
end
% %% Get attributes of the element in a structre
% function attribsStruct = getAttribFromElim(elim,attribsStruct)
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
% % Get values of the element
% elimNodeValue = getAttrValue(elim);
% elimValue = [];
% elimValue = convertStringToType(elimNodeValue, elimNodeType, elimNodeEnum);
% attribsStruct.(elimName) = elimValue;
% 
% %% Get value of the attribute
% function value = getAttrValue(attribNode)
% valueAttribNode = attribNode.getFirstChild;
% if(valueAttribNode.getNodeType == 3) 
%     value = valueAttribNode.getData;
% end
% %% Covert element value string to proper type
% function value = convertStringToType(elimNodeValue, elimNodeType, elimNodeEnum)
% switch char(elimNodeType)
%     case {'String', 'Date', 'Time', 'Boolean', 'Enumeration'}
%         value = char(elimNodeValue);
%     case 'Int16'
%         value = int16(str2num(elimNodeValue));
%     case 'Int32'
%         value = int32(str2num(elimNodeValue));
%     case 'Float'
%         value = single(str2num(elimNodeValue));
%     case 'Double'
%         value = double(str2num(elimNodeValue));
%     case 'UInt16'
%         value = uint16(str2num(elimNodeValue));
%     case 'UInt32'
%         value = uint32(str2num(elimNodeValue));
%     otherwise
%         value = char(elimNodeValue);
% end