%=========================================================================
%
%	SOURCE:		RECON.M
%	COMPONENT:	REC
%	SOLUTION:	RECFRAME
%
%	DESCRIPTION:
%	    Module to convert k-space or x-k-space data (*.ksp) to
%       image-space data *.rec
%
%	INPUT:
%		------------------------------------------------------------------
%		recon.par - Parameter file
%		------------------------------------------------------------------
%       Acquisition (acq) matrix parameters
%		acq_mode:        0              ( 0 = Cartesian             )
%                                       ( 1 = Radial                )
%                                       ( 2 = Spiral                )
%                                       ( 3 = Spectro               )
%       acq_ovs:         2.0 x 1.0 x 1.0( ov0 x ov1 x ov2 x ov3     )
%		acq_matrix:      192 x 160 x 30 ( ne0 x ne1 x ne2 x ne3     )
%       acq_immed_avg :  0				( 1 = immediate averaging 	)
%
%       Reconstruction (rec) matrix parameters
%		rec_matrix:      256 x 256 x 24 ( ne0 x ne1 x ne2 (imaging) )
%                        256 x 256 x 24 ( ne1 x ne2 x ne3 (spectro) )
%		rec_pixel_depth: 12             ( bit                       )
%		rec_img_ori:	 0              ( 0 = don't rotate in-plane )
%                                       ( 1 = 90 deg clockwise      )
%                                       (-1 = 90 deg anticlockwise  )
%       rec_img_shift:   0  x   0  x  0 ( offcentre shift (EPI only))
%
%       Scan info (inf) parameters
%       inf_field_strength:				( field strength in [T]     )
%       inf_flip_angle:					( flip angle in [deg]		)
%       inf_rep_time:					( repetition time in [ms]	)
%       inf_inv_tine:					( inversion time in [ms]	)
%       inf_pp_delay:					( prepulse delay in [ms]	)

%       User-defined (proto) parameters
%       proto_flt_array: 0.0 0.0 0.0... ( proto parameters from UI  )
%       proto_flt_array: 0.0 0.0 0.0... ( proto parameters from UI  )
%
%       Note:
%       * Cartesian data are already Fourier transformed along e0
%       * Spiral, Radial and Spectro data are NOT Fourier transformed
%       * if acq_matrix < rec_matrix recon data must be interpolated
%         to rec_matrix
%       * if rec_matrix > acq_matrix data must be cropped
%         to rec_matrix
%       ==================================================================
%
%		------------------------------------------------------------------
%		recon.ksp - K-space data file
%		------------------------------------------------------------------
%		a) header   - 10x short	integer (2 bytes)
%
%		# ne0	    - number samples along e0
%		# ne1	    - number samples along e1
%		# ne2	    - number samples along e2
%		# ne3	    - number samples along e3
%		# ncoils    - number coils
%		# navg      - number averages
%	    # nrows	    - number rows (e.g. segments in qflow)
%		# nechoes   - number echoes
%		# nlocs	    - number locations (e.g. slices)
%		# ncards    - number cardiac phases
%		# ndyns	    - number dynamic scans
%
%		Note:
%       * imaging: e0,e1,e2 denote readout and phase-encode dims
%       * spectro: e0 correspond to time; e1,e2,e3 to phase-encode dims
%       * multi-coil data, i.e. synergy + qbody data
%         are saved into one file with #ncoils = #syn channels + 1
%       * if number mixes > 1 each mix will be saved
%		  into a separate file: recon-m0.ksp
%
%		------------------------------------------------------------------
%		b) data	    - ne0*ne1*... x single prec float (4 bytes)
%
%		# order	    - |re|im|re|im|... etc.
%       ==================================================================
%
%		------------------------------------------------------------------
%		recon.epi -  K-space data file for EPI phase correction
%		------------------------------------------------------------------
%		a) header   - 10x short	integer (2 bytes)
%
%		# ne0	    - number samples along e0
%		# ne1	    - number samples along e1
%		# ne2	    - number samples along e2
%		# ne3	    - number samples along e3
%		# nphx	    - number epi phase correction data sets (dual epi corr)
%		# ncoils    - number coils
%	    # nrows	    - number rows (e.g. segments in qflow)
%		# nechoes   - number echoes
%		# nlocs	    - number locations (e.g. slices)
%		# ncards    - number cardiac phases
%
%		Note:
%       * imaging: e0,e1,e2 denote readout and phase-encode dims
%       * multi-coil data, i.e. synergy + qbody data
%         are saved into one file with #ncoils = #syn channels + 1
%       * if number mixes > 1 each mix will be saved
%		  into a separate file: recon-m0.epi
%
%		------------------------------------------------------------------
%		b) data	    - ne0*ne1*... x single prec float (4 bytes)
%
%		# order	    - |re|im|re|im|... etc.
%       ==================================================================
%
%       ------------------------------------------------------------------
%		recon.cov - Coil noise covariance matrix for noise decorrelation
%		------------------------------------------------------------------
%		a) header   - 1x short	integer (2 bytes)
%
%		# ncoils    - number coils
%
%		------------------------------------------------------------------
%		b) data	    - ncoils*ncoils x single prec float (4 bytes)
%
%		# order	    - |re|im|re|im|... etc.
%       ==================================================================
%
%	OUTPUT:
%       recon.rec - Image-space data (short integer)
%
%	VERSION HISTORY:
%	    20060215SK	Beta version
%       20060216SK  Noise decorrelation added
%       20060227SK  QFlow reconstruction added
%       20060301SK  Grid engine added
%	    20060819SK	Immediate averaging on/off
%       20080103MB  Improved radial and spiral recons
%
%=========================================================================

%=========================================================================
%	M A I N  F U N C T I O N
%=========================================================================
function [] = Recon()

% --------------------------------------------------------------------
% General defines
% --------------------------------------------------------------------
ACQ_CARTESIAN       = 0;
ACQ_RADIAL          = 1;
ACQ_SPIRAL          = 2;
ACQ_SPECTRO         = 3;

% --------------------------------------------------------------------
% Noise data flag
% --------------------------------------------------------------------
NOI_COV_DATA        = 0;

% --------------------------------------------------------------------
% EPI phase correction data flags
% --------------------------------------------------------------------
EPI_PHX_DATA        = 0;
EPI_DUAL_SET        = 1;
% Note: two data vectors for EPI phase correction are acquired for
% every profile with a relative shift of one readout lobe to permit
% correction for B0 eddy current effects
EPI_DISPLAY         = 1;

% --------------------------------------------------------------------
% Radial, Spiral weigths calculation flag
% --------------------------------------------------------------------
weight              = -1;

% --------------------------------------------------------------------
% Display title
% --------------------------------------------------------------------
fprintf ( '-------------------------------------\n' );
fprintf ( '    ReconFrame v2.0 (C)GyroTools     \n' );
fprintf ( '-------------------------------------\n' );

