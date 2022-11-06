pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dispenser is ReentrancyGuard, AccessControl {
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    address public validator;

    mapping(bytes32 => bool) public reward_nonces;
    mapping(bytes32 => bool) public task_nonces;

    event rewardedERC20(address user, uint256 value, string nonce, address token);
    event replenishedERC20(address user, uint256 value, string nonce, address token);

    constructor(address _validator) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(VALIDATOR_ROLE, ADMIN_ROLE);
        _setupRole(VALIDATOR_ROLE, _validator);
        validator = _validator;
    }

    function claimERC20(
        uint256 _value,
        string memory _nonce,
        address _token,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        bytes32 message = keccak256(
            abi.encodePacked(msg.sender, _value, _nonce, _token)
        );
        require(
            reward_nonces[message] == false,
            "Transaction was already processed"
        );
        require(
            hasRole(
                VALIDATOR_ROLE,
                message.toEthSignedMessageHash().recover(v, r, s)
            ),
            "Validator address is invalid"
        );
        IERC20(_token).safeTransfer(msg.sender, _value);
        reward_nonces[message] = true;
        emit rewardedERC20(msg.sender, _value, _nonce, _token);
    }

    function replenishERC20(
      uint256 _value,
      string memory _nonce,
      address _token,
      uint8 v,
      bytes32 r,
      bytes32 s
    ) external nonReentrant {
      bytes32 message = keccak256(
            abi.encodePacked(msg.sender, _value, _nonce, _token)
        );
        require(
            task_nonces[message] == false,
            "Transaction was already processed"
        );
        require(
            hasRole(
                VALIDATOR_ROLE,
                message.toEthSignedMessageHash().recover(v, r, s)
            ),
            "Validator address is invalid"
        );
        IERC20(_token).transferFrom(msg.sender, address(this), _value);
        task_nonces[message] = true;
        emit replenishedERC20(msg.sender, _value, _nonce, _token);
    }

    function changeValidator(address _newValidator)
        external
        onlyRole(ADMIN_ROLE)
    {
        revokeRole(VALIDATOR_ROLE, validator);
        grantRole(VALIDATOR_ROLE, _newValidator);
        validator = _newValidator;
    }
}