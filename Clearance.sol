
// TODO: Actions in this file should be multisig so owner cannot have total authority
contract Clearance {
    roles(bytes32 => Role);
    members(address => bytes32);
    
    Role {
        bytes32 id;     // ID of the role
        uint timelock;  // Length of time between 
        uint256 limit;  // Amount in wei role can withdrawl per timelock
        uint16 level;   // Ascending list of levels, e.g. level 1 can approve level 2, 3, ..., requests
    }
    
    // Check that a member has the authority to authorize/deny a withdrawl
    _isAuthorized(address _authorizor, address _requester) internal view returns (bool) {
        Role memory authorizor = roles[members[_authorizor]];
        Role memory requester = roles[members[_requester]];
        
        // Ensure authorizor has a higher ranking
        return (authorizor.level < requester.level);
    }
    
    // Create a new role, or overwrite existing role
    createUpdateRole(bytes32 id, uint timelock, uint256 limit, uint16 level) external onlyOwner {
        roles[id] = Role({
            id: id,
            timelock: timelock,
            limit: limit,
            level: level
        });
    }

    // Delete a role from the system, members with this role lose all functionality
    deleteRole(bytes32 id) external onlyOwner {
        delete roles[id];
    }
    
    // Assign a role to a member by address
    assignRole(address member, bytes32 id) external onlyOwner {
        assert(roles[id].id != 0x00);
        members[member] = id;
    }
    
    // Remove a member from a role
    removeRole(address member) external onlyOwner {
        delete members[member];
    }
}
