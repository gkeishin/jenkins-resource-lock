*** Settings ***

Documentation    Author: George Keishing   Version: JenkinsLRv1.0
...              This is a resource file utility to support
...              Jenkin resource reservation and releasing.
...              It contains the user defined keywords.

Library      String
Library      Collections
Library      Selenium2Library  timeout=10   run_on_failure=Nothing
Library      XvfbRobot
Library      SSHLibrary

Library      ../lib/jenkins_helper_lib.py
Resource     ../data/jenkins_setup_data.txt
Resource     run_test_suite.robot

*** Variables ***


*** Keywords ***

Launch Headless Browser
  [Documentation]    This keyword Launches in headless browser mode
  [Arguments]   ${url}
  Start Virtual Display    1920    1080
  Open Browser       ${url}
  Set Window Size    1920    1080


Count Resource Table Entries
  [Documentation]    Check the number of resource entries in the table.

  # Lets assume there is a MAX 1000 resource entry
  # The Jenkin resource entires in the table starts with index 2
  : FOR    ${INDEX}    IN RANGE    2   1000
  \  ${passed} =   Run Keyword And Return Status   Loop Through Table   ${INDEX}
  \  Run Keyword If  '${passed}' == 'False'    Exit For Loop

  # Substract the index offset 2 to get the exact count
  ${count} =    Evaluate    ${INDEX} - 2
  [return]   ${count}


Loop Through Table
  [Documentation]    Walk through the table row until out of index.
  [Arguments]    ${row}
  #-----------------------------------
  # Position
  #-----------------------------------
  #   1           2      3       4
  # Resource    Status  Labels  Action
  #-----------------------------------

  ${pos} =  Get Table Cell     ${CELL_TABLE_XPATH}    ${row}  1
  [return]   ${pos}


Lookup Resource Table Entries
  [Documentation]    Get the resource entries in the table matching string arg.
  [Arguments]    ${args}
  # If you are looking up a string in the page
  Page Should Contain   ${args}

  # Lets assume there is a MAX 1000 resource entry
  # The Jenkin resource entires in the table starts with index 2
  : FOR    ${INDEX}    IN RANGE    2   1000
  \  ${passed} =   Run Keyword And Return Status   Get Entry Row By Name   ${INDEX}  ${args}
  \  Run Keyword If  '${passed}' == 'True'    Exit For Loop

  # Substract the index offset 2 to get the exact count
  ${count} =    Evaluate    ${INDEX} - 2
  [return]   ${count}


Get Entry Row By Name
  [Documentation]    Walk through the table row and log
  [Arguments]    ${row}   ${args}
  #-----------------------------------
  # Position
  #-----------------------------------
  #   1           2      3       4
  # Resource    Status  Labels  Action
  #-----------------------------------

  Table Row Should Contain    ${CELL_TABLE_XPATH}    ${row}  ${args}
  [return]    ${row}


Reserve Target Entry
  [Documentation]   Lock the Targeted System
  [Arguments]    ${row}  
  Click Element      xpath=//button[@onclick='reserve_resource_${row}();']


Release Target Entry
  [Documentation]   Release the Targeted System
  [Arguments]    ${row}  
  Click Element      xpath=//button[@onclick='unreserve_resource_${row}();']


Release All Entries
  [Documentation]   Release the all Targeted System
  ${count} =  Count Resource Table Entries
  : FOR    ${INDEX}    IN RANGE    0   ${count}
  \   Run Keyword   Release Target Entry   ${INDEX}


Login and Execute Command
  [Documentation]   Login to system and execute command
  [Arguments]   ${ip_addr}   ${cmd}

  Open Connection   ${ip_addr}
  Login      ${USER_NAME}   ${PASS_WORD}
  ${out}  ${stderr}=    Execute Command  ${cmd}   return_stderr=True
  Should Be Empty     ${stderr}

  [return]    ${out}