% --------------------------------------------------------------------
% Check available files
% --------------------------------------------------------------------
DirList = dir;
hdx     = 2;
kdx     = 1;
edx     = 1;

for h=1:hdx
    kdx = 1;
    for i=1:length(DirList)
        if ~isempty(strfind(DirList(i).name,'.par'))
            ParFileName = DirList(i).name;
        end
        if ~isempty(strfind(DirList(i).name,'.ksp'))
            KspFileName(kdx,:) = DirList(i).name;
            kdx = kdx + 1;
        end
        if ~isempty(strfind(DirList(i).name,'.epi'))
            EpiFileName = DirList(i).name;
            EPI_PHX_DATA = 1;
            edx = edx + 1;
        end
        if ~isempty(strfind(DirList(i).name,'.cov'))
            NOI_COV_DATA = 1;
            CovFileName = DirList(i).name;
        end
    end
    if (kdx==1)
        system('recframe.exe');
        DirList      = dir;
    else continue; end
end

clear hdx kdx edx;

% --------------------------------------------------------------------
% Read parameters from file
% --------------------------------------------------------------------
par = ReadParameters(ParFileName);

% --------------------------------------------------------------------
% Read noise covariance data
% --------------------------------------------------------------------
if (NOI_COV_DATA)
    cov = ReadCovData(CovFileName);
end

% --------------------------------------------------------------------
% Read profile information
% --------------------------------------------------------------------
num_format = '%*4c%d %*4c%d %*5c%d %*4c%d %*5c%d %*4c%d %*5c%d %*5c%d %*3c%d %*3c%d %*3c%d %*5c%d %*6c%d ';
labels = {'mix', 'dyn', 'card', 'loc', 'extr', 'row', 'echo', 'meas', 'e3', 'e2', 'e1', 'rtop', 'rrint'};
prof = struct;
pid = fopen('recon.prof');
if (pid ~= -1)
    prof_temp = fscanf(pid,'%c',inf);
    prof_temp = sscanf(prof_temp,num_format,[13,inf]);
    for i = 1:size(prof_temp,1)
        prof = setfield(prof, labels{i}, prof_temp(i,:));
    end
    fclose(pid);
end

% --------------------------------------------------------------------
% Open rec file for writing
% --------------------------------------------------------------------
rid = fopen('recon.rec','w');

% --------------------------------------------------------------------
% Loop over mixes (1 mix only for now)
% --------------------------------------------------------------------
for mix = 1:size(KspFileName,1);

    % ----------------------------------------------------------------
    % Open ksp file and read header
    % ----------------------------------------------------------------
    [par,kid] = OpenKspFileAndReadHeader(KspFileName(mix,:),par);

    % ----------------------------------------------------------------
    % Open epi file and read header (EPI only)
    % ----------------------------------------------------------------
    if (EPI_PHX_DATA)
        [par,eid] = OpenEpiFileAndReadHeader(EpiFileName(mix,:),par);
    end

    % ----------------------------------------------------------------
    % Progress counter
    % ----------------------------------------------------------------
    progress = 1;
    total    = par.acq_ndyns*par.acq_ncards*par.acq_nlocs*par.acq_nechoes*par.rec_matrix(3);
    histo    = zeros(2^par.rec_pixel_depth,total,'uint32');

    % ----------------------------------------------------------------
    % Loop over dynamics
    % ----------------------------------------------------------------
    for dyn = 1:par.acq_ndyns
        % ------------------------------------------------------------
        % Loop over phases
        % ------------------------------------------------------------
        for card = 1:par.acq_ncards
            % --------------------------------------------------------
            % Loop over locations
            % --------------------------------------------------------
            for loc = 1:par.acq_nlocs
                % ----------------------------------------------------
                % Loop over echoes
                % ----------------------------------------------------
                for echo = 1:par.acq_nechoes

                    % ------------------------------------------------
                    % Status line
                    % ------------------------------------------------
                    str = sprintf('Processing data for mix:%2d dyn:%2d card:%2d loc:%2d echo:%2d...',mix,dyn,card,loc,echo);
                    fprintf(str);

                    % ------------------------------------------------
                    % Loop over rows; two rows only (phase-contrast)
                    % ------------------------------------------------
                    for row = 1:min(par.acq_nrows,2)

                        % --------------------------------------------
                        % Loop over averages
                        % --------------------------------------------
                        for avg = 1:par.acq_navg

                            % ----------------------------------------
                            % Read measurement data
                            % ----------------------------------------
                            data = ReadKspData(kid,par);

                            % ----------------------------------------
                            % Read and calculate epi phase correction
                            % (1st dynamic and 1st cardiac phases only)
                            % ----------------------------------------
                            if (EPI_PHX_DATA)
                                if ((dyn==1)&&(card==1))
                                    epi1 = ReadEpiData(eid,par);
                                    if (EPI_DUAL_SET) epi2 = ReadEpiData(eid,par); end
                                    phx = CalcEpiCorrection(epi1,epi2,par,EPI_DISPLAY);
                                    clear epi1 epi2;
                                end
                                data = ApplyEpiCorrection(data,phx,par);
                            end

                            % ----------------------------------------
                            % Update acq matrix from actual data;
                            % oversampling along ne0 may have been removed;
                            % keep copy of acq_matrix(1) (rq. for spiral)
                            % ----------------------------------------
                            acq_matrix = par.acq_matrix(1);
                            par.acq_matrix = [par.acq_ne0,par.acq_ne1,par.acq_ne2,par.acq_ne3];

                            % ----------------------------------------
                            % Noise decorrelation
                            % ----------------------------------------
                            %                                 if (NOI_COV_DATA)
                            %                                    data = ApplyCovData(data,cov,par);
                            %                                 end

                            % ----------------------------------------
                            % Overcontiguous 3D
                            % ----------------------------------------
                            if (par.acq_matrix(3)>1)
                                if (round(par.acq_matrix(3)/par.acq_ovs(3))<par.rec_matrix(3))
                                    tmp = complex(zeros([par.acq_matrix(1) par.acq_matrix(2) 2*par.acq_matrix(3) par.acq_ncoils],'single'));
                                    tmp(:,:,bitshift(par.acq_matrix(3),-1)+1:bitshift(par.acq_matrix(3),-1)+par.acq_matrix(3),:) = data;
                                    par.acq_matrix(3) = 2*par.acq_matrix(3);
                                    data = tmp; clear tmp;
                                end
                            end

                            % ----------------------------------------
                            % Switch for acq modes
                            % ----------------------------------------
                            switch par.acq_mode
                                % ------------------------------------
                                % Process Cartesian data
                                % ------------------------------------
                                case ACQ_CARTESIAN
                                    %---------------------------------
                                    % Fourier-transform ne1 and ne2
                                    %---------------------------------
                                    data = k2i(data,[2 3]);
                                    if (~EPI_PHX_DATA)
                                        data = circshift(data,[0 bitshift(size(data,2),-1) bitshift(size(data,3),-1) 0]);
                                    end
                                    data = flipdim(data,3);
                                    % --------------------------------
                                    % Remove oversampling along ne1
                                    %---------------------------------
                                    par.acq_matrix(2) = par.acq_ne1;
                                    tmp = round(par.acq_ne1/par.acq_ovs(2));
                                    data = data(:,bitshift(par.acq_matrix(2)-tmp,-1)+1:...
                                        bitshift(par.acq_matrix(2)-tmp,-1)+tmp,:,:,:);
                                    par.acq_matrix(2) = tmp; clear tmp;

                                    % ------------------------------------
                                    % Process Radial data
                                    % ------------------------------------
                                case ACQ_RADIAL
                                    % --------------------------------
                                    % Fourier transform ne2
                                    %---------------------------------
                                    data = circshift(k2i(data,3),[0 0 bitshift(size(data,3),-1)+1 0 0]);

                                    % --------------------------------
                                    % Reconstruct in-plane
                                    %---------------------------------
                                    [data,par] = ReconRadialData(data,par,weight);

                                    % ------------------------------------
                                    % Process Spiral data
                                    % ------------------------------------
                                case ACQ_SPIRAL
                                    % --------------------------------
                                    % Fourier transform ne2
                                    %---------------------------------
                                    data = circshift(k2i(data,3),[0 0 bitshift(size(data,3),-1)+1 0]);

                                    % --------------------------------
                                    % Reconstruct in-plane
                                    %---------------------------------
                                    [data,par,weight] = ReconSpiralData(data,par,acq_matrix,weight);

                                    % ------------------------------------
                                    % Process Spectro data
                                    % ------------------------------------
                                case ACQ_SPECTRO
                                    % --------------------------------
                                    % to be implemented
                                    % --------------------------------

                                otherwise
                                    error('acq mode not supported');
                            end
                            if (par.acq_navg>1)
                                if (avg==1) store = data; end
                                if (avg> 1) store = store+data; end
                            end
                        end
                        if (par.acq_nrows>1) store(:,:,:,:,:,row) = data; end
                    end
                    if (par.acq_navg>1)||(par.acq_nrows>1) data = store; clear store; end

                    % ------------------------------------------------
                    % Image production
                    % ------------------------------------------------
                    for slice=bitshift(par.acq_matrix(3)-par.rec_matrix(3),-1)+1:...
                            bitshift(par.acq_matrix(3)-par.rec_matrix(3),-1)+par.rec_matrix(3)

                        %---------------------------------------------
                        % Zero-fill
                        %---------------------------------------------
                        img = ZeroFill(data,par,slice+(par.acq_matrix(3)>1));

                        %---------------------------------------------
                        % Combine coils (standard and phase-contrast)
                        %---------------------------------------------
