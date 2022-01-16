//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./libraries/SafeMath.sol";
import "./ownership/Ownable.sol";
import "./lifecycle/Pausable.sol";

contract BRLT is IERC20, Ownable, Pausable {
    using SafeMath for uint256;

    string internal _name = "BRL Token";
    string internal _symbol = "BRLT";
    uint8 internal _decimals = 2;
    uint256 internal _totalSupply = 0;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowed;

    event Mint(address indexed minter, address indexed account, uint256 amount);
    event Burn(address indexed burner, address indexed account, uint256 amount);

    constructor() {
        _balances[msg.sender] = _totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function transfer(address _to, uint256 _value)
        public
        override
        whenNotPaused
        returns (bool)
    {
        require(_to != address(0), "BRLT: to address is not valid");
        require(_value <= _balances[msg.sender], "BRLT: insufficient balance");

        _balances[msg.sender] = SafeMath.sub(_balances[msg.sender], _value);
        _balances[_to] = SafeMath.add(_balances[_to], _value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function balanceOf(address _owner)
        public
        view
        override
        returns (uint256 balance)
    {
        return _balances[_owner];
    }

    function approve(address _spender, uint256 _value)
        public
        override
        whenNotPaused
        returns (bool)
    {
        _allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override whenNotPaused returns (bool) {
        require(_from != address(0), "BRLT: from address is not valid");
        require(_to != address(0), "BRLT: to address is not valid");
        require(_value <= _balances[_from], "BRLT: insufficient balance");
        require(
            _value <= _allowed[_from][msg.sender],
            "BRLT: from not allowed"
        );

        _balances[_from] = SafeMath.sub(_balances[_from], _value);
        _balances[_to] = SafeMath.add(_balances[_to], _value);
        _allowed[_from][msg.sender] = SafeMath.sub(
            _allowed[_from][msg.sender],
            _value
        );

        emit Transfer(_from, _to, _value);

        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        override
        whenNotPaused
        returns (uint256)
    {
        return _allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint256 _addedValue)
        public
        whenNotPaused
        returns (bool)
    {
        _allowed[msg.sender][_spender] = SafeMath.add(
            _allowed[msg.sender][_spender],
            _addedValue
        );

        emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);

        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue)
        public
        whenNotPaused
        returns (bool)
    {
        uint256 oldValue = _allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {
            _allowed[msg.sender][_spender] = 0;
        } else {
            _allowed[msg.sender][_spender] = SafeMath.sub(
                oldValue,
                _subtractedValue
            );
        }

        emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);

        return true;
    }

    function mintTo(address _to, uint256 _amount)
        public
        whenNotPaused
        onlyOwner
    {
        require(_to != address(0), "BRLT: to address is not valid");
        require(_amount > 0, "BRLT: amount is not valid");

        _totalSupply = _totalSupply.add(_amount);
        _balances[_to] = _balances[_to].add(_amount);

        emit Mint(msg.sender, _to, _amount);
    }

    function burnFrom(address _from, uint256 _amount)
        public
        whenNotPaused
        onlyOwner
    {
        require(_from != address(0), "BRLT: from address is not valid");
        require(_balances[_from] >= _amount, "BRLT: insufficient balance");

        _balances[_from] = _balances[_from].sub(_amount);
        _totalSupply = _totalSupply.sub(_amount);

        emit Burn(msg.sender, _from, _amount);
    }
}
