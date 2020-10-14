% Extract data dimensions in the PRIDE series
function [seriesStruct, seriesDims] = getXMLSeriesInfo(tree)
global PRIDE
PRIDEseriesInfoNode = tree.getElementsByTagName(PRIDE.XML_SERIES_HEADER);
PRIDEseriesAttribList = PRIDEseriesInfoNode.item(0).getElementsByTagName(PRIDE.XML_ATTRIB_HEADER);
seriesStruct = buildStructureFromElements(PRIDEseriesAttribList);
% Compile series dimensions
seriesDims.Max_No_Phases             = seriesStruct.Max_No_Phases;
seriesDims.Max_No_Echoes           = seriesStruct.Max_No_Echoes;
seriesDims.Max_No_Slices           = seriesStruct.Max_No_Slices;
seriesDims.Max_No_Dynamics         = seriesStruct.Max_No_Dynamics;
seriesDims.Max_No_Mixes            = seriesStruct.Max_No_Mixes;
seriesDims.Max_No_B_Values         = seriesStruct.Max_No_B_Values;
seriesDims.Max_No_Gradient_Orients = seriesStruct.Max_No_Gradient_Orients;
seriesDims.No_Label_Types          = seriesStruct.No_Label_Types;