%                         img = CombineCoils(img,par);

                        %=============================================
                        % R&D Course (begin)
                        %=============================================
                        % Combine coils using a virtual body-coil
                        %---------------------------------------------
                        [img,sensitivity]   = CombineCoilsUsingVirtualBodyCoil(img(:,:,1:end));
                        [img_water,img_fat] = WaterFatSeparation(img);
                        img_size            = size(img);
                        img                 = cat(1,cat(2,mat2gray(angle(img)),mat2gray(abs(img))),cat(2,mat2gray(img_water),mat2gray(img_fat)));
                        img                 = imresize(img,img_size,'bicubic');

                        %=============================================
                        % R&D Course (end)
                        %=============================================

                        %---------------------------------------------
                        % Scale image to pixel_depth
                        %---------------------------------------------
                        [img,histo] = ScaleImage(img,par,histo,progress);

                        %---------------------------------------------
                        % Shift image (in-plane offcentres EPI+Spiral)
                        %---------------------------------------------
                        img = ShiftImage(img,par);

                        %---------------------------------------------
                        % Make image cols and rows equal (rFOV)
                        %---------------------------------------------
                        img = SquareImage(img,par);

                        %---------------------------------------------
                        % Rotate image in-plane
                        %---------------------------------------------
                        img = RotateImage(img,par);

                        % --------------------------------------------
                        % Autoview
                        %---------------------------------------------
                        AutoView(single(real(img)),histo,progress,total);
                        progress = progress+1;

                        % --------------------------------------------
                        % Save to .rec file
                        %---------------------------------------------
                        if (par.rec_pixel_depth==8)
                            precision = 'uint8';
                        else
                            precision = 'uint16';
                        end
                        fwrite(rid,real(img),precision);
                        if (par.acq_nrows>1)
                            fwrite(rid,imag(img),precision);
                        end
                        clear img precision;
                    end
                    % ------------------------------------------------
                    % Update status line
                    % ------------------------------------------------
                    for i = 1:length(str) fprintf('\b'); end;
                end
            end
        end
    end
    fprintf('Processed data for mix:%2d dyn:%2d card:%2d loc:%2d echo:%2d...\n', mix,dyn,card,loc,echo);
end

% --------------------------------------------------------------------
% Close open files
% --------------------------------------------------------------------
fclose('all');

% --------------------------------------------------------------------
% Determine default display window width / centre and write .sql file
% --------------------------------------------------------------------
for i=1:progress-1
    index  = find(histo(:,i)>mean(histo(:,i)));
    width(i)  = max(index)-min(index);
    center(i) = bitshift(width(i),-1)+min(index);
end
sid = fopen('recon.sql','w');
offset = 0;
fprintf(sid,'use patientdb\ngo\n');
for i=1:progress-1
    fprintf(sid,'UPDATE image SET window_width = %4d, window_center = %4d WHERE series_OID = %s AND image_bulk_offset = %d\ngo\n',max(width),max(center),par.series_oid,offset);
    if (par.rec_pixel_depth==8)
        offset = offset+par.rec_matrix(1)*par.rec_matrix(1)*min(par.acq_nrows,2);
    else
        offset = offset+par.rec_matrix(1)*par.rec_matrix(1)*2*min(par.acq_nrows,2);
    end
end
fclose(sid);

% --------------------------------------------------------------------
% Close Autoview and clear all variables
% --------------------------------------------------------------------
fprintf('\n');
close all;
clear all;
end

%=========================================================================
%	L O C A L  F U N C T I O N S
%=========================================================================
function par = ReadParameters( ParFileName )

