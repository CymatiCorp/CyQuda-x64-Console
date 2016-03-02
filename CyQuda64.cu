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

#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>

#pragma comment (lib, "Ws2_32.lib")
#include "CyQu_bridge.h"

#define DEFAULT_BUFLEN 512
#define DEFAULT_PORT "12008"

using namespace std;

void CySend(SOCKET ClientSocket, string cyData) {
	cyData = cyData + "\n";
	char *sendData;
	sendData = new char[cyData.size() + 1];
    memcpy(sendData, cyData.c_str(), cyData.size() + 1);

    int iSendResult; 
	iSendResult = send(ClientSocket,  sendData, cyData.size(), 0);
			
	        // iSendResult = send( ClientSocket, recvbuf, iResult, 0 );
            if (iSendResult == SOCKET_ERROR) {
                cout << "Send Failure: " << WSAGetLastError();
                closesocket(ClientSocket);
                WSACleanup();
                return;
            }
 return;			
}

int __cdecl init_Server(void) 
{
	
	int CQ_success;
    int iResult;

	WSADATA wsaData;
	SOCKET ListenSocket = INVALID_SOCKET;
    SOCKET ClientSocket = INVALID_SOCKET;

	struct addrinfo *result = NULL;
    struct addrinfo hints;

    std::vector<char> myRecv;
    
	char recvbuf[DEFAULT_BUFLEN];
    int recvbuflen = DEFAULT_BUFLEN;
    
    // Initialize Winsock
    iResult = WSAStartup(MAKEWORD(2,2), &wsaData);
    if (iResult != 0) {
        printf("WSAStartup failed with error: %d\n", iResult);
        return 1;
    }

    ZeroMemory(&hints, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;
    hints.ai_flags = AI_PASSIVE;

    // Resolve the server address and port
    iResult = getaddrinfo(NULL, DEFAULT_PORT, &hints, &result);
    if ( iResult != 0 ) {
        printf("getaddrinfo failed with error: %d\n", iResult);
        WSACleanup();
        return 1;
    }

    // Create a SOCKET for connecting to server
    ListenSocket = socket(result->ai_family, result->ai_socktype, result->ai_protocol);
    if (ListenSocket == INVALID_SOCKET) {
        printf("socket failed with error: %ld\n", WSAGetLastError());
        freeaddrinfo(result);
        WSACleanup();
        return 1;
    }

    // Setup the TCP listening socket
    iResult = bind( ListenSocket, result->ai_addr, (int)result->ai_addrlen);
    if (iResult == SOCKET_ERROR) {
        printf("bind failed with error: %d\n", WSAGetLastError());
        freeaddrinfo(result);
        closesocket(ListenSocket);
        WSACleanup();
        return 1;
    }

    freeaddrinfo(result);

    iResult = listen(ListenSocket, SOMAXCONN);
    if (iResult == SOCKET_ERROR) {
        printf("listen failed with error: %d\n", WSAGetLastError());
        closesocket(ListenSocket);
        WSACleanup();
        return 1;
    }

    // Accept a client socket
    ClientSocket = accept(ListenSocket, NULL, NULL);
    if (ClientSocket == INVALID_SOCKET) {
        printf("accept failed with error: %d\n", WSAGetLastError());
        closesocket(ListenSocket);
        WSACleanup();
        return 1;
    }

    // No longer need server socket
    closesocket(ListenSocket);

    // Receive until the peer shuts down the connection
    do {

        iResult = recv(ClientSocket, recvbuf, recvbuflen, 0);
        if (iResult > 0) {
			
			std::vector<char> vec(recvbuf, recvbuf + iResult);
			std::string myRecv(vec.begin(), vec.end());

			// END                       - Terminates connection and program. 
			if (myRecv == "END\r\n") { 
	
			CyQu_EXIT(ClientSocket);

			}

			std::cout << myRecv;
		    char split_char = ' ';
            std::istringstream split(myRecv);
            std::vector<std::string> myCmd2;

            for (std::string each; std::getline(split, each, split_char); myCmd2.push_back(each));

		

			if (myCmd2.size() < 2) {
				
			 myRecv = "";
			 myCmd2.resize(0);
			 continue;
			} 

			// ADD     [TABLE] [DATA]    - Adds [DATA] to [TABLE] where [DATA] is in 1.1.1 format 
			if (myCmd2[0] == "ADD") { 
	
			CQ_success = CyQu_ADD(ClientSocket, myCmd2[1]);

			}

			// GET     [TABLE] [INDEX]   - Retrieves "1.2.3" string of data by [INDEX] starting with integer 1 in the order added.
	     	if (myCmd2[0] == "GET") { 
	
				CQ_success = CyQu_GET(ClientSocket, myCmd2[1]);

				if (CQ_success == 0) {
				 cout << "\n Out of Range \n"; 
				 CySend(ClientSocket, "CY: OUT OF RANGE");
				}

			}
			
			// UPDATE  [TABLE]           - Refreshes [TABLE] arrays in GPU memory, that was inserted by ADD.
			if (myCmd2[0] == "UPDATE") {
			 
			}

			if (myCmd2[0] == "FIND") {
		     CQ_success = CyQu_FIND(ClientSocket, myCmd2[1]);
			}
			
			if (myCmd2[0] == "CLEAR") {
			 CySend(ClientSocket, "Database Cleared");
		     CQ_success = CyQu_CLEAR(ClientSocket);
			}

			// Programmers Notes:
			// Using   [TABLE] will probably require use of a 2d array and &pointer setup to reference it.
			//          where [TABLE] is likely defined as an integer index. For now, we will stick to a
			//          flat array for proof of concept.

			// MAKE    [TABLE] 
			// ADD     [TABLE] [DATA]         - Adds [DATA] to [TABLE] where [DATA] is in 1.1.1 format 
            // GET     [TABLE] [INDEX]        - Retrieves "1.2.3" string of data by [INDEX] starting with integer 1 in the order added.
			// UPDATE  [TABLE]                - Refreshes [TABLE] arrays in GPU memory, that was inserted by ADD.
			// FIND    [TABLE] [DATA]         - Searches for [DATA] 1.1.1 which is converted to CPU array, and sent to GPU memory.
			// STOP    [TABLE] [SEARCH_INDEX] - Stops searching for [DATA] in the provided [SEARCH_INDEX] 
			// FREE    [TABLE]                - Frees up [TABLE] array from local memory and GPU memory.
			// ACTIVE                         - Outputs all active search indexes in form of 
			//                                   :ACTIVE_TOTAL [TOTAL_ACTIVE_SEARCHES] 
			//                                   :ACTIVE       [SEARCH_INDEX] [SEARCH_ARRAY_STRING] [TOTAL_FOUND_RESULTS]
			// 
			// SAVE    [TABLE] [FILE]    - Saves [TABLE] and outputs [TABLE] and [FILE] saved to.
			// LOAD    [TABLE] [FILE]    - Loads [TABLE] and outputs [TABLE] and [FILE] loaded from.
			// END                       - Terminates connection and program. 


        }
        else if (iResult == 0)
            printf("Connection closing...\n");
        else  {
            printf("recv failed with error: %d\n", WSAGetLastError());
            closesocket(ClientSocket);
            WSACleanup();
            return 1;
        }

    } while (iResult > 0);

    // shutdown the connection since we're done
    iResult = shutdown(ClientSocket, SD_SEND);
    if (iResult == SOCKET_ERROR) {
        printf("shutdown failed with error: %d\n", WSAGetLastError());
        closesocket(ClientSocket);
        WSACleanup();
        return 1;
    }

    // cleanup
    closesocket(ClientSocket);
    WSACleanup();

    return 0;
}


// Main Function.
int main(int argc, const char *argv[]) {
	
	init_Server();

	return 0;
	
}
