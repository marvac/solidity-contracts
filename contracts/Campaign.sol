// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Campaign {
    struct Request {
        string description;
        uint256 value;
        address recipient;
        bool complete;
        uint256 approvalCount;
        mapping(address => bool) approvals;
    }

    Request[] public requests;
    address public manager;
    uint256 public minimumContribution;
    mapping(address => bool) public approvers;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    constructor(uint256 minContribution) {
        manager = msg.sender;
        minimumContribution = minContribution;
    }

    function contribute() public payable {
        require(msg.value >= minimumContribution);
        approvers[msg.sender] = true;
    }

    function createRequest(
        string memory description,
        uint256 value,
        address recipient
    ) public restricted {
        require(approvers[msg.sender]);
        uint _index = requests.length;
        Request[] storage r = requests;
        r.push();
        r[_index].description = description;
        r[_index].value = value;
        r[_index].recipient = recipient;
        r[_index].complete = false;
        r[_index].approvalCount = 0;
    }

    function approveRequest(uint256 index) public {
        Request storage request = requests[index];
        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint index) public restricted{
        Request storage request = requests[index];
        require(!request.complete);
        request.complete = true;
    }
}