% --------------------------------------------------------------------
%   Set default values
par.acq_mode            = 0;                % Cartesian imaging
par.acq_ovs( 1 )        = 2.;               % Oversampling along e0
par.acq_ovs( 2 )        = 1.;               % Oversampling along e1
par.acq_ovs( 3 )        = 1.;               % Oversampling along e2
par.acq_ovs( 4 )        = 1.;               % Oversampling along e3
par.acq_matrix( 1 )     = 128;              % Acquisition matrix e0
par.acq_matrix( 2 )     = 128;              % Acquisition matrix e1
par.acq_matrix( 3 )     = 1;                % Acquisition matrix e2
par.acq_matrix( 4 )     = 1;                % Acquisition matrix e3
par.rec_matrix( 1 )     = 256;              % Recon matrix e0
par.rec_matrix( 2 )     = 256;              % Recon matrix e1
par.rec_matrix( 3 )     = 1;                % Recon matrix e2
par.rec_pixel_depth     = 2;                % Two bytes
par.rec_img_ori         = 0;                % Do not rotate image
par.rec_img_shift( 1 )  = 0;                % Do not shift image along e0
par.rec_img_shift( 2 )  = 0;                % Do not shift image along e1
par.rec_img_shift( 3 )  = 0;                % Do not shift image along e2
par.inf_field_strength  = 0.0;				% Field strength in [T]
par.inf_flip_angle      = 0.0;				% Flip angle in [deg]
par.inf_rep_time        = 0.0;              % Repetition time in [ms]
par.inf_inv_time        = 0.0;              % Inversion time in [ms]
par.inf_pp_delay        = 0.0;              % Prepulse delay in [ms]
par.series_oid          = '';               % Image oid for window / level update

% --------------------------------------------------------------------
%   Open parameter file
fid = fopen( ParFileName );

if ( fid ~= -1 )
    while ( ~feof( fid ) )
        str = fscanf( fid, '%s', 1 );

        if     strcmp( str, 'acq_mode:'             ) par.acq_mode          = fscanf( fid, '%d', 1 );
        elseif strcmp( str, 'acq_ovs:'              ) par.acq_ovs(1:4)      = fscanf( fid, '%f', 4 );
        elseif strcmp( str, 'acq_matrix:'           ) par.acq_matrix(1:4)   = fscanf( fid, '%d', 4 );
        elseif strcmp( str, 'rec_matrix:'           ) par.rec_matrix(1:3)   = fscanf( fid, '%d', 3 );
        elseif strcmp( str, 'rec_pixel_depth:'      ) par.rec_pixel_depth   = fscanf( fid, '%d', 1 );
        elseif strcmp( str, 'rec_img_ori:'          ) par.rec_img_ori       = fscanf( fid, '%d', 1 );
        elseif strcmp( str, 'rec_img_shift:'        ) par.rec_img_shift(1:3)= fscanf( fid, '%d', 3 );
        elseif strcmp( str, 'inf_field_strength:'   ) par.inf_field_strength= fscanf( fid, '%f', 1 );
        elseif strcmp( str, 'inf_flip_angle:'       ) par.inf_flip_angle    = fscanf( fid, '%f', 1 );
        elseif strcmp( str, 'inf_rep_time:'         ) par.inf_rep_time      = fscanf( fid, '%f', 1 );
        elseif strcmp( str, 'inf_inv_time:'         ) par.inf_inv_time      = fscanf( fid, '%f', 1 );
        elseif strcmp( str, 'inf_pp_delay:'         ) par.inf_pp_delay      = fscanf( fid, '%f', 1 );
        elseif strcmp( str, 'series_oid:'           ) par.series_oid        = fscanf( fid, '%s', 1 ); end
    end
    fclose( fid );

    fprintf( '\nScan information:\n' );
    fprintf( '  field strength    :%6.1f\n', par.inf_field_strength );
    fprintf( '  flip angle        :%6.1f\n', par.inf_flip_angle     );
    fprintf( '  repetition time   :%6.1f\n', par.inf_rep_time       );
    fprintf( '  inversion time    :%6.1f\n', par.inf_inv_time       );
    fprintf( '  prepulse delay    :%6.1f\n', par.inf_pp_delay       );
else
    fprintf( 'recon: *.par file cannot be read\n');
end
end

%=========================================================================
function [par,fid] = OpenKspFileAndReadHeader(KspFileName,par)

fid = fopen(KspFileName);
if (fid~=-1)
    hdr = fread( fid, 11, 'uint16' );
    par.acq_ne0      = hdr( 1 );    % x/kx (ima) t (spy)
    par.acq_ne1      = hdr( 2 );    % ky (ima)  kx (spy)
    par.acq_ne2      = hdr( 3 );    % kz (ima)  ky (spy)
    par.acq_ne3      = hdr( 4 );    %           kz (spy)
    par.acq_ncoils   = hdr( 5 );    % coils
    par.acq_navg     = hdr( 6 );    % averages
    par.acq_nechoes  = hdr( 7 );    % echoes
    par.acq_nrows    = hdr( 8 );    % rows (e.g. qflow segments)
    par.acq_nlocs    = hdr( 9 );    % locations
    par.acq_ncards   = hdr(10 );    % cardiac phases
    par.acq_ndyns    = hdr(11 );    % dynamic scans

    fprintf( '\nFile header information:\n' );
    fprintf( '  dynamic scans     :%4d\n', par.acq_ndyns    );
    fprintf( '  cardiac phases    :%4d\n', par.acq_ncards   );
    fprintf( '  locations         :%4d\n', par.acq_nlocs    );
    fprintf( '  rows              :%4d\n', par.acq_nrows    );
    fprintf( '  echoes            :%4d\n', par.acq_nechoes  );
    fprintf( '  averages          :%4d\n', par.acq_navg     );
    fprintf( '  coils             :%4d\n', par.acq_ncoils   );
    fprintf( '  encode e3         :%4d\n', par.acq_ne3      );
    fprintf( '  encode e2         :%4d\n', par.acq_ne2      );
    fprintf( '  encode e1         :%4d\n', par.acq_ne1      );
    fprintf( '  encode e0         :%4d\n', par.acq_ne0      );
    fprintf( '  \n' );
else
    fprintf( 'recon: *.ksp file cannot be read\n');
end
end

%=========================================================================
function ksp = ReadKspData(fid,par)

if (fid~=-1)
    ksp = single(fread(fid,par.acq_ne0*par.acq_ne1*par.acq_ne2*par.acq_ne3*par.acq_ncoils*2,'single'));
    ksp = complex(ksp(1:2:end),ksp(2:2:end));
    ksp = reshape(ksp,par.acq_ne0,par.acq_ne1,par.acq_ne2,par.acq_ne3,par.acq_ncoils);
end
end

%=========================================================================
function [par,fid] = OpenEpiFileAndReadHeader(EpiFileName,par)

