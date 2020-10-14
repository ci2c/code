Dataacces from Linux/Windows and VMS for R7.x and newer...

What you need: 
--------------
Perl: perl 5.6 or newer is fine
      Linux: Perl should be installed
      Windows: www.activestate.com
      Test your perl: type "perl -v" in a Command Prompt/Shell Window
Sybase: To connect the scanner Database a sybase client is needed
      Linux: sybase_orig/sybase-ase-11.0.3.3-6.i386.rpm
             Full Sybase Server for Linux. Only a small client is needed, 
	     however the whole Server has to be installed. (~80MB)
             It is a free version. But you should register at 
             http://www.sybase.com/linux/ase/
	Windows: Philips provide you with an Sybase client if you install Pride.
		 Per default the sybase client islq.exe is not installed on a 
		 Pride PC!!!
		 You have to install "open client" in addition to 
		 "open client runtime" for ASE 12.5!
		 Verify the path of sybase at the end of the file pati_common.pl. 
		 Since the pride wizard will overwrite the sybase ini-File 
		 each time, a new sql.ini has to be use located in the local 
		 pati_linux folder.
Perl-Scripts:
-------------
pati_linux: Contains all Perlscripts needed for R9, R10, R11, R12, R1.2, R1.5, 
R2.x
The scripts can create V3, V4, and V4.1 parfiles, nearly independend from the 
Scanner release. V4.1 works only on Rel12/2.x.
V4 is used by Philips for Releases >R10.
V4.1 is used by Philips for Release >=R12
It is known to run under Linux, Windows and VMS.             
 

pati_common.pl contains all global settings. In this file you can add all your 
               scanners, and some additional variables. (See comments in the 
               file.)
               Check the pathes at the end of the file for your setup!

pati_linux.pl  This Programm ist the main programm
               The program needs isql (installed by sybase) 
               
pati_subrout.pl Contains all sybase request. (Is needed by pati_linux,
               pat_list.pl, scan_list.pl, get_scan.pl parameter_list.pl)

pat_list.pl, scan_list.pl, parameter_list.pl, get_scan.pl
               Small scripts needed to download rec, cpx or raw-files
               within Matlab, IDL, PvWave and many others.
               It can also be used for fast database access.
               (please ask for further infos if needed.)

rec2analyze.pl A small programm to convert any rec-Files to analyze Format.
               Needs only Image Magick. (Runs not under VMS)

pati_linux.pl -h shows all options.


Installation:
Sybase (Linux)
--------------
(as root)  (Please ask for the debian package or use alien!)
   rpm -ihv sybase-ase-11.0.3.3-6.i386.rpm
The software will be installed to /opt/sybase
Type the following line into the shell you plan to make the further 
installation
   export SYBASE=/opt/sybase

Add the following lines to /etc/profile:
(like this the above line is available in all future shells.)
   SYBASE=/opt/sybase
   export SYBASE

Configure Sybase (Linux and Windows)
------------------------------------
Edit /opt/sybase/interfaces (Linux) 
     c:\pati_linux\sql.ini (windows)

For each system you need an entry as following:
gyro1
        query tcp ether gyro1 5001 

(If your scanner scanner name is not resolved by a dns-Server, add the scanner 
to the local file /etc/hosts or c:\windows\system32\drivers\etc\hosts
like: 

    192.168.43.200  gyro1.ethz.ch       gyro1

or use the ip-Addresses in the interface file.)
!!!Use only lower case letters for the scannername in any file!!!

5001 is the port of the sybase database. (Do not change!)

You can have several line (each separated with an empty line) in your 
interfaces file.

Test of the sybase request: 
---------------------------
Replace gyro1 with your scannername!!!

Linux: (as normal user. Please open a new terminal,
to test if all enviroment variables are OK.)

cd /opt/sybase/
./bin/isql -U gyroscan -P krokodil -S gyro1
                    (change gyro1 to you scanner name)

1> use patientdb
2> go
1> sp_help
2> go

If you now get a long output the sybase connection is OK.
1> quit

Windows:
Open a command prompt (cmd):
d:\sybase\ocs-12_5\bin\isql.exe -U gyroscan -P krokodil -S gyro1 -I "c:\pati_linux\sql.ini"
1> use patientdb
2> go
1> sp_help
2> go

If you now get a long output the sybase connection is OK.
1> quit

d:\sybase\ocs-12_5\bin\isql.exe should agree with the line
$isql="d:\\sybase\\ocs-12_5\\bin\\isql.exe";
in the file pati_common.pl    
All \ has to be double in the file pati_common.pl

and  
-I "c:\pati_linux\sql.ini"
with: $isql_interface="-I \"c:\\pati_linux\\sql.ini\""
Be aware of the special notation of \" and \\.

Test the file access:
---------------------
Windows: Map Network Drive
Folder: \\gyro1\bulk
Username: export
Password: scandata
(as used in the pati_common.pl)

Linux: Use automount. 
Add to /etc/auto.misc the line:
gyro1     -fstype=cifs,username=export,password=scandata,uid=500,gid=500,port=139 ://gyro1/bulk

(uid and gid should be those of the default user running the script)
Verify that autofs is running ( /etc/init.d/autofs status )
(if you have problems please let me know...)

Changes on the scanner:
-----------------------
R9: none

R10: 
You have to add a path to the ftp-Server:
Control panel -> admin tools -> Internet Information Services
default FTP -> action -> new virtual directory
Name: Patientdb
Path: D:\MRSybase\bulk\patientdb

R11/R1.2: If Pride is working, nothing has to be done. 
For earlier Releases the Scanner Firewall has to be open for Sybase (Port 5001/TCP)

All variables you should ajust you will find in pati_common.pl

Please verify all other options in the file: pati_common.pl
and make a backup from that file, to prevent to overwrite it.

Now pati_linux.pl should run...

Furter remarks:
---------------

Windows: 
--------
There is  possibility to add pati to the menu under the right mouse 
(if you are over a folder)
Execute the file dosbox_pati2.reg.

The program was design to be used command line. Therefore 
you should add the folder from pati to the path.
Like that you can just open an DOS-Prompt (Start->Run...->cmd), 
change to the folder where the data should be stored and type 
pati_linux.pl (you can also rename the file to pati.pl) with options 
if needed.

I added also a file dos_here.reg, which will add two keys to the registry 
HKEY_CLASSES_ROOT\Directory\shell\DOSBox
which allow to press in the explorer with the right mouse button on any (local) folder and choose "DOS-Box here".
This can be improved that directly pati will be started. 

If you add the folder c:\pati_linux\ (or the corrensponding on your computer)
you can start the file dosbox_pati.reg which add two lines in the contentmenu from your Explorer.

Now you can access pati if you click with the right mouse on a folder -> pati
pati_cpx will export RAW and Complex-Data.

This programs are only for research and comes without any warranty

Please send improvements of the scripts back to me.

06/2007 RL
rluchin@biomed.ee.ethz.ch

