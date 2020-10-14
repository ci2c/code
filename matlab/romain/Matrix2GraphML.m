function [ result ] = Matrix2GraphML( adjMatrix, filePath )
%Matrix2GraphML Conversion d'une matrice d'adjacence en fichier GraphML
%   Le graphe est de type dirigé
%   Les id des noeuds suivent la syntaxe 'n<numéro_ligne>'
%   Les id des arrêtes suivent la syntaxe 'e<numéro_ligne_source><numéro_colonne_destination>
%   Les poids d'adjacence sont reportés dans la clé 'd1' des arrêtes
%   adjMatrix   : matrice d'adjacence
%   filePath    : nom du fichier résultant (p.e. 'out_file.graphml')
%   result      : [nodeCount, edgeCount]

% TODO : réduire les noeuds répertoriés à ceux effectivement connectés.
% TODO : prise en charge ou non de l'insertion d'une métadonnée d'arrête

% Verbes et syntaxe XML & GraphML ...
gmlXMLBracketOpen   = '<';
gmlXMLBracketClose  = '>';
gmlXMLNodeEnd       = '/';

gmlCR               = '\r\n';
gmlTab              = '\t';
gmlSpace            = '\040';

gmlMsg01          = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>';
gmlMsg02          = '<!--Created by MATLAB::Matrix2GraphML-->';

gmlVerbGraphML      = 'graphml';
gmlVerbSchema       = 'xmlns="http://graphml.graphdrawing.org/xmlns" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns"';
gmlVerbGraph        = 'graph';
gmlVerbGraphType    = 'edgedefault="directed" id="G"';
gmlVerbNode         = 'node'; % p.e. : '<node id="n0">'
gmlVerbId           = 'id';
gmlVerbEdge         = 'edge';
gmlVerbSource       = 'source';
gmlVerbTarget       = 'target';
gmlVerbData         = 'data';
gmlVerbKey          = 'key';

strGraphMLStart = strcat(gmlXMLBracketOpen, gmlVerbGraphML, gmlSpace, gmlVerbSchema, gmlXMLBracketClose, gmlCR);
strGraphMLEnd = strcat(gmlXMLBracketOpen, gmlXMLNodeEnd, gmlVerbGraphML, gmlXMLBracketClose, gmlCR);

strGraphStart = strcat(gmlTab, gmlXMLBracketOpen, gmlVerbGraph, gmlSpace, gmlVerbGraphType, gmlXMLBracketClose, gmlCR);
strGraphEnd = strcat(gmlTab, gmlXMLBracketOpen, gmlXMLNodeEnd, gmlVerbGraph, gmlXMLBracketClose, gmlCR);

strDefKeyWeigth = strcat(gmlTab, gmlXMLBracketOpen, gmlVerbKey, gmlSpace, 'attr.name="edge_weigth" attr.type="string" for="edge" id="d1"', gmlXMLNodeEnd, gmlXMLBracketClose, gmlCR);

strFormatNode = strcat(gmlTab, gmlTab, gmlXMLBracketOpen, gmlVerbNode, gmlSpace, gmlVerbId, '=', '"', 'n%d', '"', gmlXMLNodeEnd, gmlXMLBracketClose, gmlCR);
% strFormatEdgeSingle = strcat(gmlTab, gmlTab, gmlXMLBracketOpen,
% gmlVerbEdge, gmlSpace, gmlVerbId, '=', '"', 'e%d%d', '"', gmlSpace,
% gmlVerbSource, '=', '"', 'n%d', '"', gmlSpace, gmlVerbTarget, '=', '"',
% 'n%d', '"', gmlXMLNodeEnd, gmlXMLBracketClose, gmlCR); ... cf. TODO
strFormatEdgeStart = strcat(gmlTab, gmlTab, gmlXMLBracketOpen, gmlVerbEdge, gmlSpace, gmlVerbId, '=', '"', 'e%d%d', '"', gmlSpace, gmlVerbSource, '=', '"', 'n%d', '"', gmlSpace, gmlVerbTarget, '=', '"', 'n%d', '"', gmlXMLBracketClose, gmlCR);
strEdgeEnd = strcat(gmlTab, gmlTab, gmlXMLBracketOpen, gmlXMLNodeEnd, gmlVerbEdge, gmlXMLBracketClose, gmlCR);
strFormatData = strcat(gmlTab, gmlTab, gmlTab, gmlXMLBracketOpen, gmlVerbData, gmlSpace, gmlVerbKey, '=', '"', '%s', '"', gmlXMLBracketClose, '%d', gmlXMLBracketOpen, gmlXMLNodeEnd, gmlVerbData, gmlXMLBracketClose, gmlCR);

% Test de matrice carrée ...
if (size(adjMatrix,1) ~= size(adjMatrix,2))
    error('Matrix2GraphML:argCheck', 'adjMatrix is not a square matrix !')
end

% Initialisation ...
edgeCount = 0;
nodeCount = 0;
matSize = size(adjMatrix, 1);

% Création du fichier ...
fid = fopen(filePath, 'w');

% Ecriture des en-têtes ...
fprintf(fid, strcat(gmlMsg01, gmlCR));
fprintf(fid, strcat(gmlMsg02, gmlCR));
fprintf(fid, strGraphMLStart);
fprintf(fid, strDefKeyWeigth); % ... cf. TODO
fprintf(fid, strGraphStart);

% Parcours des noeuds ...
for i = 1 : matSize
    gmlNode = sprintf(strFormatNode, i);
    fprintf(fid, gmlNode);
    nodeCount = nodeCount + 1;
end

% Parcours des arrêtes ...
for i = 1 : matSize
    for j = 1 : matSize
        if (adjMatrix(i,j) ~= 0)
            %gmlEdge = sprintf(strFormatEdge, i, j, i, j); ... cf. TODO.
            gmlEdge = sprintf(strFormatEdgeStart, i, j, i, j);
            gmlWeigth = sprintf(strFormatData, 'd1', adjMatrix(i,j));
            fprintf(fid, gmlEdge);
            fprintf(fid, gmlWeigth);
            fprintf(fid, strEdgeEnd);
            edgeCount = edgeCount + 1;
        end
    end
end

% Ecriture des terminaisons ...
fprintf(fid, strGraphEnd);
fprintf(fid, strGraphMLEnd);

% Fermeture du fichier ...
fclose(fid);

% Retour ...
result = [nodeCount edgeCount];
end