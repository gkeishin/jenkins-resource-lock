*** Settings ***
Documentation     Author: George Keishing   Version: JenkinsLRv1.0
...               Triggers Test suite run 

Library           String
Library           OperatingSystem
Library           SSHLibrary
Library           Process

*** Keywords ***

# Both are kept same but will eventually evolve into different 
# task capabilities

Run Tests Test Suite
  [Documentation]    Run the full test suite uing tox
  [Arguments]   ${cmd}
  Run  ${cmd} 

Execute Command on Host
  [Documentation]    Execute command on the current host
  [Arguments]   ${cmd}
  Run   ${cmd}
