###########################################################################################
#     List all EMC Symmetrix Arrays visible from a specified Unisphere for VMAX Server 
#	
#	  Requirements:	
#			Minimum Perl 5 
#			Minimum 8.0 Unisphere For VMAX
#				
#	  Inputs:		
#			ipaddress : The Ip Address of server running Unisphere For VMAX
#			username  : The Username of a user with Minimum monitor privileges 
#			password  : The password for the specified user
#
###########################################################################################

###########################################################################################
#  Imports

 # http://search.cpan.org/~makamaka/JSON/lib/JSON.pm
 # Example install using cpanm:
 #   cpanm -i JSON
use JSON;
 
 # http://search.cpan.org/~mcrawfor/REST-Client/lib/REST/Client.pm
 # Example install using cpanm:
 #   cpanm -i REST::Client
use REST::Client;

 # http://search.cpan.org/~smueller/Data-Dumper-2.154/Dumper.pm
 # Example install using cpanm:
 #   cpanm -i Data::Dumper
use Data::Dumper;

 # http://search.cpan.org/~gaas/MIME-Base64-3.15/Base64.pm
 # Example install using cpanm:
 #   cpanm -i MIME::Base64
use MIME::Base64;
###########################################################################################

###########################################################################################
#  Variables 

# Quit unless we have the correct number of command-line args
$num_args = $#ARGV + 1;
if ($num_args != 3) {
    print "\nUsage: list_symms_example.pl ipaddress username password\n";
    exit;
}

# Set Variables from Arguments 
my $ipaddress= $ARGV[0];
my $username = $ARGV[1];
my $password = $ARGV[2];

my $host = 'https://'.$ipaddress.':8443'; 
my $headers = {
	Accept => 'application/json', 
	Content-Type => 'application/json',
	Authorization => 'Basic ' . encode_base64($username . ':' . $password)
};
###########################################################################################

###########################################################################################
#  Main 

showTitle();
showSymmetrixDetails();

###########################################################################################

###########################################################################################
#  Sub Procedures 

sub showSymmetrixDetails{
	# GET List of Symmetrix Arrays
	my $listSymmetrixArraysUrl = 'univmax/restapi/system/symmetrix';
	
	# Call sub procedure to get json response from server using the specified URL
	my $jsonResponse = runRestGetCall($listSymmetrixArraysUrl);
	
	# Handle the response from the server
	my $numOfSymmetrixArrays = $jsonResponse->{'num_of_symmetrix_arrays'};	
	my $symmetrixIds = toList($jsonResponse,'symmetrixId');

	print "-------------------------------------------------------------------------\n";		
	print "////    Number of Symmetrix Arrays : " . $numOfSymmetrixArrays . "\n";			
	print "-------------------------------------------------------------------------\n";
	print "////    Symmetrix    | Model    | Ucode        | Local | Volumes \n";	
	print "-------------------------------------------------------------------------\n";
	foreach $symmetrixId (@$symmetrixIds){	
		# GET Info for each Symmetrix Array
		
		# Call sub procedure to get json response from server using the specified URL
		my $jsonResponse = runRestGetCall($listSymmetrixArraysUrl . "/" . $symmetrixId);
		
		# Handle the response from the server
		my $symmetrixArrays = toList($jsonResponse,'symmetrix');
		foreach $symmetrixArray (@$symmetrixArrays){
			print "////    " . $symmetrixArray->{'symmetrixId'} ." | ";		
			print $symmetrixArray->{'model'} ." | ";
			print $symmetrixArray->{'ucode'} ." | ";
			if ($symmetrixArray->{'local'} eq 1) {
				print "True  |";
			}else{
				print"False |";
			}
			print " ".$symmetrixArray->{'device_count'} ." | \n";			
		}			
	}
	print "-------------------------------------------------------------------------\n";
}

sub runRestGetCall{
	# Get passed in URL argument
    	my ($url) = @_;	
	# Get Client 
	my $client = getClient();	
	# Run GET call
	$client->GET($url, $headers);	
	# Get Response 
	my $responseContent = $client->responseContent();	
	my $responseCode = $client->responseCode();
	# Add some Error Handling 
	responseErrorHandler($responseCode,$responseContent);
	# Return JSON Response
	return from_json($responseContent);
}

sub getClient{	
	#Get REST client used to issue the Requests
	
	#SSL 
		## Set SSL X509 client authentication
		# my $client = REST::Client->new();	
		# $client->setCert('/path/to/ssl.crt');
		# $client->setKey('/path/to/ssl.key'); 
		# $client->setCa('/path/to/ca.file');
		
		## or 
		
		## Override SSL (DEV ENVIRONMENT ONLY)
		$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;	
		my $client = REST::Client->new();		
		$client->getUseragent()->ssl_opts( SSL_verify_mode => 0 );	
		
	# Set Client Host 
	$client->setHost($host);
	
	return $client;
}

sub responseErrorHandler{
    	# Generic Handler 
	
	# Get passed in response Code and Response Content 
    	my ($responseCode,$responseContent) = @_;
	
	if($responseContent eq ""){
		print "Response code:" . $responseCode . "\n";
		print "Response: No Response";
		exit;
	}elsif( $responseCode eq '500' ){			
		print "Response code:" . $responseCode . "\n";
		my $jsonResponse = from_json($responseContent);
		my $error_message = $jsonResponse->{'message'};
		print "ERROR: " . $error_message;
		exit;
	}elsif( $responseCode eq '400' ){			
		print "Response code:" . $responseCode . "\n";
		my $jsonResponse = from_json($responseContent);
		my $error_message = $jsonResponse->{'message'};
		print "ERROR: " . $error_message;
		exit;
	}elsif($responseCode ne '200' ){	
		print "Response code:" . $responseCode . "\n";
		print "Response:" . $responseContent;
		exit;
	}
}

sub toList {
   	my $data = shift;
   	my $key = shift;
   	if (ref($data->{$key}) eq 'ARRAY') {
       		$data->{$key};
   	} elsif (ref($data->{$key}) eq 'HASH') {
       		[$data->{$key}];
   	} else {
       		[];
   	}
}

sub showTitle{
	print "\n";
	print "        ///////////////    /////          /////         /////////        \n";
	print "        ////               //////        //////       ///		\n";
	print "        ////               //// //      // ////     ///			\n";
	print "        ////               ////  //    //  ////   ///			\n";
	print "        ///////////////    ////   //  //   ////   ///			\n";
	print "        ////               ////    ////    ////   ///			\n";
	print "        ////               ////            ////    ///			\n";
	print "        ////               ////            ////      ///			\n";
	print "        ///////////////    ////            ////        //////////	\n";
	print "\n";
}
###########################################################################################
