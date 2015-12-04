#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>
#include <assert.h>
#include <string>
#include <cuda_runtime.h>
#include <helper_functions.h>
#include <helper_cuda.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <iostream>
#include <vector>

//#include <thrust/host_vector.h>
//#include <thrust/device_vector.h>

/*
 TO DO
  1. Search Entries using CUDA.
   2. Load entries from file
    3. Use a socket layer to accept commands.

  For "search entries", to copy the Array from Host to Device 
  we will need to flatten the array 
    from [Row][Column] 
	  to [Row + Column*N]
 
  Decide between Array, Vector, or Thrust
  where each has its drawbacks and limitations.

 */

using namespace std;

//Initialize Variables.
int matrixIndex = 0;    // Initial matrix Index.
int searchIndex = 0;    // Initial search Index.

int matrixSize = 8000;  // Max argvbase Entries.
int searchSize = 10;    // Max Search Entries.
int resultSize = 20;    // Max Result Entries.

int selectIndex = 0;
int i = 0;

// Create Arrays.
vector<vector<int>> myMatrix;
vector<vector<int>> mySearch;
vector<vector<int>> myResults;


cudaError_t searchMatrix(int *searchResult, char *aMatrix, char *searchElement);
cudaError_t addMatrix(char *matrixArray);

// CUDA engine for searchMatrix function.
__global__ void searchMatrixKernel(int searchResult, char aMatrix , char searchElement)
{
// int x = threadIdx.x;

/* 
 int sI = 0;
 // Detect the first matching character
 if (myMatrix[matrixIndex][sI] == searchElement[0]) {
   // Loop through next keyword character
   for (int j=1; j< matrixIndex.size(); j++) {
     if (myMatrix[matrixIndex][sI] != searchElement[j])
       break;
     else
     // Store the first matching character to the result list
       searchResult[sI] = 1;
   }
  }
*/

}

/*
// Search helper Function.
cudaError_t searchMatrix(int * result, char *matrixargv, char *searchElements) 
{
	
 char *dev_argv = 0;
 char *dev_keyword = 0;
 int *dev_result = 0;
 
 cudaError_t cudaStatus;
 cudaStatus = cudaSetDevice(0);  // Choose which GPU to run on, change this on a multi-GPU system.

 if (cudaStatus != cudaSuccess) { fprintf(stderr, "cudaSetDevice failed! Do you have a CUDA-capable GPU installed? 0"); goto Error; }
 cudaStatus = cudaMalloc((void**)&dev_result, resultSize * sizeof(int));                                          // Allocate GPU buffers for result set.
 if (cudaStatus != cudaSuccess) {  fprintf(stderr, "cudaMalloc failed! 1 "); goto Error;  }
 cudaStatus = cudaMalloc((void**)&dev_argv, matrixSize * sizeof(char));                                           // Allocate GPU buffers for input argv set.
 if (cudaStatus != cudaSuccess) {  fprintf(stderr, "cudaMalloc failed! 2 ");  goto Error; }
 cudaStatus = cudaMalloc((void**)&dev_keyword, sizeof(*searchElements));                                        // Allocate GPU buffers for keyword.
 if (cudaStatus != cudaSuccess) { fprintf(stderr, "cudaMalloc failed! 3 "); goto Error; }
 cudaStatus = cudaMemcpy(dev_argv, matrixargv, matrixSize * sizeof(char), cudaMemcpyHostToDevice);                      // Copy input argv from host memory to GPU buffers.
 if (cudaStatus != cudaSuccess) { fprintf(stderr, "cudaMemcpy failed! 4 "); goto Error; }
 cudaStatus = cudaMemcpy(dev_keyword, searchElements, sizeof(*searchElements), cudaMemcpyHostToDevice);                // Copy keyword from host memory to GPU buffers.
 if (cudaStatus != cudaSuccess) { fprintf(stderr, "cudaMemcpy failed! 5 "); goto Error; }

 searchMatrixKernel<<<1, matrixSize>>>(dev_result, dev_argv, dev_keyword);                                      // Launch a search keyword kernel on the GPU with one thread for each element.
 cudaStatus = cudaDeviceSynchronize();                                                                         // cudaDeviceSynchronize waits for the kernel to finish, and returns any errors encountered during the launch.
 if (cudaStatus != cudaSuccess) { fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel! 6 \n", cudaStatus); goto Error; }
 cudaStatus = cudaMemcpy(result, dev_result, resultSize * sizeof(int), cudaMemcpyDeviceToHost);                  // Copy result from GPU buffer to host memory.
 if (cudaStatus != cudaSuccess) { fprintf(stderr, "cudaMemcpy failed! 7"); goto Error; }

Error:
 cudaFree(dev_result);
 cudaFree(dev_argv);
 cudaFree(dev_keyword);

 return cudaStatus;
}
*/

