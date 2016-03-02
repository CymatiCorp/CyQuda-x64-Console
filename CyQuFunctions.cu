#define WIN32_LEAN_AND_MEAN
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


#include "CyQu_bridge.h"

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

  * Do parallel searches of before.current.after words.
  * 128 messages per 8 word index 128*8=1024 , Y*X
   
  */

using namespace std;

static const signed int arraySpace = 64;
static const size_t mySize = arraySpace * sizeof(signed int);

//Initialize Variables.
int matrixIndex = -1;    // Initial matrix Index.
int searchIndex = 0;    // Initial search Index.

int matrixSize = 8000;  // Max argvbase Entries.
int searchSize = 10;    // Max Search Entries.
int resultSize = 20;    // Max Result Entries.

int selectIndex = 0;
int i = 0;

// Create Arrays.

signed int* myMatrix = (signed int*)malloc(mySize);
signed int *deviceMatrix;
vector<vector<int>> mySearch;
vector<int> myResults;

vector<vector<int>> *deviceSearch;
vector<vector<int>> *deviceResults;


__global__ void CyQu_Kernel(int* deviceMatrix) {

	// printf("Block XY [%d, %d] ", blockIdx.x, blockIdx.y);
	// printf("\n");
	// printf("Grid X [%d] ", gridDim.x);
	// printf("\n");
	 printf("Block XY [%d, %d] : Grid [%d] :  Thread XY [%d, %d] \n", blockIdx.x, blockIdx.y, gridDim.x, threadIdx.x, threadIdx.y);
	// printf("[%d][%d]\n",threadIdx.y,threadIdx.x);
	//if (threadIdx.y > matrixIndex) { return; }
	//int selector = threadIdx.x * threadIdx.y;
	for (int i = 0; i < 8; i++) {
    // printf("[%d] = [%d] \n",i, deviceMatrix[selector]);
	}
	// printf("\n");
	// printf("\n");
	/*
	int idx = threadIdx.x;
	int idy = threadIdx.y
	
	for (i = 0; i < 9; i++) {
       if (&deviceMatrix[idx][idy] == &deviceSearch[selectedIndex][i]) {
	    CySend(ClientSocket, "");
	   }

	}
*/     

}

int CyQu_CLEAR (SOCKET ClientSocket) {
	
    free(myMatrix);
	cudaFree(deviceMatrix);

	signed int* myMatrix = (signed int*)malloc(mySize);
    signed int *deviceMatrix;

	matrixIndex = -1;

	cout << "Matrix Cleared \n";
	
	return 1;
}

int CyQu_USAGE (SOCKET ClientSocket, string cyData) {
		if (cyData == "ADD") { cout << "\n\n Usage: ADD 1.2.3 \n\n"; }
		if (cyData == "GET") { cout << "\n\n Usage: GET 1 \n\n"; }
		if (cyData == "Delete") { cout << "\n\n Usage: Delete 1 \n\n"; }
		if (cyData == "Search") { cout << "\n\n Usage: Search 1.2.3 \n\n"; }
return 1;
}

int CyQu_ADD (SOCKET ClientSocket, string mycyData) {

	char split_char2 = '.';
    std::istringstream split2(mycyData);
    std::vector<std::string> token;
    for (std::string each2; std::getline(split2, each2, split_char2); token.push_back(each2));
	
     matrixIndex++;
	 
	 if (sizeof(myMatrix) < 1) { 
		 // myMatrix.resize(myMatrix.size() + 1000);

      
	  
	 }
	 // myMatrix[matrixIndex].resize(token.size() + 1);
	
	 for (i = 0; i < token.size(); i++) {
      myMatrix[(matrixIndex * 8 + i)] = atoi(token[i].c_str());
	 }
	
return 1;
}

//int CyQu_SEARCH (SOCKET ClientSocket, string mycyData) {

	
//return 1
//}

int CyQu_GET (SOCKET ClientSocket, string cyData) {
	
        selectIndex = atoi(cyData.c_str());

		if (selectIndex > matrixIndex) { return 0;	}

		if (selectIndex < 0) { 	return 0; }

		string myResult = "CY: ";

  	    printf("[%d]", selectIndex);

		for (i = 0; i < 8; i++) {
   	     myResult = myResult + " " + to_string(myMatrix[selectIndex * 8 + i]); 
		} 

		CySend(ClientSocket, myResult);

  return 1;
}

int CyQu_FIND (SOCKET ClientSocket, string mycyData) {

	if (matrixIndex == 0) { 
		 cout << "- Database Empty.\n";
		 return 0;
	 }

	if (mySearch.size() < 1) { 
		mySearch.resize(10); 
	}

	char split_char2 = '.';
    std::istringstream split2(mycyData);
    std::vector<std::string> token;
    for (std::string each2; std::getline(split2, each2, split_char2); token.push_back(each2));

	searchIndex = atoi(token[0].c_str());

	if (searchIndex >= searchSize) { 
		 cout << "- Search Index Out of Range. Use 0- \n" << (searchSize -1); 
		 return 0; 
	 }


     mySearch[searchIndex].resize((token.size() -1));
	
	 for (i = 1; i < (token.size() -1); i++) {
      mySearch[searchIndex][(i - 1)] = atoi(token[i].c_str());
	 }
     
	 cudaSetDevice(0);

	 //int deviceMatrixSize = sizeof(myMatrix) * sizeof(signed int);
	 cudaMalloc((void**)&deviceMatrix, mySize);
     
	 /*
	 int deviceSearchSize = mySearch.size() * sizeof(int);
	 cudaMalloc((void**)&deviceSearch, deviceSearchSize);
     cudaMemcpy(deviceSearch, &mySearch[0], deviceSearchSize, cudaMemcpyHostToDevice);
	 */

 	 //int deviceResultsSize = myResults.size() * sizeof(int);
	 //cudaMalloc((void**)&deviceResults, deviceResultsSize);
     //cudaMemcpy(deviceResults, &myResults[0], deviceResultsSize, cudaMemcpyHostToDevice);

	 for (int i = 0; i < 16; i++) {
      printf("[%d] = [%d] \n",i, myMatrix[i]);
	 }

	 cout << "Kernal>>> \n\n";
	 
	 dim3 dimGrid(1);
	 dim3 dimBlock(8, matrixIndex +1);

     cudaMemcpy(deviceMatrix, &myMatrix[0], mySize, cudaMemcpyHostToDevice);

	 CyQu_Kernel<<<dimGrid, dimBlock>>>(deviceMatrix);

	 return 1;
}



void CyQu_LOAD(SOCKET ClientSocket, string cyLoad) {

}

void CyQu_SAVE(SOCKET ClientSocket, string cySave) {

}

void CyQu_EXIT(SOCKET ClientSocket) {
        free(myMatrix);
	    cudaFree(deviceMatrix);

	    cout << "\n\n Exiting . . .\n\n";
		closesocket(ClientSocket);
        WSACleanup();
		exit(EXIT_WAIVED);
return;

}
