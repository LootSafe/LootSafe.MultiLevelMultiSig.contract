pragma solidity ^0.4.18;

import "./Ownable.sol";

contract Clearance is Ownable {
  mapping (bytes32 => Role) roles;
  mapping (address => bytes32) members;
    
  struct Role {
    bytes32 id;         // ID of the role
    uint timelock;      // Length of time between 
    uint256 limit;      // Amount in wei role can withdrawl per timelock
    uint16 level;       // Ascending list of levels, e.g. level 1 can approve level 2, 3, ..., requests
    bool autoApprove;   // If true the role does not require approval (but is still bound to timelock and limit)
  }
    
  /**
    * @noice Get role of a member
    * @dev Return the role id of an address
    * @param member The members address
    */
  function getMemberRole(address member) public view returns (bytes32) {
    return members[member];
  }
    
  /**
    * @notice Get role information
    * @dev Return role struct by id
    * @param id The id of the role
    */
  function getRole(bytes32 id) public view returns (bytes32, uint, uint256, uint16) {
    Role memory role = roles[id];
    return (
      role.id,
      role.timelock,
      role.limit,
      role.level
    );
  }
    
  /**
    * @notice Check that a member has the authority to authorize/deny a withdrawl
    * @dev Check that a member role has higher level role than requester
    * @param _authorizor The member attempting to authorize a request
    * @param _requester The member whom has submitted the request
    */
  function _isAuthorized(address _authorizor, address _requester) internal view returns (bool) {
    Role memory authorizor = roles[members[_authorizor]];
    Role memory requester = roles[members[_requester]];
    return (authorizor.level < requester.level);
  }
    
  /**
    * @notice Create a new role, or overwrite existing role
    * @dev Create a new role, or overwrite existing role
    * @param id The ID of the role to create or update (e.g. "admin")
    * @param timelock The amount of time before requests become expired and new requests can be made
    * @param limit The withdrawl value limit within the timelock
    * @param level The authority level of this role
    * @param autoApprove If true the role does not require approval for withdrawal requests
    */
  function createUpdateRole(bytes32 id, uint timelock, uint256 limit, uint16 level, bool autoApprove) external onlyOwner {
    roles[id] = Role({
      id: id,
      timelock: timelock,
      limit: limit,
      level: level,
      autoApprove: autoApprove
    });
  }

  /**
    * @notice Delete a role from the system, members with this role lose all functionality
    * @dev Delete a role by ID
    * @param id The ID of the role to delete
    */
  function deleteRole(bytes32 id) external onlyOwner {
    delete roles[id];
  }
    
  /**
    * @notice Assign a role to a member by address
    * @dev Assign a role to member address by id
    * @param member The address of the member to promote to a role
    * @param id The ID of the role to assign (e.g. "admin")
    */
  function assignRole(address member, bytes32 id) external onlyOwner {
    assert(roles[id].id != 0x00);
    members[member] = id;
  }
    
  /**
    * @notice Remove a member from a role
    * @dev Delete a member from the roles mapping
    * @param member The address of the member to remove from the system
    */
  function removeRole(address member) external onlyOwner {
    delete members[member];
  }
}
