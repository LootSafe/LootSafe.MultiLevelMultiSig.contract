# LootSafe.MultiLevelMultiSig.contract


# Usage

## Roles
Roles are descriptions of the members abilites within the contract. You can define the amount the member can withdrawal, how often the can withdrawal that amount (multiple smaller amounts within that time frame are also possible) as well as the level of the role.

### Description

#### Timelock
A timelock is how often a user can withdrawal, for instance with a timelock of one day, the user can withdrawal up to their limit within one day, as transactions become older than the timelock they can withdrwal more funds.

#### Limit
The limit is simply how much (in wei) the user can withdrawal within the timelock.

#### Level
The level comes into play when approving withdrawl requests. A member with a higher rank can approve withdrawls for lower ranking members. For example an `admin` role with a level of `0` can approve `moderator` roles with a level of `1`, `noob` roles with a level of `2` and so on.

### Creating & Managing roles




# Clearance Contract
```
roles(id => Role);
members(address => id);

Role {
  id: '0x0' // Id of the role
  name: 'Admin' // Human readable name of the role
  timelock: 123445 // Time before limit has been lifted
  limit: 10000000 // Amount in wei to limit per timelock
  level: 1 // ascending list of levels, e.g. level 1 can approve level 2, 3, 4, 5 requests
}

checkLimit
  Check if the user has pending withdrawls in last role.timelock
  check if withdrawl request + pendingWithdrawl exceeds role.limit
 
isSupervisor (address msg.sender, address requester)
  check if users role level is less than that of the role provided requester
  or if the sender is the owner of the contract
 
addMember(address, id) onlyOwner
  members[address] = id;
  
removeMember(address) onlyOwner
  delete members[address];
 
createUpdateRole (name, timelock, limit, level, id)
  create and update roles
  if id exists, update role, else generate id and create new role

deleteRole () onlyOwner
  remove a role
  
 ```
 
# Requests Contract

```
Request {
  requester: address // address of requester
  at: now, // Time of request
  amount: 1000000, // Amount in wei being requested for withdrawl
  status: 0,1,2 // pending, approved, denied
}

requestsById(id => Request);
requestsByRequester (address => bytes32[]);
requests[bytes32];

getRequests 
  return requests

getRequestsByRequester(address requester)
  return requestsByRequester[requester];
  
getRequestById (id)
  return requestsById[id]
   
makeRequest (requester, amount) {
  // ensure user has a role assigned
  // create request struct
  Request memory request = Request({
    requester: requester,
    at: now,
    amount: amount,
    status: 0
  })
  bytes32 id = // generate id somehow
  requestsById[id] = request;
  requestsByRequester[msg.sender].push(id);
  requests.push(id);
  
  // Request Event
}
  
```
 
# MultiLevelMultiSig Contract

```
is Clearance

constructor () {
  owner = msg.sender;
}

request (amount) {
  require(checkLimit(msg.sender, amount));
  makeRequest(msg.sender, amount);
}

approveRequest (id)
  Request storage request = requestsById[id];
  require(isSupervisor(msg.sender, request.requester)) // require superior role to requestor 
  require(request.status == 0); // require request to be pending
  // send request.amount to request.requester
  request.status = 1;
 
denyRequest (id)
  Request storage request = requestsById[id];
  require(isSupervisor(msg.sender, request.requester))
  require(request.status == 0); // require request to be pending
  request.status = 2;

```
