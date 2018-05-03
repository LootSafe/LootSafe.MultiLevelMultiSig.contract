----

<img align="left" src="https://assets.entrepreneur.com/content/3x2/1300/20160112205229-sign-falling-ladder-brick-rock-bottom-person-danger-prevention.jpeg?width=750" data-canonical-src="https://assets.entrepreneur.com/content/3x2/1300/20160112205229-sign-falling-ladder-brick-rock-bottom-person-danger-prevention.jpeg?width=750" width="100"/>

### Woah there!
This contract has yet to be audited, before you go storing all your Ether here please have this contract audited, or wait for us to audit it.

----

# LootSafe.MultiLevelMultiSig.contract

The Multi Level Multi Sig contract allows multisig through roles and daily limits. Members can withdraw only the alotted amount of Ether within the assigned timeframe. Roles can be assinged to approve requests to withdraw made by users. Although the user can create withdraw requests at any time, requests are first checked against the limit and timelock of the role a member is in. To futher ensure security you can force certain roles to require approval from higher ranking members, there is also of course the ability to just enforce withdraw limits per x amount of time through the timelock to speed up smaller spending from the wallet.

----

<img align="left" src="https://d1u5p3l4wpay3k.cloudfront.net/zelda_gamepedia_en/f/f7/Navi_Art.png" data-canonical-src="https://d1u5p3l4wpay3k.cloudfront.net/zelda_gamepedia_en/f/f7/Navi_Art.png" width="150"/>

### Hey! Listen!!
This contract works best wrapped in our MultiSigCall contract unless you plan to use the freeze() method!

**How?** - Simply call the `transferOwnership` from the owner account and provied the call the address of your deployed MultiSigCall contract.

----

# Usage

## Roles

Roles are descriptions of the members abilites within the contract. You can define the amount the member can withdraw, how often the can withdraw that amount (multiple smaller amounts within that time frame are also possible) as well as the level of the role.

**Timelock** - A timelock is how often a user can withdraw, for instance with a timelock of one day, the user can withdraw up to their limit within one day, as transactions become older than the timelock they can withdrw more funds.

**Limit** - The limit is simply how much (in wei) the user can withdraw within the timelock.

**Level** - The level comes into play when approving withdraw requests. A member with a higher rank can approve withdraws for lower ranking members. For example an `admin` role with a level of `0` can approve `moderator` roles with a level of `1`, `noob` roles with a level of `2` and so on.

**AutoApprove** - If true users will not require approval from a higher ranking role, but will still be bound to the timelock and limit restrictions. It is highly reccomended that the highest level role (e.g. 0) has this flag set to true, else the highest level role will never be able to have their requests approved. (unless you're using the MultiSigCall contract)

### Creating & Managing roles

#### Create or update a role

Create a new role within the contract, after creation the owner can apply the role to members. ROles can be updated by calling this function again.

```solidity
function createUpdateRole(bytes32 id, uint timelock, uint256 limit, uint16 level, bool autoApprove) external onlyOwner 
```

| type | name | description |
|----- |----- |------------ |
|bytes32|id|Id of the role, e.g. `admin`|
|uint|timelock|The lenght of time in seconds before the withdrawl cap resets|
|uint256|limit|The amount in Wei the member can withdraw within this timelock|
|uint16|level|The rank of this role the lower the number the higher ranking this role is|
|bool|autoApprove|If true he role will not require approval for withdraws|

#### Delete a role

Delete a role from the contract, members who have this role assigned to them will be assumed to have no role after deletion.

```solidity
function deleteRole(bytes32 id) external onlyOwner
```
| type | name | description |
|----- |----- |------------ |
|bytes32|id|Id of the role, e.g. `admin`|

#### Assign a role

Assign a role to a user. Assigning a role gives the member the ability to withdraw as much and as often as defined by the role they are assigned.

```solidity
function assignRole(address member, bytes32 id) external onlyOwner
```
| type | name | description |
|----- |----- |------------ |
|address|member|The the member to assign this role to|
|bytes32|id|Id of the role, e.g. `admin`|

#### Remove a role from a member

Removing a role from a memeber will disallow all interaction with this contract by that member (unless they are the owner)

```solidity
 function removeRole(address member) external onlyOwner
 ```

| type | name | description |
|----- |----- |------------ |
|address|member|The the member to assign this role to|


## Requests

Requests can be made at any frequency and in any amount so long as the total value of the pending requets within the past x timelock do not exceed the limit set on the role. Some requets may be auto approved depending on your role however this does not mean a role can bypass the limit of the role within the timelock.

**ID** - The ID is a keccak256 of the requester, epoc timestamp of request, value, and status of the request.

**Requester** - The address of the member making the request

**At** - Timestamp of the request

**Value** - The value of the request in wei

**Status** - The status of the request (0 - pending, 1 - approved, 2 - denied)

#### Make a request

Making a request will create a request in the system, if your role has `autoApprove` enabled you will not require approval and will receive your withdraw request immediatly. Otherwise a higher ranking member must approve your request.

```solidity
 function request (uint256 value) public
 ```

| type | name | description |
|----- |----- |------------ |
|uint256|value|The amount in wei you'd like to withdraw|

#### Approve a request

Approving a request will set the status of the request to approved preventing any futher approvals or denials, in addition the value of this request will be transferred to the requester.

```solidity
 function approveRequest (bytes32 id) external
 ```

| type | name | description |
|----- |----- |------------ |
|bytes32|id|The ID of the request to approve|

#### Deny a request

Denying a request will set the status of the request to denied preventing any futher approvals or denials, in addition the value of this request will **NOT** be transferred to the requester.

```solidity
 function denyRequest (bytes32 id) external
 ```

| type | name | description |
|----- |----- |------------ |
|bytes32|id|The ID of the request to deny|

#### Get requests

List all requests in the system

```solidity
 function getRequests () public view returns (bytes32[])
```
 
#### Get a request by id

Returns all information about a request by id

```solidity
 function getRequest (bytes32 id) public view returns (address, uint, uint256, uint16)
 ```

| type | name | description |
|----- |----- |------------ |
|bytes32|id|The ID of the request to fetch|

#### Get a request by member

Returns all request ids filtered by member.

```solidity
 function getRequestsByRequester (address requester) public view returns (bytes32[])
 ```

| type | name | description |
|----- |----- |------------ |
|address|requester|The address to perform the request lookup on|
