pragma solidity ^0.4.18;

contract Requests {
  mapping (bytes32 => Request) requestsById;
  mapping (address => bytes32[]) requestsByRequester;
  bytes32[] public requests;
    
  struct Request {
    bytes32 id;           // ID of request
    address requester;    // address of requester
    uint at;              // Time of request
    uint256 value;        // Amount in wei being requested for withdrawl
    uint16 status;        // pending, approved, denied
  }
    
  /** 
    * @notice Get all requests
    * @dev Return requests array
    * @return bytes32[] returns array of request ids
    */
  function getRequests () public view returns (bytes32[]) {
    return requests;
  }
    
  /**
    * @notice Get requests by requester address
    * @dev Get array of requests by member address
    * @param requester the address of the requester
    */
  function getRequestsByRequester (address requester) public view returns (bytes32[]) {
    return requestsByRequester[requester];
  }
    
  /**
    * @notice Get a specific request
    * @dev Get a request by id
    * @param id The ID of the request
    */
  function getRequest (bytes32 id) public view returns (address, uint, uint256, uint16) {
    Request memory request = requestsById[id];
    return ( 
      request.requester,
      request.at,
      request.value,
      request.status
    );
  }  
}
