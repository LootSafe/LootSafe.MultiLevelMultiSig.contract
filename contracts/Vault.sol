pragma solidity ^0.4.18;

import "./Clearance.sol";
import "./Requests.sol";

contract Vault is Clearance, Requests {    
  event FundsReceived(uint value, address from);
  event RequestMade(bytes32 id, address requester, uint at, uint256 value);
  event RequestApproved(bytes32 id);
  event RequestDenied(bytes32 id);

  /** 
    * @notice Ensure member withdrawl limit isn't exceeded.
    * @dev requested withdrawal plus open and accepted withdrawals in past x time shouldn't exceed the roles limit
    * @param requester the address of the member making a withdrawl request
    * @param value the value of the new request
    * @return bool returns true if the limit is exceeded
    */
  function _isLimitExceeded (address requester, uint256 value) internal view returns (bool) {
    bytes32[] memory memberRequests = requestsByRequester[requester];
    Role memory memberRole = roles[members[requester]];
        
    uint256 withdrawsInTimelock = value;
        
    // Check for all open or accepted requests in the past timelock
    for (uint i = 0; i < memberRequests.length; i++) {
      Request memory memberRequest = requestsById[memberRequests[i]];
      if (now - memberRequest.at <= memberRole.timelock && memberRequest.status != 2) {
        withdrawsInTimelock = withdrawsInTimelock + memberRequest.value;
      }
    }
        
    return withdrawsInTimelock > memberRole.limit;
  }

  /**
    * @notice Request a withdrawal from the contract
    * @dev a member can request a withdrawal (or get auto approved) depending on thier current limit status
    * @param value the value of the request being submitted
    */
  function request (uint256 value) public {
    Role memory role = roles[members[msg.sender]];
    assert(!_isLimitExceeded(msg.sender, value));
    uint16 status = role.autoApprove ? 1 : 0;
    bytes32 id = keccak256(msg.sender, now, value, status);

    Request memory newRequest = Request({
      id: id,
      requester: msg.sender,
      at: now,
      value: value,
      status: role.autoApprove ? 1 : 0
    });
        
    requests.push(id);
    requestsByRequester[msg.sender].push(id);
    requestsById[id] = newRequest;
  
    RequestMade(id, msg.sender, now, value);

    if (role.autoApprove) {
      // TODO: keep track of pending requests, disallow requests when conract 
      // doesn't have enough ether to fulfill them
      RequestApproved(id);
      msg.sender.transfer(value);
    }
  }
  
  /**
    * @notice Approve a pending request within the system
    * @dev allows authorized members to approve requests of lower raking members
    * @param id the id of the request to approve
    */  
  function approveRequest (bytes32 id) external {
    Request storage selectedRequest = requestsById[id];
    assert(_isAuthorized(msg.sender, selectedRequest.requester));
    selectedRequest.status = 1;
    selectedRequest.requester.transfer(selectedRequest.value);
    RequestApproved(id);
  }
  
  /**
    * @notice Deny a pending request within the system
    * @dev allows authorized members to deny requests of lower ranking members
    * @param id the id of the request to deny
    */  
  function denyRequest (bytes32 id) external {
    Request storage selectedRequest = requestsById[id];
    assert(_isAuthorized(msg.sender, selectedRequest.requester));    
    selectedRequest.status = 2;
    RequestDenied(id);
  }
    
  /** 
    * @notice Seal the contract roles as is, no new roles can be created, or assigned
    * @dev this irreversibly sets owner to 0x0, locking all onlyOwner functions
    */
  function seal() public onlyOwner {
    owner = 0x0;
  }

  /**
    * @notice Will accept any Ether sent to the contract
    */
  function () external payable {
    FundsReceived(msg.value, msg.sender);
  }
}
