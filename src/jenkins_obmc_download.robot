*** Settings ***
Documentation     Author: George Keishing   Version: JenkinsLRv1.0
...               Triggers download image from URL

Library           String
Library           OperatingSystem
Library           ../lib/jenkins_helper_lib.py

*** Keywords ***

Fetch URL page
  [Documentation]    Run the full test suite uing tox
  [Arguments]   ${url}

  @{tar_file_info} =  Get File Info From Url   ${url} 
  [return]  @{tar_file_info}

Download File from URL
  [Documentation]    Run the full test suite uing tox
  [Arguments]   ${url}

  Download URL Tar File   ${url}

Ping and wait For Reply
  [Arguments]     ${ip_addr}

  # Runs the given command in the system and returns the RC and output
  # ping -c 5  ip  This means count for 5 instance of succcess and return
  ${rc}   ${output} =     Run and Return RC and Output     ping -c 5 ${ip_addr}
  Should be equal     ${rc}    ${0}   Ping To Server failed   values=${TRUE}
  Log To Console     Ping Test [ OK ]

