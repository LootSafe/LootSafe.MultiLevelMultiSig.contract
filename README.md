# LootSafe.MultiLevelMultiSig.contract

The Multi Level Multi Sig contract allows multisig through roles and daily limits. Members can withdraw only the alotted amount of Ether within the assigned timeframe. Roles can be assinged to approve requests to withdraw made by users. Although the user can create withdraw requests at any time, requests are first checked against the limit and timelock of the role a member is in. To futher ensure security you can force certain roles to require approval from higher ranking members, there is also of course the ability to just enforce withdraw limits per x amount of time through the timelock to speed up smaller spending from the wallet.

# Usage

## Roles

Roles are descriptions of the members abilites within the contract. You can define the amount the member can withdraw, how often the can withdraw that amount (multiple smaller amounts within that time frame are also possible) as well as the level of the role.

**Timelock** - A timelock is how often a user can withdraw, for instance with a timelock of one day, the user can withdraw up to their limit within one day, as transactions become older than the timelock they can withdrw more funds.

**Limit** - The limit is simply how much (in wei) the user can withdraw within the timelock.

**Level** - The level comes into play when approving withdraw requests. A member with a higher rank can approve withdraws for lower ranking members. For example an `admin` role with a level of `0` can approve `moderator` roles with a level of `1`, `noob` roles with a level of `2` and so on.

**AutoApprove** - If true users will not require approval from a higher ranking role, but will still be bound to the timelock and limit restrictions.

### Creating & Managing roles

#### Create or update a role

Create a new role within the contract, after creation the owner can apply the role to members. ROles can be updated by calling this function again.

```solidity
function createUpdateRole(bytes32 id, uint timelock, uint256 limit, uint16 level, bool autoApprove) external onlyOwner 
```

#### Delete a role

Delete a role from the contract, members who have this role assigned to them will be assumed to have no role after deletion.

```solidity
function deleteRole(bytes32 id) external onlyOwner
```

#### Assign a role

Assign a role to a user. Assigning a role gives the member the ability to withdraw as much and as often as defined by the role they are assigned.

```solidity
function assignRole(address member, bytes32 id) external onlyOwner
```

#### Remove a role from a member

Removing a role from a memeber will disallow all interaction with this contract by that member (unless they are the owner)

```solidity
 function removeRole(address member) external onlyOwner
 ```
 
| type | name | description |
|----- |----- |------------ |
|bytes32|id|Id of the role, e.g. `admin`|
|uint|timelock|The lenght of time in seconds before the withdrawl cap resets|
|uint256|limit|The amount in Wei the member can withdraw within this timelock|
|uint16|level|The rank of this role the lower the number the higher ranking this role is|
|bool|autoApprove|If true he role will not require approval for withdraws|
 
| method 	| parameters 	| description 	|
|--------	|------------	|-------------	|
|createUpdateRole |bytes32 id, uint timelock, uint256|             	|
|        	|            	|             	|
|        	|            	|             	|
 
 
