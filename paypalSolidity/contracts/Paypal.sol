// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Paypal {
	address public owner;

	constructor() {
		owner = msg.sender;
	}

	struct request {
		address payeeAddress;
		string payeeUserName;
		uint256 amount;
		uint256 requestTime;
		string message;
		address payerAddress;
	}

	struct transaction {
		string action;
		uint256 amount;
		string message;
		address myAddress;
		address yourAddress;
		string yourUserName;
		uint256 txnTime;
	}

	struct userName {
		string name;
		bool hasName;
	}

	mapping(address => userName) address2UserNameHashMap;
	mapping(address  => request[]) requestsHashMap;
	mapping(address  => transaction[]) txnHistoryHashMap;

	function modifyUserName(string memory _name) public {
		userName storage newUserName = address2UserNameHashMap[msg.sender];
		newUserName.name = _name;
		newUserName.hasName = true;
	}

	function createRequest(address _user, uint256 _amount, string memory _message) public {
		request memory newTxnRequest;
		newTxnRequest.payeeAddress = msg.sender;
		if (address2UserNameHashMap[msg.sender].hasName) {
			newTxnRequest.payeeUserName = address2UserNameHashMap[msg.sender].name;
		}
		newTxnRequest.amount = _amount;
		newTxnRequest.requestTime = block.timestamp;
		newTxnRequest.message = _message;
		newTxnRequest.payerAddress = _user;

		requestsHashMap[_user].push(newTxnRequest);
	}

	function payRequest(uint256 _request) public payable {
		require(_request < requestsHashMap[msg.sender].length, "No Such Request");
		request[] storage myRequests = requestsHashMap[msg.sender];
		request storage payableRequest = myRequests[_request];
		
		uint256 txnAmount = payableRequest.amount * 1000000000000000000;
		require(msg.value == (txnAmount), "Pay Correct Amount");
		
		payable(payableRequest.payeeAddress).transfer(msg.value);
		
		addHistory(msg.sender, payableRequest.payeeAddress, payableRequest.amount, payableRequest.message);
		
		myRequests[_request] = myRequests[myRequests.length - 1];
		myRequests.pop();
	}

	function addHistory(address payerAddress, address payeeAddress, 
						uint256 _amount, string memory _message) private {
		transaction memory debitTxn;
		debitTxn.action = "DEBIT";
		debitTxn.amount = _amount;
		debitTxn.message = _message;
		debitTxn.myAddress = payerAddress;
		debitTxn.yourAddress = payeeAddress;
		if (address2UserNameHashMap[payeeAddress].hasName) {
			debitTxn.yourUserName = address2UserNameHashMap[payeeAddress].name;
		}
		debitTxn.txnTime = block.timestamp;
		txnHistoryHashMap[payerAddress].push(debitTxn);
		
		transaction memory creditTxn;
		creditTxn.action = "CREDIT";
		creditTxn.amount = _amount;
		creditTxn.message = _message;
		creditTxn.myAddress = payeeAddress;
		creditTxn.yourAddress = payerAddress;
		if (address2UserNameHashMap[payerAddress].hasName) {
			creditTxn.yourUserName = address2UserNameHashMap[payerAddress].name;
		}
		creditTxn.txnTime = block.timestamp;
		txnHistoryHashMap[payeeAddress].push(creditTxn);
	}

	function rejectRequest(uint256 _request) public {
		require(_request < requestsHashMap[msg.sender].length, "No Such Request");
		request[] storage myRequests = requestsHashMap[msg.sender];
		myRequests[_request] = myRequests[myRequests.length - 1];
		myRequests.pop();
	}

	function getMyName(address _user) public view returns(userName memory) {
		return address2UserNameHashMap[_user];
	}

	function getMyRequests(address _user) public view returns (request[] memory) {
   		return requestsHashMap[_user];
	}

	function getMyTxnHistory(address _user) public view returns(transaction[] memory) {
		return txnHistoryHashMap[_user];
	}
}
