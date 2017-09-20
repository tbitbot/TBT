pragma solidity ^0.4.11;

import './IERC20.sol'; 
import './SafeMath.sol';

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}


contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract ParentToken {

     /* library used for calculations */
    using SafeMath for uint256; 

    /* Public variables of the token */
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address=>uint)) allowance;        



    /* Initializes contract with initial supply tokens to the creator of the contract */
    function ParentToken(uint256 currentSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol){
            
       balances[msg.sender] =  currentSupply;    // Give the creator all initial tokens  
       totalSupply = currentSupply;              // Update total supply 
       name = tokenName;                         // Set the name for display purposes
       decimals = decimalUnits;                  // Decimals for the tokens
       symbol = tokenSymbol;					// Set the symbol for display purposes	
    }
    
    

   ///@notice Transfer tokens to the beneficiary account
   ///@param  to The beneficiary account
   ///@param  value The amount of tokens to be transfered  
       function transfer(address to, uint value) returns (bool success){
        require(
            balances[msg.sender] >= value 
            && value > 0 
            );
            balances[msg.sender] = balances[msg.sender].sub(value);    
            balances[to] = balances[to].add(value);
            return true;
    }
    
	///@notice Allow another contract to spend some tokens in your behalf
	///@param  spender The address authorized to spend 
	///@param  value The amount to be approved 
    function approve(address spender, uint256 value)
        returns (bool success) {
        allowance[msg.sender][spender] = value;
        return true;
    }

    ///@notice Approve and then communicate the approved contract in a single tx
	///@param  spender The address authorized to spend 
	///@param  value The amount to be approved 
    function approveAndCall(address spender, uint256 value, bytes extraData)
        returns (bool success) {    
        tokenRecipient recSpender = tokenRecipient(spender);
        if (approve(spender, value)) {
            recSpender.receiveApproval(msg.sender, value, this, extraData);
            return true;
        }
    }



   ///@notice Transfer tokens between accounts
   ///@param  from The benefactor/sender account.
   ///@param  to The beneficiary account
   ///@param  value The amount to be transfered  
    function transferFrom(address from, address to, uint value) returns (bool success){
        
        require(
            allowance[from][msg.sender] >= value
            &&balances[from] >= value
            && value > 0
            );
            
            balances[from] = balances[from].sub(value);
            balances[to] =  balances[to].add(value);
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
            return true;
        }
        
}