fid = fopen(EpiFileName);
if (fid~=-1)
    hdr = fread( fid, 10, 'uint16' );
    par.epi_ne0      = hdr( 1 );    % x
    par.epi_ne1      = hdr( 2 );    % ky
    par.epi_ne2      = hdr( 3 );    % kz
    par.epi_ne3      = hdr( 4 );    % not used
    par.epi_ncoils   = hdr( 5 );    % coils
    par.epi_nphx     = hdr( 6 );    % phx sets
    par.epi_nechoes  = hdr( 7 );    % echoes
    par.epi_nrows    = hdr( 8 );    % rows
    par.epi_nlocs    = hdr( 9 );    % locations
    par.epi_ncards   = hdr(10 );    % cardiac phases
end
end

%=========================================================================
function epi = ReadEpiData(fid,par)

if (fid~=-1)
    epi = single(fread(fid,par.epi_ne0*par.epi_ne1*par.epi_ne2*par.epi_ncoils*2,'single'));
    epi = complex(epi(1:2:end),epi(2:2:end));
    epi = reshape(epi,par.epi_ne0,par.epi_ne1,par.epi_ne2,par.epi_ncoils);
else
    epi = 0;
end
end

%=========================================================================
function phx = CalcEpiCorrection(epi1,epi2,par,display)

% Display EPI phx raw k-space data
if display
    figure(2);
    subplot(2,1,1);
    plot(sum(abs(i2k(epi2(:,1:end-1,:,:),1)),4));
    title('EPI phx sample data');
end

% Calculate simple EPI phx correction vector
phx = single(ones(par.epi_ne0,par.epi_ne1-1,par.epi_ne2));
for ky=1:par.epi_ne1-1
    phx(:,ky) = angle(mean(epi2(:,1,:,:)./epi2(:,ky,:,:),4));
end
phx = complex(cos(phx),sin(phx));

% Display EPI phx correction k-space data for all coils
for c=1:par.epi_ncoils
    for ky=1:par.epi_ne1-1
        tmp(:,ky,1,c) = epi2(:,ky,c).*phx(:,ky);
    end
end

if display
    subplot(2,1,2);
    plot(sum(abs(i2k(tmp,1)),4));
    title('EPI phx correct data');
end
clear tmp;
end

%=========================================================================
function data = ApplyEpiCorrection(data,phx,par)

epi_factor = size(phx,2);
nr_shots   = par.acq_ne1/epi_factor;
for c=1:par.acq_ncoils
    for kz=1:par.acq_ne2
        for ky=1:par.acq_ne1
            data(:,ky,kz,:,c) = squeeze(data(:,ky,kz,:,c)).*phx(:,fix((ky-1)/nr_shots)+1);
        end
    end
end
end

%=========================================================================
function cov = ReadCovData(CovFileName)

fid = fopen(CovFileName);
if (fid~=-1)
    ncoils = fread( fid, 1, 'uint16' );
    cov = single(fread(fid,'single'));
    cov = complex(cov(1:2:end),cov(2:2:end));
    cov = reshape(cov,ncoils,ncoils);
else
    cov = 0;
end
end

%=========================================================================
function data = ApplyCovData(data,cov,par)

data = reshape(permute(cov^(-0.5)*reshape(permute(data,[5 1 2 3 4]), ...
    par.acq_ncoils,prod([par.acq_ne0,par.acq_ne1,par.acq_ne2,par.acq_ne3])),[2 1]),...
    [par.acq_ne0,par.acq_ne1,par.acq_ne2,par.acq_ne3 par.acq_ncoils]);
end

%=========================================================================
function newdata = k2i(data,dim)

numDims = ndims(data);
idx = cell(1,numDims);
for k = 1:numDims
    m = size(data, k);
    if m>1 & (isempty(dim) | ~isempty(find(k==dim))),
        p = bitshift(m,-1)+1;
        idx{k} = [p:m 1:p-1];
        clear p;
    else
        idx{k} = [1:m];
    end
end
clear k m;
newdata = data(idx{:});
fftnumelements = 1;
for k = 1:numDims
    m = size(newdata, k);
    if m>1 & (isempty(dim) | ~isempty(find(k==dim))),
        newdata = ifft(newdata,[],k);
        fftnumelements = fftnumelements*m;
    end
end
clear k m numDims;
newdata(idx{:}) = newdata;
clear idx;
newdata = newdata*fftnumelements;
end

%=========================================================================
function newdata = i2k(data,dim)

numDims = ndims(data);
idx = cell(1,numDims);
for k = 1:numDims
    m = size(data, k);
    if m>1 & (isempty(dim) | ~isempty(find(k==dim))),
        p = bitshift(m,-1)+1;
        idx{k} = [p:m 1:p-1];
        clear p
    else
        idx{k} = [1:m];
    end
end
clear k m;
newdata = data(idx{:});
fftnumelements = 1;
for k = 1:numDims
    m = size(newdata,k);
    if m>1 & (isempty(dim) | ~isempty(find(k==dim))),
        newdata = fft(newdata,[],k);
        fftnumelements = fftnumelements*m;
    end
end
clear k m numDims;
newdata(idx{:}) = newdata;
clear idx;
newdata = newdata/fftnumelements;
end

%=========================================================================
function [data,par] = ReconRadialData(data,par,weight)

%     data = data(:,end-60:end,:,:,:);

%---------------------------------------------------------------------
% Set-up
no_samples      = par.acq_matrix(1);
no_profiles     = par.acq_matrix(2);

%     no_profiles     = size(data,2);

k               = zeros(no_samples,3,no_profiles,'single');

%---------------------------------------------------------------------
% Initialization of gridder
kernel_width    = 4;
kernel_beta     = 5.75;  %according to Jackson, IEEE TMI 10(3):473 1991
grid_ovs        = 1;

%---------------------------------------------------------------------
% Calculate radial trajectory
if no_samples/2~=floor(no_samples/2)
    k0 = [zeros(1,no_samples);linspace(-floor(no_samples/2),floor(no_samples/2),no_samples)];
else
    k0 = [zeros(1,no_samples);linspace(-floor(no_samples/2),ceil(no_samples/2-1),no_samples)];
end

for i = 0:no_profiles-1
    %         rot_angle = mod(i * pi/180*111.246,2*pi);
    %         if( rot_angle > pi )
    %             rot_angle = rot_angle - pi;
    %         end
    rot_angle = -i*pi/no_profiles;
    R = [cos(rot_angle),-sin(rot_angle);sin(rot_angle),cos(rot_angle)];
    k(:,1:2,i+1) = (R*k0)';
end
k = permute(k,[1,3,2]);
clear k0 R;

%---------------------------------------------------------------------
% Calculate simple k-space weights
if weight(1) == -1
    gk = k(2:end,:,:)-k(1:end-1,:,:); gk(end+1,:,:) = gk(end,:,:);
    weight = abs(k(:,:,1).*gk(:,:,1)+k(:,:,2).*gk(:,:,2));
    weight(end,:) = weight(end-1,:);
    weight = double(reshape(weight,no_samples*no_profiles,1));
    clear gk;
end

