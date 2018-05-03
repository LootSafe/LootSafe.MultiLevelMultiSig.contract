const expectThrow = require('./helpers/expectThrow')

const MLMS = artifacts.require('MultiLevelMultiSig.sol')

const gasPrice = 6000029

contract('MultiLevelMultiSig', (accounts) => {
  it('should deploy', async () => {
    const instance = await MLMS.new(accounts[0])
    if (instance.address === undefined) throw new Error('deployment failed')
  })

  it('should create roles', async () => {
    const instance = await MLMS.new(accounts[0])
    await instance.createUpdateRole('moderator', 86400, 100000000000000000, 1, false)
    const moderator = await instance.getRole('moderator')
    if (moderator[3].toString() !== '1') throw new Error('role creation failed')
  })

  it('should list role info', async () => {
    const instance = await MLMS.new(accounts[0])
    await instance.createUpdateRole('moderator', 86400, 1000000000000000, 1, false)
    const moderator = await instance.getRole('moderator')
    if (moderator[3].toString() !== '1') throw new Error('error getting role info')
  })

  it('should promote members to a role', async () => {
    const instance = await MLMS.new(accounts[0])
    await instance.createUpdateRole('admin', 86400, 1000000000000000000, 0, true)
    await instance.assignRole(accounts[1], 'admin')
    const member = await instance.getMemberRole(accounts[1])
    if (member != '0x61646d696e000000000000000000000000000000000000000000000000000000') throw new Error('something went wrong promoting member')
  })

  it('should delete a role', async () => {
    const instance = await MLMS.new(accounts[0])
    await instance.createUpdateRole('admin', 86400, 10000000000000000, 0, true)
    await instance.deleteRole('admin')
    const role = await instance.getRole('admin')
    if (role[0] !== '0x0000000000000000000000000000000000000000000000000000000000000000') throw new Error('Role not deleted')
  })

  it('should demote member from role', async () => {
    const instance = await MLMS.new(accounts[0])
    await instance.createUpdateRole('admin', 86400, 10000000000000000, 0, true)
    await instance.assignRole(accounts[1], 'admin')
    await instance.removeRole(accounts[1])
    const member = await instance.getMemberRole(accounts[1])
    if (member !== '0x0000000000000000000000000000000000000000000000000000000000000000') throw new Error('User not demoted!')
  })

  it('should allow a member to create a request', async () => {
    const instance = await MLMS.new(accounts[0])
    await instance.createUpdateRole('admin', 86400, 1000000000000000000, 0, false)
    await instance.createUpdateRole('moderator', 86400, 1000000000000000000, 1, false)
    await instance.assignRole(accounts[1], 'admin')
    await instance.assignRole(accounts[2], 'moderator')
    await instance.request(1000000000000, {from: accounts[2]})
    const requests = await instance.getRequests()
    if (!requests[0]) throw new Error('Request not made!')
  })

  it('should allow a member to approve a lower ranking memebers request', async () => {
    const instance = await MLMS.new(accounts[0])
    await instance.send(10, { from: accounts[0] })
    await instance.createUpdateRole('admin', 86400, 1000000000000000000000, 0, false)
    await instance.createUpdateRole('moderator', 86400, 1000000000000000000, 1, false)
    await instance.assignRole(accounts[1], 'admin')
    await instance.assignRole(accounts[2], 'moderator')
    await instance.request(10, { from: accounts[2] })
    const requests = await instance.getRequests()
    await instance.approveRequest(requests[0], { from: accounts[1] })  
    const request = await instance.getRequest(requests[0]) 
    if (request[3].toString() !== '1') throw new Error('Request not set to accepted state, something went wrong')
    if (web3.eth.getBalance(instance.address).toNumber() != 0) throw new Error('Contract did not send out ether!')
  })

  it('should allow a member to be auto approved for a request', async () => {
    const instance = await MLMS.new(accounts[0])
    await instance.send(10, { from: accounts[0] })
    await instance.createUpdateRole('admin', 86400, 10000000000000000000000, 0, true)
    await instance.assignRole(accounts[1], 'admin')
    await instance.request(5, { from: accounts[1] })
    const requests = await instance.getRequests()
    const request = await instance.getRequest(requests[0])
    if (request[3].toString() !== '1') throw new Error('Request not moved to accepted state automatically')
    if (web3.eth.getBalance(instance.address).toNumber() !== 5) throw new Error('Expected contract balance to be 5')
  })

  it('should allow a member to deny a lower ranking members request', async () => {
    const instance = await MLMS.new(accounts[0])
    await instance.send(10, { from: accounts[0] })
    await instance.createUpdateRole('admin', 86400, 1000000000000000000000, 0, false)
    await instance.createUpdateRole('moderator', 86400, 1000000000000000000, 1, false)
    await instance.assignRole(accounts[1], 'admin')
    await instance.assignRole(accounts[2], 'moderator')
    await instance.request(5, { from: accounts[2] })
    const requests = await instance.getRequests()
    await instance.denyRequest(requests[0], { from: accounts[1] })
    const request = await instance.getRequest(requests[0])
    if (request[3].toString() !== '2') throw new Error('Request was expected to be denied, but is not')
  })

  it('should throw when trying to approve a request that is denied', async () => {
    const instance = await MLMS.new(accounts[0])
    await instance.send(10, { from: accounts[0] })
    await instance.createUpdateRole('admin', 86400, 1000000000000000000, 0, false)
    await instance.createUpdateRole('moderator', 86400, 10000000000000000, 1, false)
    await instance.assignRole(accounts[1], 'admin')
    await instance.assignRole(accounts[2], 'moderator')
    await instance.request(5, { from: accounts[2] })
    const requests = await instance.getRequests()
    await instance.denyRequest(requests[0], { from: accounts[1] })
    //expectThrow(instance.approveRequest(requests[0], { from: accounts[1] }))  
  })
  // Expect to throw trying to approve a denied request
  
  // Expect throw when double approving request

  // Expect multiple requets under the limit to be ok
  it('should allow multiple requets as long as the limit is not exceeded', async () => {
    const instance = await MLMS.new(accounts[0])
    await instance.send(10, { from: accounts[0] })
    await instance.createUpdateRole('admin', 86400, 1000000000000000000, 0, false)
    await instance.createUpdateRole('moderator', 86400, 10000000000000000, 1, false)
    await instance.assignRole(accounts[2], 'moderator')
    await instance.request(5, { from: accounts[2] })
    await instance.request(5, { from: accounts[2] })
    const requests = await instance.getRequests()
    if (requests.length !== 2) throw new Error('Did not create two requests!')
  })


  // Expect making a request over the limit to throw
  
})
