
/**
* Copyright 2017–2018, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.21;


import "solidity-shared-lib/contracts/Owned.sol";


/**
* @title Events History universal multi contract.
*
* Contract serves as an Events storage for any type of contracts.
* Events appear on this contract address but their definitions provided by calling contracts.
*
* Note: all the non constant functions return false instead of throwing in case if state change
* didn't happen yet.
*/
contract MultiEventsHistory is Owned {
    // Authorized calling contracts.
    mapping(address => bool) public isAuthorized;

    modifier onlyAuthorized {
        if (isAuthorized[msg.sender] || 
            msg.sender == contractOwner
        ) {
            _;
        }
    }

    /**
    * Authorize new caller contract.
    *
    * @param _caller address of the new caller.
    *
    * @return success.
    */
    function authorize(address _caller) 
    external
    onlyAuthorized 
    returns (bool) 
    {
        if (isAuthorized[_caller]) {
            return false;
        }
        isAuthorized[_caller] = true;
        return true;
    }

    /**
     * Reject access.
     *
     * @param _caller address of the caller.
     */
    function reject(address _caller) 
    external 
    onlyAuthorized 
    {
        delete isAuthorized[_caller];
    }

    /**
    * Event emitting fallback.
    *
    * Can be and only called by authorized caller.
    * Delegate calls back with provided msg.data to emit an event.
    *
    * Throws if call failed.
    */
    function () external {
        if (!isAuthorized[msg.sender]) {
            return;
        }
        // Internal Out Of Gas/Throw: revert this transaction too;
        // Recursive Call: safe, all changes already made.
        if (!msg.sender.delegatecall(msg.data)) {
            revert("[MultiEventsHistory] Cannot delegatecall to a sender");
        }
    }
}
