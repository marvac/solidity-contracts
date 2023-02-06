// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Factory {
    address[] public deployedCampaigns;

    function createCampaign(uint256 minContribution) public {
        address createdCampaign = address(
            new Campaign(minContribution, msg.sender)
        );
        
        deployedCampaigns.push(createdCampaign);
    }

    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint256 value;
        address payable recipient;
        bool complete;
        uint256 approvalCount;
        mapping(address => bool) approvals;
    }

    Request[] public requests;
    address public manager;
    uint256 public minimumContribution;
    mapping(address => bool) public approvers;
    uint256 public approversCount;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    constructor(uint256 minContribution, address creator) {
        manager = creator;
        minimumContribution = minContribution;
    }

    function contribute() public payable {
        require(msg.value >= minimumContribution);
        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(
        string memory description,
        uint256 value,
        address payable recipient
    ) public restricted {
        require(approvers[msg.sender]);
        uint256 _index = requests.length;
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

    function finalizeRequest(uint256 index) public restricted {
        Request storage request = requests[index];
        require(request.approvalCount > (approversCount / 2));
        require(!request.complete);

        request.recipient.transfer(request.value);
        request.complete = true;
    }
}
