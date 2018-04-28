pragma solidity ^0.4.18;

// TODO: Actions in this file should be multisig so owner cannot have total authority
contract Clearance is Owned {
    mapping (bytes32 => Role) roles;
    mapping (address => bytes32) members;
    
    struct Role {
        bytes32 id;         // ID of the role
        uint timelock;      // Length of time between 
        uint256 limit;      // Amount in wei role can withdrawl per timelock
        uint16 level;       // Ascending list of levels, e.g. level 1 can approve level 2, 3, ..., requests
        bool autoApprove;   // If true the role does not require approval (but is still bound to timelock and limit)
    }
    
    // Get role of member
    function getMemberRole(address member) public view returns (bytes32) {
        return members[member];
    }
    
    // Get role information
    function getRole(bytes32 id) public view returns (bytes32, uint, uint256, uint16) {
        Role memory role = roles[id];
        return (
            role.id,
            role.timelock,
            role.limit,
            role.level
        );
    }
    
    // Check that a member has the authority to authorize/deny a withdrawl
    function _isAuthorized(address _authorizor, address _requester) internal view returns (bool) {
        Role memory authorizor = roles[members[_authorizor]];
        Role memory requester = roles[members[_requester]];
        
        // Ensure authorizor has a higher ranking
        return (authorizor.level < requester.level);
    }
    
    // Create a new role, or overwrite existing role
    function createUpdateRole(bytes32 id, uint timelock, uint256 limit, uint16 level, bool autoApprove) external onlyOwner {
        roles[id] = Role({
            id: id,
            timelock: timelock,
            limit: limit,
            level: level,
            autoApprove: autoApprove
        });
    }

    // Delete a role from the system, members with this role lose all functionality
    function deleteRole(bytes32 id) external onlyOwner {
        delete roles[id];
    }
    
    // Assign a role to a member by address
    function assignRole(address member, bytes32 id) external onlyOwner {
        assert(roles[id].id != 0x00);
        members[member] = id;
    }
    
    // Remove a member from a role
    function removeRole(address member) external onlyOwner {
        delete members[member];
    }
}
