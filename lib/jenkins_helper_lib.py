#!/usr/bin/python
##############################################################
#    @file     jenkins_helper_lib.py
#    @brief    Helper Module to Robot Selenium framework
#
#    @author   George Keishing
#
#    @date     Jun 07, 2016
#
#    ----------------------------------------------------
#    @version  Developer      Date       Description
#    ----------------------------------------------------
#      1.0     gkeishin     06/07/16     Initial create
##############################################################

import os
import time
import re
import sys, subprocess
import os.path

# Initial helper class module for Robot lib call to this object
class  jenkins_helper_lib(object):

    ##########################################################################
    # Function : while_loop
    #
    # @param   : None
    # @return  : None 
    #
    # @brief    While 1 loop 
    #
    ##########################################################################
    def while_loop(self):
        while 1:
            pass

    ##########################################################################
    # Function : Is_File_Exist
    #
    # @param   : None
    # @return  : None
    #
    # @brief    File Exist
    #
    ##########################################################################
    def Is_File_Exist(self, i_fileExist):
        return os.path.isfile(i_fileExist)

    ##########################################################################
    # Function : Strip_date
    #
    # @param   i_str  : String input
    # @return  Returns the string back
    #
    # @brief   strip the start-end index and returns string.
    #
    ##########################################################################
    def Strip_date(self, i_string):
        return i_string[0:8]

    ##########################################################################
    # Function : while_loop
    #
    # @param   i_dir: Directory path 
    # @return  : None
    #
    # @brief     Robot framework doesnt have Change directory because some
    #            version of jython doesnt support it.
    #
    ##########################################################################
    def Change_Directory(self, i_dir):
        os.chdir(i_dir)

    ##########################################################################
    # Function : Get_File_info_From_Url
    #
    # @param   i_url       : BMC jenkins image URL path
    # @return  Returns the tar and the file size mentioned in the URL.
    #
    # @brief   Walk the page and get the <syste>-date.all.tar and MB size.
    #          Example : ['barreleye-20160609005744.all.tar', '32.00 MB']
    #
    ##########################################################################
    def Get_File_info_From_Url(self, i_url):
        cmd = 'wget  ' + i_url + ' -q -O -'
        cmd_out = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        output,error = cmd_out.communicate()

        pageStr = re.findall(r"<tr>(.*?)</tr>",str(output))

        # This is a list.. so find that entry having tar and MB in the HTML
        index = [i for i, elem in enumerate(pageStr) if ".all.tar" in elem]

        tableStr= pageStr[index[0]]
        # Grab the match containing the text tar file and size
        tarStr = re.findall(r".all.tar\">(.*?)</a>",str(tableStr))
        sizeStr = re.findall(r"fileSize\">(.*?)</td>",str(tableStr))

        #name_size_list = zip(tarStr,sizeStr)
        name_size_list = tarStr
        name_size_list.append(sizeStr[0])

        return name_size_list


    ##########################################################################
    # Function : Download_URL_File
    #
    # @param   i_url_file  : BMC jenkins image URL with tar name abs path
    # @return  Returns the size downloaded on the system/Local
    #
    # @brief   Get the file from URL using wget/continue method.
    #
    ##########################################################################
    def Download_URL_Tar_File(self, i_url_file):
        i_file_name = i_url_file.split('/')[-1]

        download_cmd ='wget  ' + i_url_file

        status = self.Execute_Download_Cmd(download_cmd)
        if status == "NOK":
            download_cont_cmd ='wget -c  ' + i_url_file
            # Can't do much post this continue failure...
            status_cont = self.Execute_Download_Cmd(download_cont_cmd)

        # Get File downloaded in MB size but return it a as string
        if os.path.isfile(i_file_name) == True:
            chmd_file='chmod 777  ' + i_file_name.strip()
            os.system(chmd_file)
            file_size = os.path.getsize(i_file_name.strip()) >> 20
        else:
            file_size="Download Failed"
        return  str(file_size)

    ##########################################################################
    # Function : Execute_Download_Cmd
    #
    # @param   i_cmd  : wget command to fetch file
    # @return  Returns OK on success
    #          Returns NOK incomplete download
    #          Returns FATAL on cmd failure or execptions
    #
    # @brief   Execute the command
    #
    ##########################################################################
    def Execute_Download_Cmd(self, i_cmd):
        print " Executing :",i_cmd

        try:
            cmd_out = subprocess.Popen(i_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
            output,error = cmd_out.communicate()
            if (len(error)>1):
               print "Error downloading:", error
               return "NOK"
            else:
               print "Download output \n", output
               # This would be in the log.html
        except:
            return  "FATAL"
        return "OK"

