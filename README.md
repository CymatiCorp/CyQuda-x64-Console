# CyQuda x64 (Console)
CUDA Query Tool for 64-bit Console application.

Commands.
=========
* Add 1.2.3<br>
  - Adds elements to the next index.<br><br>
* Delete 1 (Not implimented)<br>
  - Deletes index 1.<br><br>
* Request 1
  - Returns entry from index 1<br><br>
* Search 1.2 (Not implimented)<br>
   - Uses CUDA to find matches, from provided elements, <br>
       to elements in an index. Returns index and matches found in index.
* Exit <br>
   - Exits program.

```
      [TABLE] not yet implimented.

ADD     [TABLE] [DATA]         - Adds [DATA] to [TABLE] where [DATA] is in 1.1.1 format 
GET     [TABLE] [INDEX]        - Retrieves "1.2.3" string of data by [INDEX] starting with integer 1 in the order added.
UPDATE  [TABLE]                - Refreshes [TABLE] arrays in GPU memory, that was inserted by ADD.
FIND    [TABLE] [DATA]         - Searches for [DATA] 1.1.1 which is converted to CPU array, and sent to GPU memory.
STOP    [TABLE] [SEARCH_INDEX] - Stops searching for [DATA] in the provided [SEARCH_INDEX] 
FREE    [TABLE]                - Frees up [TABLE] array from local memory and GPU memory.	
ACTIVE                         - Outputs all active search indexes in form of 
			                                   :ACTIVE_TOTAL [TOTAL_ACTIVE_SEARCHES] 
			                                   :ACTIVE       [SEARCH_INDEX] [SEARCH_ARRAY_STRING] [TOTAL_FOUND_RESULTS]
			 
SAVE    [TABLE] [FILE]    - Saves [TABLE] and outputs [TABLE] and [FILE] saved to.
LOAD    [TABLE] [FILE]    - Loads [TABLE] and outputs [TABLE] and [FILE] loaded from.
END                       - Terminates connection and program. 
```

<br><br><br><br>
Compile Directions.<br><br>
===================

* Create New Project ...<br>
  - Installed > Templates > Visual C++ > Win32 > Win32 Console Application
  - Name: CyQuda64<BR><BR>
* Win32 Application Wizard
  - Console Application
  - Empty Project
  - Finish.<BR><BR>
* Right click project name in solution explorer (CyQuda64)
  - Build Customizations
  - Check CUDA 7.5 (.targets, .props) <br><br>
* Project > Properties > Configuration Properties
  - Click button "Configuration Manager"
  - Click drop-down "active solution platform" and click "< New >"
  - Set platform type to: x64, copy settings from Win32.
  - press OK
  - Click drop-down "active solution platform" again, and click "< Edit >"
  - Select Win32 and "Remove"
  - Examine Configuration Properties > Configuration and make sure Platform is set to "x64"
  - press OK
  

* Right click solution name (CyQuda64) 
  - Properties<br>
  - Configuration Properties > General
  - Set "Character Set" to  ``` Use Multi-Byte Character Set ```
  
*  Configuration Properties > VC++ Directories > Include Directories<br>
```
$(VCInstallDir)include;$(VCInstallDir)atlmfc\include;$(WindowsSDK_IncludePath);C:\ProgramData\NVIDIA Corporation\CUDA Samples\v7.5\common\inc\; 
```

Configuration Properties > VC++ Directories > Library Directories<br>
```
$(VCInstallDir)lib\amd64;$(VCInstallDir)atlmfc\lib\amd64;$(WindowsSDK_LibraryPath_x64);C:\ProgramData\NVIDIA Corporation\CUDA Samples\v7.5\common\lib\; 
```
<br><br>
Configuration Properties > Linker > General<br>
```
%(AdditionalLibraryDirectories);$(CudaToolkitLibDir);$(CUDA_LIB_PATH);C:\ProgramData\NVIDIA Corporation\CUDA Samples\v7.5\common\lib\; 
```
<br><br>
Configuration Properties > Linker > Input<br>
```
cudart.lib;kernel32.lib;user32.lib;gdi32.lib;winspool.lib;comdlg32.lib;advapi32.lib;shell32.lib;ole32.lib;oleaut32.lib;uuid.lib;odbc32.lib;odbccp32.lib;%(AdditionalDependencies) 
```
<br><br>
Configuration Properties > CUDA C/C++ > Common <br>
```
Target Machine Platform: 64-bit (--machine 64)
```
<br><br>

``` Notice that the 64-bit setup uses different include/library folders than you would use for 32-bit. ```

<br><br>

* Right click "Source Files"
  - Add new item ...
  - Nvidia CUDA 7.5 > Code > CUDA C/C++ File
  - Name: CyQuda64
  - Add.<br><br>

Copy code from CyQuda64.cu into file, (or import CyCuda64 from zip file.) <br><br>

* Compile and or Rebuild Solution.
