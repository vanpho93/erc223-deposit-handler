pragma solidity 0.5.11;

contract ITokenRecipient {
    function tokenFallback(address from, uint value) public;
    function collect(address tokenAddress, uint value) public;
}

contract IToken {
    function balanceOf(address) public view returns (uint256);
    function transfer(address to, uint value) public;
}

contract IFactory {
    address payable public SAFE;
    function onReceiveToken(address tokenAddress, uint256 value) public; 
}

contract Ownable {
    address public owner;

    constructor() public {
      owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract Account is ITokenRecipient {
    address public ACCOUNT_FACTORY;

    constructor(address accountFactory) public {
        ACCOUNT_FACTORY = accountFactory;
    }
    
    function tokenFallback(address, uint256 value) public {
        collect(msg.sender, value);
    }

    function collect(address tokenAddress, uint256 value) public {
        IFactory(ACCOUNT_FACTORY).onReceiveToken(tokenAddress, value);
        IToken(tokenAddress).transfer(address(uint160(IFactory(ACCOUNT_FACTORY).SAFE())), value);
    }
}

contract Factory is Ownable {
    address payable public SAFE = ...;
    
    event Deposit(address bank, uint value, address coinAddress);
    event CreateAccount(address bank);
    mapping(address => bool) isValidAccount;

    function createAccounts(uint256 numberOfNewAccounts) public {
        for (uint256 index = 0; index < numberOfNewAccounts; index++) {
            address newAccountAddress = address(new Account(address(this)));
            isValidAccount[newAccountAddress] = true;
            emit CreateAccount(newAccountAddress);
        }
    }

    function onReceiveToken(address tokenAddress, uint256 value) public {
        require(isValidAccount[msg.sender]);
        emit Deposit(msg.sender, value, tokenAddress);
    }

    function setSafe(address payable newAddress) public onlyOwner {
        SAFE = newAddress;
    }
}
