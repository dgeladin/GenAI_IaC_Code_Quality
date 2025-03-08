# CHECKOV OUTPUT

## Version
Checkov Version: 3.2.382

## Documentation
[https://www.checkov.io/1.Welcome/Quick%20Start.html](https://www.checkov.io/1.Welcome/Quick%20Start.html)

## Directory Structure
Follows the outputs directory  
GenAI_Model / Scenario#

## Data Prep
The data will be analyzed so that the same check between checkov and tfsec are not reported twice. 

## Note
Checkov has the ability to download external modules to have a more comprehensive scan.  Since the point of this project is to examine the generated code only, download external modules is  disabled.  If another researcher wants to enable this, edit the generate_checkov_outputs.sh script and turn DOWNLOAD_EXTERNAL="true"

## Output
The output of checkov will be a json file. 

JSON file will be used to calculate the statistical analysis. 
