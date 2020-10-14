#!/usr/bin/perl
###################################################################
#              Pati V0.99d (Linux/Win32/VMS R9-R12/R1-2.x         #
#                RL 2007 IBT Zuerich (Switzerland)                #
#                      http://www.mr.ethz.ch/                     #
#                            Presets                              #
###################################################################

### Variables: Please ajust

$image_reorder=1;       #default 1:images will be reordert to be in correct order
$use_terminal_colors=0; #default 1: If you have Problems in terminals to see the
                        #patient list, turn it off
                        #Windows: use 0!
$use_terminal_size=0;   #default 0 (off): Seems to work only on very old Linux Versions.
$anonym=1;              #patient name will be shorten to 2 letters and birthday
                        #will be 1.1 of the birthday year. 
$no_conf=1;             #will not ask if the input is correct.
$pride_vers=4.1;        #default Pride format: 3 (R9), 4 (R10), and 4.1 (R12)
                        #are valid
                        #use -p3, -p4, or p41 to change it at startup.
$filename_format=4;     #0: as up to now: pat_name+study_date+scan_name+series_oid
                        #1: pat_name+study_date+scan_name+last 4 digits series_oid (may not be unique)
                        #2: pat_name+scan_name+last 4 digits series_oid (unique?)
                        #3: pat_name+study_date+series_oid+scan_name
                        #4: pat_name+study_date+series_time+acqu_nr+recon_nr+scan_name (unique?)
       			#5: pat_name+acqu_nr+recon_nr+scan_name (unique??) 

$node="";               #default scanner. If you use/have only 1 scanner add it here.
                           #All Scanners has to be known by this computer 
                           #(either over DNS or use the hosts-file and 
                           #by the file /opt/sybase/interfaces (windows use 
                           #dsedit to create it) as following:
			   #use only lower case hostnames!!!
#	gyro1
#	        query tcp ether gyro1 5001


#Create for each scanner a block as followed:
#Hints: Use only lowercase for the hostname!
#       do not change the lines:
# $username{$host}="gyroscan";   #sybase user
# $pswd{$host}="krokodil";       #sybase password
#       Default lines for Windows see further down!

#linux with win_share
$host="achieva3t";			#lower case host name!
$allowed_hosts{$host}="r12";    #SW release scanner R1.x->R11 (r9, r10, r11)
$order_hosts{$host}=1;         #order how scanners are presented during startup
$username{$host}="gyroscan";   #sybase user (do not change!!!)
$pswd{$host}="krokodil";       #sybase password (do not change!!!)
$username_ftp{$host}="export";  #ftp or win_share username (should be fine for 99% of the centers!)
$pswd_ftp{$host}="scandata";           #ftp or win_share password (should be fine for 99% of the centers!)
$host_ftp{$host}="";           #This option is only needed if ftp is used over a proxy (add proxy name in that case)
$file_transfer{$host}="win_share";   #File accessmode: ftp or win_share (Win_share is fine for Rel10 and later!)
$file_transfer_dir{$host}="/misc";  #ftp: empty, win_share: path to patientdb from this host!

#$host="gyro35";
#$allowed_hosts{$host}="r12";    
#$order_hosts{$host}=3;        
#$username{$host}="gyroscan"; 
#$pswd{$host}="krokodil";    
#$username_ftp{$host}="export";
#$pswd_ftp{$host}="scandata";
#$host_ftp{$host}="";           
#$file_transfer{$host}="win_share";  
#$file_transfer_dir{$host}="/misc/gyro35";

#For Windows with win_share
#$host="gyro3";			#lower case host name!
#$allowed_hosts{$host}="r11";	#SW release scanner R1.x->R11 (r9, r10, r11)   
#$order_hosts{$host}=5;        
#$username{$host}="gyroscan"; 	#sybase user (do not change!!!)
#$pswd{$host}="krokodil";    	#sybase password (do not change!!!)
#$username_ftp{$host}="export"; #ftp or win_share username (should be fine for 99% of the centers!)
#$pswd_ftp{$host}="scandata";	#ftp or win_share password (should be fine for 99% of the centers!)
#$host_ftp{$host}="";           #This option is only needed if ftp is used over a proxy (add proxy name in that case)
#$file_transfer{$host}="win_share";  #File accessmode: ftp or win_share (Win_share is fine for Rel10 and later!)
#$file_transfer_dir{$host}="\\\\gyro3\\bulk"; #ftp: empty, win_share: path to patientdb from this host!

#win_share allow to use Windows Share to access the files.
#Please add path in the next hash.
#Linux: Folder has to be mounted automatic (use autofs) or has to be 
#mounted by default.
#Windows will mount the folder using perl subroutins
#In the folder mentioned below the folder patientdb should be found


#SYBASE installation Linux
# export SYBASE=/opt/sybase         has to be added to /etc/profile
# create an appropriate /opt/sybase/interface file
# add scanner to the host-file if dns-lookup is not appropriate... 
#
#windows
#install sybase client
#use dsedit from sybase to create an appropriate interface-file
# Copy that file over to the folder with pati.

# Check the pathes in the following lines!!!

if ($^O eq "MSWin32"){
   $isql="c:\\Program Files\\sybase\\bin\\isql.exe";    #Win32
   $isql_interface="-I \"c:\\pati_linux\\sql.ini\""
} elsif ($^O eq "VMS"){
   $isql="disk1:[SB.SYBASE_CLIENT.SYBASE.BIN]ISQL.EXE";
} else {
   $isql="/opt/sybase/bin/isql";    #Linux
}   

return(1);