// Main Function.
int main(int argc, const char *argv[]) {
	
	std::string newArg;
    char *myOutput;
	myOutput = "";
	cout << "CyQuda-x64 1.0 (Console) \n\n";

getInput:
	newArg = "";
	cout << "> ";

	std::getline(std::cin, newArg);
	// Get Arguments.  std::vector<std::string> myArgs(argv, argv + argc);
	char split_char = ' ';
    std::istringstream split(newArg);
    std::vector<std::string> myCmd;
    for (std::string each; std::getline(split, each, split_char); myCmd.push_back(each));
    
	if (myCmd.size() == 0) { 
		cout << "usage:  CyQuda.exe Add/Request/Search/Exit \n\n";
		goto getInput;
	} 

	std::string my_Command = myCmd[0];

	if (my_Command == "Exit") { 
	    cout << "\n\n Exiting . . .\n\n";
		return 0;
	}
	
	if (myCmd.size() == 1) {
		if (my_Command == "Add") { cout << "\n\n Usage: Add 1.2.3 \n\n"; }
		if (my_Command == "Request") { cout << "\n\n Usage: Request 1 \n\n"; }
		if (my_Command == "Delete") { cout << "\n\n Usage: Delete 1 \n\n"; }
		if (my_Command == "Search") { cout << "\n\n Usage: Search 1.2.3 \n\n"; }
      goto getInput;
	}
	
    char split_char2 = '.';
    std::istringstream split2(myCmd[1]);
    std::vector<std::string> token;
    for (std::string each2; std::getline(split2, each2, split_char2); token.push_back(each2));
	
	// ================================== Add <Index Index ...>
	if (my_Command == "Add") {
	

     matrixIndex++;
	 if ((matrixIndex +1) > myMatrix.size()) { 
		 myMatrix.resize(myMatrix.size() + 1000);
	 }
	 myMatrix[matrixIndex].resize(token.size() + 1);
     // myMatrix.push_back(myRow);
     // myMatrix[matrixIndex].push_back(1);

	 cout << " - ";
	 for (i = 0; i < token.size(); i++) {
      myMatrix[matrixIndex][i] = atoi(token[i].c_str());
	 cout << token[i].c_str() << " ";
	 }
	 cout << "\n";
	 // sprintf(myOutput, "Index %d", matrixIndex);
	 
     goto getInput;
	}

	// ================================== Delete
	if (my_Command == "Delete") {
	 goto getInput;
	}

	// ================================== Request <Index>
	if (my_Command == "Request") {
        selectIndex = atoi(token[0].c_str());
		
		if (selectIndex > matrixIndex) {
			cout << "\n Out of Range \n"; 
			goto getInput;
		}
		if (selectIndex < 1) { 
			cout << "\n Out of Range \n"; 
			goto getInput;
		}
		cout << "\n Length: " << (myMatrix[selectIndex].size() -1) << "\n ";
	    cout << "\n ";
		for (i = 0; i < (myMatrix[selectIndex].size() -1); i++) {
   	     cout << myMatrix[selectIndex][i] << " "; 
		}

		cout << " \n";
	
		goto getInput;
	}
	
	// ================================== List	
	// = List active searches.
	if (my_Command == "List") {

	}

	// ================================== Search <element.element.element...> 
	// = Matches groups of elements from the token[x] array.  
    // =  returns "X <Search Index>" when completed.
	// =  Completed search indexes are re-used after completion.

    if (my_Command == "Search") {
	 if (matrixIndex == 0) { 
		 cout << "- No entries added. \n";
		 goto getInput;
	 }
	 
	 searchIndex++;
     mySearch[searchIndex].resize(token.size() + 1);
    
	 for (i = 0; i < token.size(); i++) {
      mySearch[searchIndex][i] = atoi(token[i].c_str());
	 }

   // Search Matrix (Not yet fully implimented.)
   //  cudaError_t cudaStatus = searchMatrix(myResults, myMatrix, mySearch);
   //  if (cudaStatus != cudaSuccess) { cout << "searchMatrix() failed! /n";  }

	 goto getInput;
	}

    // Load matrix array into CUDA memory.
	if (my_Command == "Matrix") { 

	}

	cout << "\n> ";
	goto getInput;

}
