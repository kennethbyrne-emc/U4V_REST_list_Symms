# Unisphere for VMAX - List Symmetrix Arrays

This Perl script returns a list of all visible EMC Symmetrix Arrays for a specified Unisphere for VMAX instance using REST api. 

This is a simple example of a REST GET call issued against a Unisphere for VMAX Server. 

# Usage

~~~
usage: perl REST_List_Symm.py ipaddress username password 

Required arguments:
	ipaddress : The Ip Address of server running Unisphere For VMAX
	username  : The Username of a user with Minimum monitor privileges 
	password  : The password for the specified user	
	
Reports the following for each Symmetrix visible to the Unisphere for VMAX server:
	Symmetrix : The Symmetrix Id
	Model	  : The Model of the Symmetrix 
	Ucode     : The current ucode level of the Symmetrix
	Local     : True/False depending on whether the Symmetrix is Local or Remote to the Unisphere for VMAX Server
	Volumes   : The number of Volumes provisioned on the Symmetrix 

~~~


# Example Output

```
-------------------------------------------------------------------------
////    Number of Symmetrix Arrays : 3
-------------------------------------------------------------------------
////    Symmetrix    | Model    | Ucode        | Local | Volumes
-------------------------------------------------------------------------
////    000000000001 | VMAX-1SE | 5876.286.194 | True  | 4318 
////    000000000002 | VMAX-1SE | 5876.286.194 | False | 2211 
////    000000000003 | DMX4-6   | 5773.198     | True  | 1048 
-------------------------------------------------------------------------
```
