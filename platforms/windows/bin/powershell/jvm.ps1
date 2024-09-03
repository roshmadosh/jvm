# Convenience variable to hold reference to location of primary jvm directory
$jvm = Resolve-Path ~\.jvm

#
# Prints a provided message to stderr and exits the script
#
# Arguments:
#    $1 = error message to be printed
#
function Exit-Error {
    Write-Error "$1"
    exit 1
}

#
# Attempts to install the specified version of Java using the provided link. If the
# specified version is already installed, it will not be reinstalled and the user
# will be notified. 
#
# Arguments:
#    $1 = version of Java to be downloaded
#    $2 = JDK download link (should provide a tarball)
#
function Install-JDK {
    $version = $args[0]
    $downloadLink = $args[1]
    $versionDir = "$jvm\installed-versions\open-jdk-$version"
    
    
    Write-Output "jvm: Attempting to install Java v$version..."
    
    if (Test-Path $versionDir) {
        Write-Output "jvm: Java $version is already installed! Type 'jvm use $version' to switch to it!"
    }
    else {
        try {
            $err = @()
            $zipped = "$jvm\tmp\openjdk-$version.zip"
            Write-Output "Collecting the archived information"
            Invoke-WebRequest $downloadLink -OutFile $zipped -EA SilentlyContinue -EV err 
            if ($err -gt 0) {
                Exit-Error "Failed to download JDK zip from $downloadLink! Aborting installation!"
            }
            Write-Output "Attempting to extract the archive"
		Expand-Archive -Path $zipped -DestinationPath "$jvm\tmp" -EA SilentlyContinue -EV err
            $extracted = (Get-ChildItem -Path "$jvm\tmp" -Directory -Filter *$version* | Select-Object -ExpandProperty FullName)
            if ($err -gt 0) {
                Exit-Error "Failed to unzip JDK tarball! Aborting installation!"
            }
        } catch {
            Write-Error "There was an issue resolving a parameter within the script. `nThis is normally caused by the archive module not being updated. `nRun Install-Module Microsoft.Powershell.Archive -Force in admin mode to resolve the issue. `nIf the issue does not subside, submit an issue to the GitHub Repository."
        	Write-Host $_
	  }
        Copy-Item -Recurse -Force $extracted $versionDir
        Remove-Item -Recurse -Force (Resolve-Path ~\.jvm\tmp\*)
        Write-Output "jvm: Java v$version installed!"
        
    }
}

#
# Attempts to change the currently used version of Java. If the targeted Java version
# is installed, then it will be used. If the targeted Java version is not installed,
# the user will be notified to install it first.
# 
# Arguments:
#    $1 = target version of Java to switch to
#
function Set-JDK {
    $version = $args[0]
    $currentDir = "$jvm\current"
    $desiredVersion = "$jvm\installed-versions\open-jdk-$version"
    if (Resolve-Path $desiredVersion) {
        Remove-Item -Recurse -Force "$currentDir\*"
        Copy-Item -Recurse -Force "$desiredVersion\*" "$currentDir\"
        Write-Output "jvm: Switched to Java v$version"
    }
    else {
        Write-Output "jvm: You do not appear to have Java v$version installed! Try running 'jvm install $version' first!"
    }
    
}

#
# Primary script logic
#
# Determines what command was given to the jvm invocation: install, use, uninstall, and if 
# none of these then usage information will be displayed.
# 
# Arguments:
#    $1 = provided command
#    $2 = specified Java version
#

$cmd = $args[0]
$javaVersion = $args[1]

switch ($cmd) {
    list {
        Write-Output "jvm: Listing installed Java versions..."
        Write-Output "jvm: Installed versions:"
        Get-ChildItem -Path "$jvm\installed-versions" -Directory | ForEach-Object {
            Write-Output "jvm:   $(Split-Path $_ -Leaf)"
        }
    }
    install {
        switch ($javaVersion) {
            latest {
                Install-JDK latest https://download.java.net/openjdk/jdk19/ri/openjdk-19+36_windows-x64_bin.zip
            }
            19 {
                Install-JDK 19 https://download.java.net/openjdk/jdk19/ri/openjdk-19+36_windows-x64_bin.zip
            }
            18 {
                Install-JDK 18 https://download.java.net/openjdk/jdk18/ri/openjdk-18+36_windows-x64_bin.zip
            }
            17 {
                Install-JDK 17 https://download.java.net/openjdk/jdk17/ri/openjdk-17+35_windows-x64_bin.zip
            }
            16 {
                Install-JDK 16 https://download.java.net/openjdk/jdk16/ri/openjdk-16+36_windows-x64_bin.zip
            }
            15 {
                Install-JDK 15 https://download.java.net/openjdk/jdk15/ri/openjdk-15+36_windows-x64_bin.zip
            }
            14 {
                Install-JDK 14 https://download.java.net/openjdk/jdk14/ri/openjdk-14+36_windows-x64_bin.zip
            }
            13 {
                Install-JDK 13 https://download.java.net/openjdk/jdk13/ri/openjdk-13+33_windows-x64_bin.zip
            }
            12 {
                Install-JDK 12 https://download.java.net/openjdk/jdk12/ri/openjdk-12+32_windows-x64_bin.zip
            }
            11 {
                Install-JDK 11 https://download.java.net/openjdk/jdk11/ri/openjdk-11+28_windows-x64_bin.zip
            }
            10 {
                # Seems to be an issue with getting 
                Write-Output "jvm: JDK 10 is not currently supported"
            }
            9 {
                Install-JDK 9 https://download.java.net/openjdk/jdk9/ri/jdk-9+181_windows-x64_ri.zip
            }
            8 {
                Install-JDK 8 https://download.java.net/openjdk/jdk8u42/ri/openjdk-8u42-b03-windows-i586-14_jul_2022.zip
            }
            { $_ -lt 8 } {
                Write-Output "jvm: No support for Java version 7 and below"
            }
            Default {
                Write-Output "jvm: Unknown version specified"
            }
        }
    }
    use {
        switch ($javaVersion) {
            latest {
                Set-JDK latest
            }
            19 {
                Set-JDK 19
            }
            18 {
                Set-JDK 18
            }
            17 {
                Set-JDK 17
            }
            16 {
                Set-JDK 16
            }
            15 {
                Set-JDK 15
            }
            14 {
                Set-JDK 14
            }
            13 {
                Set-JDK 13
            }
            12 {
                Set-JDK 12
            }
            11 {
                Set-JDK 11
            }
            10 {
                Set-JDK 10
            }
            9 {
                Set-JDK 9
            }
            8 {
                Set-JDK 8
            }
            { $_ -lt 8 } {
                Write-Output "jvm: No support for Java version 7 and below"
            }
            Default {
                Write-Output "jvm: Unknown version specified"
            }
        }
    }
    uninstall {
        switch ($javaVersion) {
            latest {
                Remove-Item -Recurse -Force "$jvm\installed-versions\open-jdk-latest"
            }
            { $_ -lt 20 -And $_ -gt 7} {
                Remove-Item -Recurse -Force "$jvm\installed-versions\open-jdk-$_"
            }
            { $_ -lt 8 } {
                Write-Output "jvm: No support for Java version 7 and below"
            }
            Default {
                Write-Output "jvm: Unknown version specified"
            }
        }
    }
    Default {
        Write-Output "usage: jvm [command] [version]`n`nCommands: use, list, install, uninstall"
    }
}
