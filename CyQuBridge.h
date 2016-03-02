#ifndef CyQu_bridge_H    // To make sure you don't declare the function more than once by including the header multiple times.
#define CyQu_bridge_H
#define WIN32_LEAN_AND_MEAN
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>

#pragma comment (lib, "Ws2_32.lib")

int CyQu_USAGE (SOCKET ClientSocket, std::string cyData);
int CyQu_ADD (SOCKET ClientSocket, std::string cyData);
int CyQu_GET (SOCKET ClientSocket, std::string cyData);
int CyQu_FIND (SOCKET ClientSocket, std::string cyData);
void CyQu_LOAD(SOCKET ClientSocket, std::string cyLoad);
void CyQu_SAVE(SOCKET ClientSocket, std::string cySave);
void CyQu_EXIT (SOCKET ClientSocket);
int CyQu_CLEAR(SOCKET ClientSocket);

void CySend(SOCKET ClientSocket, std::string cyData);
#endif


