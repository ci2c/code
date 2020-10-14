function [TP_faces FN_faces TP_words FN_words]= parse_xls_log_files_4IRMf(IOpath,encodingFilename,retrievalFilename,outputFile)
%function ok = parse_xls_log_files_4IRMf(IOpath,encodingFile,retrievalFile,outputFile)
% Analyse par expression regex des bonnes et mauvaises réponses d'un
% fichier Excel contenant les triggers
% Romain Viard @ CHR Lille, avr 2015


%%RUN 1 Visages

%pattern regex pour les visages
patternEncodingTimes = '(./images/[f m]_encoding_faces\W\S*)';
%container pour stocker les temps avec comme clé le chemin de l'image
encodingTimes = containers.Map('KeyType','char','ValueType','int32');
TP_faces_c = containers.Map('KeyType','char','ValueType','int32');
FN_faces_c = containers.Map('KeyType','char','ValueType','int32');

%lecture des fichiers
encodingFilename
IOpath
encodingFile = read_xls_file(encodingFilename,IOpath)
retrievalFile = read_xls_file(retrievalFilename,IOpath);

dimEncodingFile = size(encodingFile.run1.num,1);
for i=1:dimEncodingFile
    tok = regexpi(encodingFile.run1.txt{i,2},patternEncodingTimes,'tokens');
    if (size(tok,2)>0)
        encodingTimes(char(tok{1})) = encodingFile.run1.num(i,3);
    end
end

dimRetrievalFile = size(retrievalFile.run1.num,1);
for i=1:dimRetrievalFile
    tok = regexpi(retrievalFile.run1.txt{i,2},patternEncodingTimes,'tokens');
    if (size(tok,2)>0) && isKey(encodingTimes,char(tok{1}))
        if (retrievalFile.run1.num(i,5) == 1) 
            TP_faces_c(char(tok{1})) = cell2mat(values(encodingTimes,tok{1}));
         %attention faut-t-il prendre les non reponse comme une erreur ?
        elseif (retrievalFile.run1.num(i,5) == 2)
            FN_faces_c(char(tok{1})) = cell2mat(values(encodingTimes,tok{1}));
        end
    end
end

%Ecriture des resultats
TP_faces = cell2mat(values(TP_faces_c)');
fid = fopen(strcat(IOpath,'/faces_TruePositive_',outputFile,'.txt'), 'w');
fprintf(fid,'%g\n',double(TP_faces)/1000.);
fclose(fid);

FN_faces = cell2mat(values(FN_faces_c)');
fid = fopen(strcat(IOpath,'/faces_FalseNegative_',outputFile,'.txt'), 'w');
fprintf(fid,'%g\n',double(FN_faces)/1000.);
fclose(fid);


%%RUN 2 Mots

%Pattern regex pour les mots
patternEncodingTimes = '(./images/[f m]_encoding_words\W\S*)';
%container pour stocker les temps avec comme clé le chemin de l'image
clear encodingTimes; encodingTimes = containers.Map('KeyType','char','ValueType','int32');
TP_words_c = containers.Map('KeyType','char','ValueType','int32');
FN_words_c = containers.Map('KeyType','char','ValueType','int32');

dimEncodingFile = size(encodingFile.run2.num,1);
for i=1:dimEncodingFile
    tok = regexpi(encodingFile.run2.txt{i,2},patternEncodingTimes,'tokens');
    if (size(tok,2)>0)
        encodingTimes(char(tok{1})) = encodingFile.run2.num(i,3);
    end
end

dimRetrievalFile = size(retrievalFile.run2.num,1)

for i=1:dimRetrievalFile
    tok = regexpi(retrievalFile.run2.txt{i,2},patternEncodingTimes,'tokens');
    if (size(tok,2)>0) && isKey(encodingTimes,char(tok{1}))
        if (retrievalFile.run2.num(i,5) == 1) 
            TP_words_c(char(tok{1})) = cell2mat(values(encodingTimes,tok{1}));
%attention faut-t-il prendre les non reponses comme une erreur ?
        elseif (retrievalFile.run2.num(i,5) == 2)
            FN_words_c(char(tok{1})) = cell2mat(values(encodingTimes,tok{1}));
        end
    end
end

TP_words = cell2mat(values(TP_words_c)');
fid = fopen(strcat(IOpath,'/words_TruePositive_',outputFile,'.txt'), 'w');
fprintf(fid,'%g\n',double(TP_words)/1000.);
fclose(fid);

FN_words = cell2mat(values(FN_words_c)');
fid = fopen(strcat(IOpath,'/words_FalseNegative_',outputFile,'.txt'), 'w');
fprintf(fid,'%g\n',double(FN_words)/1000.);
fclose(fid);

    
