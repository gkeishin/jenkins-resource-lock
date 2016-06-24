---------------------
INTRODUCTION
---------------------

This is a robot selenium code with extra python code as supporting library.

This code would work only -IF- the systems or resources are managed using Jenkins Lockable Resources plugins.

This is not availble as package but as a bare code to access Jenkin resource, lock it, do code update, test and release on completion.

The code update and testing would only work if it is for Open Power project.


---------------------
HOW TO USE
---------------------

From your code, import the main source code as

*** Settings *****
Resource     ../src/jenkins_resource_keywords.robot


and you can use those modules user define keyword to do the work.

This is still a very basic setup module.

To Execute :

   robot -v TARGET:<IP/string>  <your_file>.robot 

   Define your own ${USER_NAME}  and ${PASS_WORD}  for jenkins and system you intend to use.
   Define your ${JENKINS_URL} and Open Power Jenkin build path in the data/ file section else use -v  option to pass directly on to you test framework.

---------------------
USING THE CODE
---------------------

Update the info in ../data/jenkins_setup_data.txt
                -OR-
use python -m robot -v USER_NAME:<user name >  -v PASS_WORD:<Secrete password> -v JENKINS_URL:http://<to your login page url>   my_test.robot

# Test ENV mandatory variables
# Update your own Jenkin user and password, just to keep things simpler
# Keep the credential same as that of system, else change in the code
# accordingly
${USER_NAME}    <User login>
${PASS_WORD}    <Secrete password>

# Web URL address to Login page
# This is the URL link to login page for test, you should update your own
# stuff here
${JENKINS_URL}    http://<to your login page url>

# Open Power Jenkin image page
# This is jenkin page where the image of the build is generated.
${URL_BARRELEYE}   https://<URL page to your Jenkins build page>
${URL_PALMETTO}    https://<URL page to your Jenkins build page>

