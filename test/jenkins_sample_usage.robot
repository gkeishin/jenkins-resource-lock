*** Settings ***
Documentation     Author: George Keishing   Version: JenkinsLRv1.0
...               This is a sample example to use the code to login to
...               the jenkin resource page, reserve and release and test
...               a given system.
...               This example show you how to use the code.
...               Since this is an example the code is layed flat out.

# Main Jenkin support code base
Resource      ../src/jenkins_resource_keywords.robot

# Extended for Open Power code update and test
Resource      ../src/jenkins_obmc_download.robot

*** Test Cases ***

Login To Jenkins Resource
  [Documentation]   Login to Jenkin Resource page

  Should Not Be Empty   ${USER_NAME}
  Should Not Be Empty   ${PASS_WORD}
  Should Not Be Empty   ${JENKINS_URL}
  Should Not Be Empty   ${TARGET}

  # Using headless
  # You can use the browser directly here as well
  Launch Headless Browser   ${JENKINS_URL}

  Wait Until Element Is Visible    ${SUBMIT_XPATH}

                    # Locator               #input text
  Input Text        ${LOGIN_USER_XPATH}     ${USER_NAME}
  Input Text        ${LOGIN_PASSWD_XPATH}   ${PASS_WORD}
  Click Element     ${SUBMIT_XPATH}

  Page Should Contain    Lockable Resources


How Many Entries
  [Documentation]   Count resource added in the page

  ${count} =   Count Resource Table Entries
  Log To Console   ${count}


Find the Entry
  [Documentation]   Get the row containing resource in the page

  ${row} =  Lookup Resource Table Entries   ${TARGET}
  Log To Console   ${row}


Lock a Resource
  [Documentation]   Lock the entry by index

  ${row} =  Lookup Resource Table Entries   ${TARGET}
  Log To Console   ${row}
  Reserve Target Entry  ${row}

  # Set it for release example
  Set Suite Variable    ${ROW_INDEX}   ${row}


Ping Test server
  [Documentation]   Check if target can be accessed or responding

  Ping and wait For Reply  ${TARGET}

Connect and Get Driver build
  [Documentation]   Connect to system and execute command

  ${out} =   Login and Execute Command   ${TARGET}   cat /etc/version
  ${out} =   Strip Date  ${out}
  Log To Console   \n Build date: ${out}
  ${out} =   Login and Execute Command   ${TARGET}   cat /etc/os-release
  Log To Console   \n OS Release: ${out}


Look up Tar image
  [Documentation]   Fetch file info from URL page per system

  ${target_out} =   Login and Execute Command  ${TARGET}   hostname
  @{result} =   Run Keyword If  '${target_out}' == 'palmetto'     Fetch URL page   '${URL_PALMETTO}'
  ...   ELSE IF  '${target_out}' == 'barreleye'    Fetch URL page   ${URL_BARRELEYE}
  # IF downloaded , needs code update
  Set Suite Variable   ${TAR_IMAGE}  @{result}[0]

  # Set global to this test case so that i can be use in code update
  # [0] - file name [1] file size
  Log To Console   \n @{result}[0] 
  Log To Console   \n @{result}[1] 

  # Check ig current installed onto the system vs in URL are same,
  # if so ignore and fail
  ${out} =   Login and Execute Command   ${TARGET}   cat /etc/version
  ${out} =   Strip Date  ${out}
  ${diff} =  Get Regexp Matches   @{result}[0]   ${out}
  Run Keyword And Ignore Error  Should Not Be Empty   @{diff}[0]  msg=*** Image already Upto Date ***

  # If the file is already downloaded just skip downloading
  ${status} =  Run Keyword   Is File Exist   ${EXECDIR}${/}@{result}[0]
  Run Keyword If  ${status} == True    Fail   *** Image already downloaded ***

  Run Keyword If  '${target_out}' == 'palmetto'    Download BMC Tar image   ${URL_PALMETTO}   @{result}[0]
  Run Keyword If  '${target_out}' == 'barreleye'   Download BMC Tar image   ${URL_BARRELEYE}  @{result}[0]


Create Workspace Directory
  [Documentation]   Download and prepare the work space for code update and test case execution

  Log To Console    \n Fetching Test Suite and code update tool from Github
  Execute Command on Host   git clone https://github.com/openbmc/openbmc-test-automation
  Execute Command on Host   git clone https://github.com/causten/tools


Code Update system
  [Documentation]   Fire up the code update

  Variable Should Exist   ${TAR_IMAGE}  msg=Code update not required

  Log To Console    Code updating system
  ${out} =   Login and Execute Command   ${TARGET}   cat /etc/version
  ${out} =   Strip Date  ${out}

  Should Not Contain  ${TAR_IMAGE}  ${out}   msg="**Same image already Updated.. Skipping Code update **"  values=True

  Run Tests Test Suite     python tools/obmc/codeupdate.py -i ${TARGET} -u ${USER_NAME} -p ${PASS_WORD} -t bmc -f ${TAR_IMAGE}


Release a Resource
  [Documentation]   Release a Locked entry by index

  # Continuing above lock example, using saved off index row
  Variable Should Exist   ${ROW_INDEX}  msg=Indication that Reservation failed 
  Release Target Entry   ${ROW_INDEX}
  

*** Keywords ***

Download BMC Tar image
  [Documentation]   Download the file
  [Arguments]       ${url}   ${tar_file_version}

  ${URL_FILE} =    Catenate  SEPARATOR=   ${url}   ${tar_file_version}
  Log To Console   ${URL_FILE}
  Download File from URL   ${URL_FILE}

Execute Test on Target
  [Documentation]   Execute the test cases once code is updated

  ${target_out} =    Login and Execute Command    ${TARGET}   hostname
  Log To Console     Target : ${target_out}
  Change Directory   openbmc-automation

  # Execute a single test case
  Run Tests Test Suite   OPENBMC_HOST=${TARGET} tox -e ${target_out} -- -t "'Test Firmware Version'" tests/test_fw_version.robot

  # Execute a Entire test suite
  #Run Tests Test Suite  OPENBMC_HOST=${TARGET} tox -e ${target_out} -- tests

