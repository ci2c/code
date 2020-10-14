#! /bin/bash

return=$1
return="${return//_/}"
return="${return//-/}"
return="${return//^/}"
return="${return// /}"
return="${return//./}"
echo ${return}
