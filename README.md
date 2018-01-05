# README #

In this repository we will store files and instructions related to IDMoney ICO.

### Contents ###

* Smart Contract files of IDMoney to be deployed in Ethereum
* Version: 1.0

### Methodology ###
IDMoney is a smart coin that will be used associated with a local or national ID in order to provide additional layers of security to both users and investors.
In this context the ICO process will be limited to only registered investors and will have a cap amount so to avoid problems.

### ICO Status ###
1. NotICO status: In this status the contract is not able to receive investments.
2. ICO status: In this status the contract is able the receive investments from registered investors

### ICO Methodology ###
* The default status for the contract is NotICO
* The owner can initiate an ICO at any time, as long as the contract is in the NotICO state
* The owner can use the beginICO in order to put the contract in the ICO status so that the contract can accept investments.
* Before any investor can do any investment the owner have to include the investor address in the investor list (array included in the contract). To do so the owner can use the addICOInvestor function.
* Every investment that the contract receives is used to mint more tokens taking into account the exchange rate defined by the ICO (specified in the beginICO function)
* The owner can also mint more tokens using the mint function at any time regarding of the contract status but this functionality is not supposed to be used. 
* Any ICO can be stopped by the owner using the endICO function.
* Once any ICO is stopped the data can be retrieved using the getInvestorAddresses and the getInvestorsTotal functions.
* The investor and investment lists will be erased when initiating a new ICO.

### Dependencies ###

* This environment can be downloaded using Git with the appropiate access to any computer 
* Any change in these files must be tested in a test network before being deployed in Ethereum.
* It has been tested in truffle (node.js based tool) but there are other tools that can be used.

## Automatic Tests ##

To be able to use automatic test you must do the following.

* Install Node.js
* Install truffle globally from the command line, in this way: 'npm install -g truffle'.
* Install testrpc which is a development server for Ethereum, in order to do that you must write in the command line this: 'npm npm install -g ethereumjs-testrpc'
* To run tests you must run the testrpc server in one process and run 'truffle tests' in the command line in another process.
* This does a 'dummy' deploy of the contract in the testrpc and runs tests associated with the token and the ICO process.

## Copyright (c) 2018 IDMoney