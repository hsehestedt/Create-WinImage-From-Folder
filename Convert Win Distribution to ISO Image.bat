@echo off
cd /d %~dp0

set LastUpdate=Sep 09, 2021

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: This script will convert a Windows distribution located in a folder into a bootable ISO image. ::
:: This is helpful if you are going to copy a Windows image to a disk, then modify files that are ::
:: located there or if you plan to add/remove/replace files there. When done, this will recreate  ::
:: the image for you with the updated files.                                                      ::
::                                                                                                ::
:: Written by Hannes Sehestedt                                                                    ::
:: Version 1.01                                                                                   ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::
:: User Definable Settings ::
:::::::::::::::::::::::::::::


set SkipIntro=0
set OSCDIMG_Location=C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg
set DestinationPath=
set DestinationFile=
set SourcePath=


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: IMPORTANT: If you leave any of the above user definable settings blank, make sure that you do not have any                 ::
::    trailing spaces after the "=" sign.                                                                                     ::
::                                                                                                                            ::
:: Below is a description of eache user definable setting above.                                                              ::
::                                                                                                                            ::
:: SkipIntro - When set to "0" the program will NOT skip the intro and will display the opening remarks to                    ::
::    familiarize the user with the program. This can be annoying once the user is aquinted with the                          ::
::    program. To skip this introductory remarks, change this setting to "1".                                                 ::
::                                                                                                                            ::
:: OSCDIMG_Location - If you installed the ADK with the default settings, then the OSCDIMG utility should be                  ::
::    located in "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg"        ::
::    If this is not the correct location, please change this to reflect the correct location. Note that the program will     ::
::    perform a check to verify that the file is indeed located there and will inform you if it is not.                       ::
::                                                                                                                            ::
:: DestinationPath - If DestinationPath is set to nothing (as it is by default), then the script will ask you where to save   ::
::    the image file. However, if you plan to use the same path repeatedly, then you can cahnge this value to that path and   ::
::    then the script will not ask you where to put it every time.                                                            ::
::                                                                                                                            ::
:: DestinationFile - Just as with the path, you can specify a filename if you plan to use the same name repeatedly. Otherwise ::
::    the script will ask you for this path.                                                                                  ::
::                                                                                                                            ::
:: SourcePath - This is the location where the Windows files that will be used to create the image are are located. As with   ::
::    the destination path and file, leave this blank to be asked for the location.                                           ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: If any of the paths or file names in the user defined strings above are enclosed in   ::
:: quotes or have a trailing backslash, we will get rid of those now. This process fails ::
:: if the string is blank so we will first check to see if it is blank.                  ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: If user entered a blank path, ask for a name again

if "%OSCDIMG_Location%"=="" (
goto Step2
)
set OSCDIMG_Location=%OSCDIMG_Location:"=%
if %OSCDIMG_Location:~-1%==\ set OSCDIMG_Location=%OSCDIMG_Location:~0,-1%

:Step2

if "%DestinationPath%"=="" (
goto Step3
)
set DestinationPath=%DestinationPath:"=%
if %DestinationPath:~-1%==\ set DestinationPath=%DestinationPath:~0,-1%

:Step3

if "%DestinationFile%"=="" (
goto Step4
)
set DestinationFile=%DestinationFile:"=%
if %DestinationFile:~-1%==\ set DestinationFile=%DestinationFile:~0,-1%

:Step4

if "%SourcePath%"=="" (
goto EndVarCheck
)
set SourcePath=%SourcePath:"=%
if %SourcePath:~-1%==\ set SourcePath=%SourcePath:~0,-1%

:EndVarCheck

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Display introductory remarks to user. If "SkipIntro" is set to "1", skip the intro. ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if %SkipIntro%==1 (
goto EndIntro
)

:Intro

cls
echo Create ISO Image from Windows Distribution in a Folder
echo by Hannes Sehestedt
echo Last updated %LastUpdate%
echo.
echo.
echo This script will take a Windows files that are located in a folder on a hard disk or other media
echo and create a bootable Windows ISO image from those files.
echo.
echo Please note that this script requires that the Windows ADK be installed. When installing the ADK,
echo the only option that needs to be installed is the "Deployment Tools".
echo.
echo If you have not done so already, please cancel this script, and open it in an editor such as Notepad.
echo Any editor that will not add formatting characters to the text is fine. Modify the user definable
echo settings at the top of the script under "User Definable Settings". A description of each of these
echo settings follows those settings explaining their purpose and how to set them.
echo.
pause

