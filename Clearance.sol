
contract Clearance {
    roles(bytes32 => Role);
    members(address => bytes32);
    
    // TODO: Actions in this file should be multisig so owner cannot have total authority
    
    Role {
        bytes32 id;     // ID of the role
        uint timelock;  // Length of time between 
        uint256 limit;  // Amount in wei role can withdrawl per timelock
        uint16 level;   // Ascending list of levels, e.g. level 1 can approve level 2, 3, ..., requests
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
}