%---------------------------------------------------------------------
% Calculate filter for normalization
fnorm = gridder(single([0 0 0]),single([1]),[1],[no_samples*grid_ovs no_samples*grid_ovs 1],1,kernel_width,kernel_beta);

%---------------------------------------------------------------------
% Shift the origin of every odd profile by one
data = ShiftRadialOrigin(data);

%---------------------------------------------------------------------
% Grid, Fourier transform, normalize
s = size(data); s(1:2) = no_samples * grid_ovs;
tmp = complex( zeros(s,'single'),zeros(s,'single'));
for slice=1:par.acq_ne2
    for coil=1:par.acq_ncoils
        tmp(:,:,slice,1,coil) =                                         ...
            k2i(gridder(reshape(k,no_samples*no_profiles,3),                ... % kx,ky,kz-position (Nx3)
            reshape(data(:,:,slice,1,coil),size(data,1)*size(data,2),1),... % data (Nx1)
            weight,                                                     ... % data weight (Nx1)
            [no_samples no_samples 1],                                  ... % size of k-space (3x)
            grid_ovs,                                                   ... % oversampling factor (1x)
            kernel_width,                                               ... % Kaiser-Bessel window-width (1x)
            kernel_beta),[1 2])'./                                      ... % Kaiser-Bessel window-beta (1x)
            k2i(fnorm,[1 2]);                                               % Normalize
    end
end

%---------------------------------------------------------------------
% Crop the image due to the reconstruction on a finer grid
acq_matrix = round(no_samples/par.acq_ovs(1));
tmp  = tmp(floor((no_samples*grid_ovs-acq_matrix)/2)+1:end-ceil((no_samples*grid_ovs-acq_matrix)/2), ...
    floor((no_samples*grid_ovs-acq_matrix)/2)+1:end-ceil((no_samples*grid_ovs-acq_matrix)/2),:,:,:);
tmp  = tmp(:,end:-1:1,:,:,:);

data = flipdim(tmp,3); clear tmp;

% --------------------------------------------------------------------
% Update acq matrix
par.acq_matrix(1) = size(data,1);
par.acq_matrix(2) = size(data,2);
end

%=========================================================================
function data = ShiftRadialOrigin(data)

shift = (-1).^(0:size(data,2)-1);
shift(shift==-1) = 0;
ind_shift = find(shift);
data(2:end,ind_shift,:,:,:) = data(1:end-1,ind_shift,:,:,:);
data(1,ind_shift,:,:,:) = 0;
end

%=========================================================================
function [data, par, weight] = ReconSpiralData(data,par,acq_matrix,weight)

%---------------------------------------------------------------------
% Spiral fine-tuning (scanner specific)
channel_delay  = 0;
phase_offset   = 0;
lambda         = 3;

%---------------------------------------------------------------------
% Initialization of gridder
kernel_width   = 4;
kernel_beta    = 5.75;  %according to Jackson, IEEE TMI 10(3):473 1991
grid_ovs       = 1;

%---------------------------------------------------------------------
% Definition of k-space trajectory is found in mpuspiral__g.c in
% Philips pulse programming environment
no_samples     = par.acq_matrix(1) ;
no_interleaves = par.acq_matrix(2);
no_turns       = acq_matrix/(2*no_interleaves);
lambda         = min(no_turns,lambda);
phi_top        = pi*acq_matrix*sqrt(1+lambda)/(no_interleaves*no_samples);
A              = no_interleaves/(2*pi);
k              = zeros(no_samples,no_interleaves,3,'single');

%---------------------------------------------------------------------
% Calculate spiral trajectory
for interleave=0:no_interleaves-1
    phi_0 = 2*pi*interleave/no_interleaves+phase_offset;
    for sample=fix(channel_delay):no_samples-1
        samp = channel_delay - fix(channel_delay) + sample;
        phi_t = phi_top*samp/sqrt(1+lambda*samp/no_samples);
        k(sample+1,interleave+1,1) = A*phi_t*cos(phi_t-phi_0);
        k(sample+1,interleave+1,2) = A*phi_t*sin(phi_t-phi_0);
    end
end

%---------------------------------------------------------------------
% Calculate simple k-space weights
if weight(1) == -1
    gk = k(2:end,:,:)-k(1:end-1,:,:); gk(end+1,:,:) = gk(end,:,:);
    weight = abs(k(:,:,1).*gk(:,:,1)+k(:,:,2).*gk(:,:,2));
    weight(end,:) = weight(end-1,:);
    weight = double(reshape(weight,no_samples*no_interleaves,1));
    clear gk;
end

%---------------------------------------------------------------------
% Calculate filter for normalization
fnorm = gridder(single([0 0 0]),single([1]),[1],[grid_ovs*acq_matrix grid_ovs*acq_matrix 1],1,kernel_width,kernel_beta);

%---------------------------------------------------------------------
% Trajectory and phase corrections
data = ShiftSpiralOrigin(data);

%---------------------------------------------------------------------
% Grid, Fourier-transform, normalize
s = size(data); s(1:2) = grid_ovs*acq_matrix;
tmp = complex( zeros(s,'single'),zeros(s,'single'));
for slice=1:par.acq_ne2
    for coil=1:par.acq_ncoils
        tmp(:,:,slice,coil) =                                               ...
            k2i(gridder(reshape(k,no_samples*no_interleaves,3),                 ... % kx,ky,kz-position (Nx3)
            reshape(data(:,:,slice,coil),size(data,1)*size(data,2),1),  ... % data (Nx1)
            weight,                                                     ... % data weight (Nx1)
            [acq_matrix acq_matrix 1],                                  ... % size of k-space (3x)
            grid_ovs,                                                   ... % oversampling factor (1x)
            kernel_width,                                               ... % Kaiser-Bessel window-width (1x)
            kernel_beta),[1 2])./                                       ... % Kaiser-Bessel window-beta (1x)
            k2i(fnorm,[1 2]);                                               % Normalize
    end
end

%---------------------------------------------------------------------
% Crop the image due to the reconstruction on a finer grid
tmp  = tmp(floor((grid_ovs*acq_matrix-acq_matrix)/2)+1:end-ceil((grid_ovs*acq_matrix-acq_matrix)/2), ...
    floor((grid_ovs*acq_matrix-acq_matrix)/2)+1:end-ceil((grid_ovs*acq_matrix-acq_matrix)/2),:,:,:);
data = tmp; clear k tmp fnorm min_temp;

% --------------------------------------------------------------------
% Update acq matrix
par.acq_matrix(1) = size(data,1);
par.acq_matrix(2) = size(data,2);
end

%=========================================================================
function data = ShiftSpiralOrigin(data)

data_temp = complex(zeros(size(data),'single'),zeros(size(data),'single'));
slice = ceil(size(data,3)/2);
[mi,origin_shift] = min(range(angle(data(1:20,:,slice,:,:)),2));
origin_shift = round(mean(squeeze(origin_shift)));
data_temp(1:(end-origin_shift),:,:,:,:) = data((1+origin_shift):end,:,:,:,:);
data = data_temp;
end