:EndIntro

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Verify that the OSCDIMG.EXE utility is located where we expect it to be. ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if NOT Exist "%OSCDIMG_Location%\oscdimg.exe" (
cls
echo We were not able to find the OSCDIMG.EXE file where we expected it to be. This file is a part of the Windows
echo ADK and is needed to create an ISO image file. The most likely causes for this error are:
echo.
echo 1 - The ADK was not installed.
echo     Corrective action: Install the ADK. Only the "Deployment Tools" are needed.
echo.
echo 2 - The ADK was installed to a different location than the usual default.
echo     Corrective action: Edit this batch file and change "OSCDIMG_Location" to reflect the correct location.
echo.
pause
goto END
)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Get the location of the Windows files from which we will create an ISO image. ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:GetSourcePath

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check to see if we have pre-specified a path using "SourcePath". ::
:: to save the final image. If so, don't ask for a path.            ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if "%SourcePath%" NEQ "" (
goto EndGetSourcePath
)

cls
echo Please provide the full path to the folder that contains the Windows files. 
echo.
set /p SourcePath="Path to Windows files: "

:: If user entered a blank path, ask for a name again

if "%SourcePath%"=="" (
goto GetSourcePath
)

:: If the user enters the path with quotes or trailing backslash, we will remove these now

set SourcePath=%SourcePath:"=%
if %SourcePath:~-1%==\ set SourcePath=%SourcePath:~0,-1%

:EndGetSourcePath

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Any valid Windows distribution should have a file named "bootmgr.efi" in the root of the distribution. ::
:: We're just going to check for the existance of such a file as a simple sanity check that the folder    ::
:: specified by the user is valid.                                                                        ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if NOT Exist %SourcePath%\bootmgr.efi (
cls
echo The location that you specified does not exist or does not hold valid Windows distribution files.
echo Please correct this situation and run the script again.
echo.
pause
goto END
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: If we arrive here, then the folder specified by the user has a file named "bootmgr.efi" and we are ::
:: making the assumption that this is a valid Windows distribution. We are proceeding normally.       ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check to see if we have pre-specified a path using "DestinationPath". ::
:: to save the final image. If so, don't ask for a path.                 ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if "%DestinationPath%" NEQ "" (
goto EndGetPath
)

:GetPath

cls
echo Where should we save the image that we are about to create? Please enter the full path to that location but do not
echo include a filename. Example: D:\My Windows Image
echo. 
set /p DestinationPath="Enter location where image should be created: "

:: If user entered a blank path, ask for a name again

if "%DestinationPath%"=="" (
goto GetPath
)

:: If the user enters the path with quotes or trailing backslash, we will remove these now

set DestinationPath=%DestinationPath:"=%
if %DestinationPath:~-1%==\ set DestinationPath=%DestinationPath:~0,-1%

:EndGetPath

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check to see if the path specified by the user already exists. If not, then we will attempt to ::
:: create that folder. We will then check again for the existance of the folder to see if we were ::
:: successful. If the folder still does not exist, warn the user.                                 ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if not exist "%DestinationPath%" (

:: If we arrive here then the folder specified by the user does not exist. We will now attempt to create that folder.
:: If the folder exists, skip to "DestinationExists".

MD "%DestinationPath%"
) else (
goto DestinationExists
)

:: We srrived here because the destination folder did not exist and we had to try to create it. We are
:: now going to check for the destination folder once more to see if we created it successfully.

if not exist "%DestinationPath%" (
cls
echo The path specified does not exist. We tried to create it but failed to do so.
echo Is it possible that you specified a bad drive letter?
echo.
echo Please correct the situation and then run this script again.
echo.
pause
goto END
)

:DestinationExists

:: We arrive here if the destination path exists

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: As with the destination path, check to see if a filename was pre-specified. If not, ask for the filename. ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if "%DestinationFile%" NEQ "" (
goto EndGetFile
)

:GetFile

cls
echo What would you like name the image? Specify a filename without a path or file extension. Example: Windows 10 20H1
echo.
set /p DestinationFile="Enter the name of the file to create without a path or file extension: "

:: If user entered a blank filename, ask for a name again

if "%DestinationFile%"=="" (
goto GetFile
)

:: If the user enters the path with quotes or trailing backslash, we will remove these now

set DestinationFile=%DestinationFile:"=%
if %DestinationFile:~-1%==\ set DestinationFile=%DestinationFile:~0,-1%

:EndGetFile

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: We arrive here once we have a filename. At this point we have ::
:: all the information we need. Time to create the final image.  ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

cls

echo ::::::::::::::::::::::::::::::
echo :: Creating the final image ::
echo ::::::::::::::::::::::::::::::
echo.

:: NOTE: If you prefer to hide the progress of the ISO image file creation, just add " > NUL 2>&1" (without the quotes)
:: at the end of the line below (after the last double quote mark).

"%OSCDIMG_Location%\oscdimg.exe" -m -o -u2 -udfver102 -bootdata:2#p0,e,b"%SourcePath%\boot\etfsboot.com"#pEF,e,b"%SourcePath%\efi\microsoft\boot\efisys.bin" "%SourcePath%" "%DestinationPath%\%DestinationFile%.iso"

:END
