
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeLock{

    event TokensLocked(address indexed user, uint256 amount, uint256 duration, uint256 releaseTime);
    event TokensReleased(address indexed user, uint256 amount);

    // Mapping to store users' token balances
    mapping(address => uint256) public balances;

    // Array to store token locks
    TokenLock[] public tokenLocks;

    bool public paused;

      // Struct to represent a token lock
    struct TokenLock {
        address user;
        uint256 amount;
        uint256 duration;
        uint256 releaseTime;
        bool released;
    }

    modifier notPaused() {
    require(!paused, "Contract is paused");
    _;
}

    function pause() public {
    require(!paused, "Already paused");
    paused = true;
}

function resume() public {
    require(paused, "Not paused");
    paused = false;
}


function lockTokens(uint256 amount, uint256 duration) public notPaused {
    require(amount > 0, "Amount must be greater than 0");
    require(balances[msg.sender] >= amount, "Insufficient balance");
    
    uint256 releaseTime = block.timestamp + duration;
    
    TokenLock memory newLock = TokenLock({
        user: msg.sender,
        amount: amount,
        duration: duration,
        releaseTime: releaseTime,
        released: false
    });
    
    tokenLocks.push(newLock);
    balances[msg.sender] -= amount;
    
    emit TokensLocked(msg.sender, amount, duration, releaseTime);
}

function getLockStatus(uint256 lockIndex) public view returns (bool isReleased, uint256 releaseTime) {
    require(lockIndex < tokenLocks.length, "Invalid lock index");
    TokenLock storage lock = tokenLocks[lockIndex];
    return (lock.released, lock.releaseTime);
}


function releaseTokens(uint256 lockIndex) public notPaused {
    require(lockIndex < tokenLocks.length, "Invalid lock index");
    TokenLock storage lock = tokenLocks[lockIndex];
    require(!lock.released, "Tokens have already been released");
    require(block.timestamp >= lock.releaseTime, "Release time has not been reached");
    
    balances[lock.user] += lock.amount;
    lock.released = true;
    
    emit TokensReleased(lock.user, lock.amount);
    
}

}