%=========================================================================
function img = ZeroFill(data,par,slice)

img = zeros([max(par.rec_matrix(1:2),par.acq_matrix(1:2)) par.acq_ncoils par.acq_nrows],'single');
img(bitshift(par.rec_matrix(1)-par.acq_matrix(1),-1)+1:bitshift(par.rec_matrix(1)-par.acq_matrix(1),-1)+par.acq_matrix(1),       ...
    bitshift(par.rec_matrix(2)-par.acq_matrix(2),-1)+1:bitshift(par.rec_matrix(2)-par.acq_matrix(2),-1)+par.acq_matrix(2),:,:) = ...
    i2k(data(:,:,slice,:,:,:),[1 2]);
img = k2i(img,[1 2]);
end

%=========================================================================
function img = CombineCoils(img,par)

% --------------------------------------------------------------------
% Process phase-contrast data (if available)
if (par.acq_nrows>1)
    % ----------------------------------------------------------------
    % Root sum-of-squares coil combination +
    % weighted sum of coil phases differences
    modul = mean(sqrt(sum(abs(img).^2,3)),4);
    scale = mean(abs(img),4);
    phase = angle(sum(scale.*img(:,:,:,1)./img(:,:,:,2),3));
    phase = single((2^(par.rec_pixel_depth-1)-1)*(phase/pi+1));

    % ----------------------------------------------------------------
    % store modulus in real part;
    % phase in imaginary part of img
    img = complex(modul,phase);
    clear modul scale phase;
else
    % ----------------------------------------------------------------
    % Standard root sum-of-squares coil combi
    img = sqrt(sum(abs(img).^2,3));
end
end

%=========================================================================
function [img,histo] = ScaleImage(img,par,histo,progress)

dmax = max(real(img(:)))*0.99; img(find(real(img)>dmax)) = dmax;
dmin = min(real(img(:)))*1.01; img(find(real(img)<dmin)) = dmin;
img = complex(uint16((real(img)-dmin)./(dmax-dmin+.001).*(2^par.rec_pixel_depth-1)),uint16(imag(img)));
histo(:,progress) = uint16(histc(real(img(:)),1:2^par.rec_pixel_depth));
clear dmax dmin;
end

%=========================================================================
function img = ShiftImage(img,par)

img = circshift(img,[par.rec_img_shift(1) ...
    par.rec_img_shift(2) ...
    par.rec_img_shift(3) 0]);
end

%=========================================================================
function img = SquareImage(img,par)

if (par.rec_matrix(1)~=par.rec_matrix(2))
    tmp = zeros(par.rec_matrix(1),par.rec_matrix(1),'uint16');
    tmp(:,bitshift(par.rec_matrix(1)-par.rec_matrix(2),-1)+1:...
        bitshift(par.rec_matrix(1)-par.rec_matrix(2),-1)+par.rec_matrix(2)) = img;
    img = tmp; clear tmp;
end
end

%=========================================================================
function img = RotateImage(img,par)

REC_ROTATE_L        = -1;
REC_ROTATE_NONE     =  0;
REC_ROTATE_R        =  1;
REC_FLIP_ONLY       =  2;

if isfield(par,'epi_ne0')
    rec_img_ori = -par.rec_img_ori;
else
    rec_img_ori =  par.rec_img_ori;
end

switch rec_img_ori
    % ----------------------------------------------------------------
    % Rotate anti clock-wise
    case REC_ROTATE_L
        img = flipdim(permute(img,[2 1 3 4]),2);
        % ----------------------------------------------------------------
        % Rotate clock-wise
    case REC_ROTATE_R
        img = flipdim(permute(img,[2 1 3 4]),1);
        % ----------------------------------------------------------------
        % Flip
    case  REC_FLIP_ONLY
    case -REC_FLIP_ONLY
        img = flipdim(flipdim(img,1),2);
        % ----------------------------------------------------------------
        % Do not rotate
    otherwise
end
end

%=========================================================================
function AutoView(data,histo,actual,total)

%---------------------------------------------------------------------
% Default window size
wsize = 512;

%---------------------------------------------------------------------
% Use available histogram data for rescaling
for i=1:actual
    index = find(histo(:,i)>0.3*mean(histo(:,i)));
    maxind(i) = max(index);
    minind(i) = min(index);
end
minint = min(minind);
maxint = max(maxind);

scrsz = get(0,'ScreenSize');
f = figure(1);
set(f,  'Position', [scrsz(3)/2-bitshift(wsize,-1) scrsz(4)/2-bitshift(wsize,-1) wsize wsize],...
    'Color',[1 1 1],...
    'Name','ReconFrame - Autoview',...
    'NumberTitle','off',...
    'MenuBar','none');
axes('Position',[0 0 1 1],'Parent',f);

%---------------------------------------------------------------------
% Bilinear image resizing before display
imagesc(transpose(imresize(abs(data),[wsize,wsize],'bilinear')),[minint,maxint]); colormap(gray);
text(wsize/2,10,sprintf('%04d/%04d',actual,total),'FontName','verdana','FontWeight','bold','Color','white','HorizontalAlignment','center');
text(wsize/2,wsize-10,'For Investigational Use Only - (C) www.gyrotools.com','FontName','verdana','FontWeight','bold','Color','white','HorizontalAlignment','center');
drawnow;
waitforbuttonpress;
clf;
%---------------------------------------------------------------------
end

%=========================================================================
% R&D Course (begin)
%=========================================================================
function [img,sensitivity] = CombineCoilsUsingVirtualBodyCoil(data)

%-------------------------------------------------------------------------
% This function performs a Roemer reconstruction without
% requiring a body-coil or sum-of-squares image.
%
% A virtual body-coil reference image is generated using the
% array compression principle permitting phase-sensitive image
% production.
%
% The coil-combined image perserve object phase and therefore
% permits any phase-sensitive image production (e.g. water-fat separation)
%
% Input:    Image-domain data with individual coil images
%
% Output:   Coil-combined image-domain data, sensitivity map (coca)
%
% History:  20080603 MB
%           20080610 MB
%-------------------------------------------------------------------------

% ------------------------------------------------------------------------
% Preparation
% ------------------------------------------------------------------------
% Get matrix sizes
x_res       = size(data,1);
y_res       = size(data,2);
nr_coils    = size(data,3);

% ------------------------------------------------------------------------
% 1.1) Image mask definition
% ------------------------------------------------------------------------
% Calculate the sum-of-squares image and calculate a mask on it
% Mask calculation: Assume that the noise level is much smaller than the
% signal level. Furthermore the noise in a sum-of-squares image is gamma
% distributed. 

