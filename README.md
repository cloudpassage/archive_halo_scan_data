# archive_halo_scan_data
Script to retrieve and store your historical scan data locally

<b>Program description</b>

The Ruby program file ‘archiveScanData.rb’ retrieves and archives information on historical scans.

The program makes use of the Halo API client library (in alpha) which handles functions like making REST calls, creating and parsing JSON responses, authentication and error handling.

<b>Install instructions</b>

Download the files from here, then go to the halo-api-client directory and run the following command:

$ gem install halo-api-lib

<b>Note:</b> Make sure to reinstall the gem if you receive an updated copy.

Copy the file named ‘archiveScanData.rb’ to the same directory where you installed the Halo API client

Halo requires the script to pass both the key ID and secret key values for a valid Halo API key in order to make API calls. You pass those values in a file name of your choosing, specifying the full path to the file in the --auth=<filename> option.

Copy the ID and the secret into a text file so that it contains just one line, with the key ID and the secret
separated by a vertical bar ("|"):

your_key_id|your_secret_key

Save the file as, say scanData.auth (or any other name).

<b>Program usage</b>

Run the following command to see program usage:

$ ./archiveScanData.rb -?

Usage: archiveScanData.rb [flag]
  
  where flag can be one of:
  
    --auth=<file>			Read auth info from <file>
  
    --starting=<when>		Only get historical scans after <when> (ISO-8601 format)
  
    --ending=<when>		Only get historical scans till <when> (ISO-8601 format)
  
    --base=<url>			Override base URL (normally https://portal.cloudpassage.com/)
  
    --localca			Use local CA file (needed on Windows)
  
    --detailsfiles			Write details about each scan's results to a set of files locally
  
    --threads=<num>		Set number of threads to use downloading scan results

After the program has run successfully, you will find a directory called “details” created under your current working directory under which the scan details will be archived.

If you have a large environment or a high scan frequency, consider using the --starting= and --ending= variables to reduce your memory consumption while running this tool.

To retrieve and archive scan data since, say January 1 of 2015, use the following command:
$./archiveScanData.rb --auth=/opt/halo/scanData.auth --threads=30 --detailsfiles --starting=2015-01-01

<!---
#CPTAGS:community-supported archive
#TBICON:images/ruby_icon.png
-->
