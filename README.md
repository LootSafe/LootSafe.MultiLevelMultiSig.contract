# LootSafe.MultiLevelMultiSig.contract

# Role Contract
```
Role {
  id: '0x0' // Id of the role
  name: 'Admin' // Human readable name of the role
  timelock: 123445 // Time before limit has been lifted
  limit: 10000000 // Amount in wei to limit per timelock
  level: 1 // ascending list of levels, e.g. level 1 can approve level 2, 3, 4, 5 requests
}

canWithdrawl
  Check if the user has pending withdrawls in last role.timelock
  check if withdrawl request + pendingWithdrawl exceeds role.limit
 
canApprove (address msg.sender, address requester)
  check if users role level is less than that of the role provided requester
 
createUpdateRole (onlyOwner)
  create and update roles

deleteRole (onlyOwner)
  remove a role
  
 ```
 