% Calculate the sum-of-squares image (and scale it to values between 0 and 1
sos_data = mat2gray( sqrt(sum(abs(data).^2,3)) );

% Add own code here
cutoff = ...;
mask = im2bw(sos_data,cutoff);

% ------------------------------------------------------------------------
% 1.2) Compute virtual body-coil image
% ------------------------------------------------------------------------
% Convert data into vector form for the coil combination ( [nr_coils,nr_of_pixels] )
% and exclude the pixels which are not in the mask (use mask as ROI)
ind_mask = find(mask);
data = reshape(data, x_res*y_res,nr_coils);
data = permute(data,[2,1]);
masked_data = data(:,ind_mask);

% ------------------------------------------------------------------------
% Calculate coil combination matrix for combining all elements into one
% virtual coil
P = zeros(nr_coils);

% Add own code here
P = ...

% Add own code here
A = ...;

% ------------------------------------------------------------------------
% Combine data to obtain virtual body-coil image

% Add own code here
bodycoil = ...;

% ------------------------------------------------------------------------
% Convert coil-combined data back the the original matrix.
bodycoil = permute(bodycoil,[2,1]);
bodycoil = reshape(bodycoil,x_res,y_res);

% ------------------------------------------------------------------------
% Transform input data back to its original size
data = permute(data,[2,1]);
data = reshape(data,x_res,y_res,nr_coils);

% ------------------------------------------------------------------------
% 2) Calculate coil sensitivities
% ------------------------------------------------------------------------
sensitivity = CalcCoilSensitivities(data,bodycoil,mask);

% ------------------------------------------------------------------------
% 3) Roemer combination
% ------------------------------------------------------------------------
% Perform the Roemer reconstruction using the smoothed sensitivity

% Add own code here
img = ...;

% ------------------------------------------------------------------------
% Mask singular values
img(isinf(img)) = 0;
img(isnan(img)) = 0;

end

%=========================================================================
function sensitivity = CalcCoilSensitivities(data,bodycoil,mask);
% ------------------------------------------------------------------------
% Calculate sensitivity maps
% ------------------------------------------------------------------------
% Sensitivity maps are smoothed using 2D spline interpolation.
% Spline-fitting is slow; therefore define a lower dimensional grid
% consisting of 625 pixels and take raw sensitivities on the grid as input
% for the spline-fitting.
%
% (Note that some functions use the matrix coordinate system
% (origin upper left, first coordinate rows, second, columns) and some use
%  the Euclidian coordinate system (origin lower right left, first coordinate
%  x-axis, second y-axis). The notation x and y here stands for the axis in
%  the Euclidian coordinate system.)

% ------------------------------------------------------------------------
% Get matrix sizes
x_res       = size(data,1);
y_res       = size(data,2);
nr_coils    = size(data,3);

% ------------------------------------------------------------------------
% Preassign the complex sensitivity map
sensitivity = complex(zeros(size(data)),zeros(size(data)));

[input_x_grid,input_y_grid] = meshgrid(floor(linspace(1,size(data,2),25)),...
    floor(linspace(1,size(data,1),25)));

% ------------------------------------------------------------------------
% For the spline fitting we only provide pixels which are in the mask.
% To test if the pixels are in the mask, we convert the two-dimensional
% matrix indices to one-dimensional indices.
ind_input = sub2ind(size(mask),input_y_grid(:),input_x_grid(:));

% ------------------------------------------------------------------------
% Test which of the input pixels are in the mask and only use these inputs
% for the spline fitting
ind_input = ind_input(mask(ind_input)>0);

% ------------------------------------------------------------------------
% Convert the linear indices back to multi-dimensional indices
[input_x, input_y] = ind2sub(size(mask),ind_input);

% ------------------------------------------------------------------------
% Define the sensitivity on the original high resolution grid.
[x,y] = meshgrid(1:y_res,1:x_res);

% ------------------------------------------------------------------------
% Process the mask: The mask usually has holes in areas with low signal.
% The coil sensitivies however should ideally be defined on the whole image.
% For that purpose fill the holes in the mask and define a new mask which
% specifies where the sensitivities should be calculated.
% Before the hole filling process the mask  median filtered and slightly
% extrapolated to remove single isolated foreground and background pixels
% in the mask.
se = strel('disk',2);
interp_mask = imfill(imdilate(medfilt2(double(mask)),se),'holes');

% ------------------------------------------------------------------------
% Smooth and interpolate sensitivity maps using a smoothing thin-plate
% spline. The real and imaginary parts of the sensitivity are smoothed
% separately as the smoothing function can only take real inputs.
for i = 1:nr_coils
    % --------------------------------------------------------------------
    % Calculate raw sensitivities by dividing the data by the virtual body-coil.
    % Sensitivity is defined on the original mask.
    raw_sensitivity = mask.* data(:,:,i)./bodycoil;

    % --------------------------------------------------------------------
    % Smooth the real part of the sensitivity using the 2D-spline
    % interpolation. As input, the data from the low resolution grid,
    % defined earlier is provided.
    spline_function = tpaps([input_x(:),input_y(:)]',real(raw_sensitivity(ind_input))');

    % --------------------------------------------------------------------
    % Evaluate the spline function on the low dimensional grid
    % and then interpolate the low dimensional grid on the
    % original high resolution grid.
    val_spline = reshape(fnval(spline_function,[input_y_grid(:),input_x_grid(:)]'),size(input_x_grid));
    sensitivity_real = interp2(input_x_grid,input_y_grid,val_spline,x,y);

    % --------------------------------------------------------------------
    % Smooth the imaginary part of the sensitivity using the 2D-spline
    % interpolation
    spline_function = tpaps([input_x(:),input_y(:)]',imag(raw_sensitivity(ind_input))');
    val_spline = reshape(fnval(spline_function,[input_y_grid(:),input_x_grid(:)]'),size(input_x_grid));
    sensitivity_imag = interp2(input_x_grid,input_y_grid,val_spline,x,y);

    % --------------------------------------------------------------------
    % Combine real and imaginary part of the smoothed and interpolated
    % sensitivity. The sensitivity maps should now be defined on the
    % "hole-filled" mask
    sensitivity(:,:,i) = interp_mask.*complex(sensitivity_real,sensitivity_imag);
    sensitivity(isnan(sensitivity)) = 0;

end
end

%=========================================================================
function [img_fat,img_water] = WaterFatSeparation(data)
alpha_min = fminbnd(@CostFunction,0,2*pi);
data = data.*exp(j.*alpha_min);
img_water = abs(abs(data).*(sign(angle(data))+1));
img_fat = abs(abs(data).*(-sign(angle(data))+1));

    function cost = CostFunction(alpha)
        data_test = data.*exp(j.*alpha);
        cost = -sum(abs(imag(data_test(:))));
    end
end
%=========================================================================
% R&D Course (end)
%=========================================================================

%=========================================================================
%=========================================================================