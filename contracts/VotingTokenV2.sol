// SPDX-License-Identifier: MIT
// su dung lib erc-20 cua Oppenzepllin
pragma solidity >= 0.8.12;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VotingTokenV2 is ERC20{
    mapping (address => uint256) public depositOf;

    constructor(  ) ERC20("ComunityToken v2" , "COMV2" ){

    }

    function deposit(  ) payable public {
        depositOf[msg.sender] += msg.value;
        //0.1eth = 1k token
        uint256 rate = 1000 * 10**18;
        uint256 totalTokenReceipt = (msg.value * rate) / ( 0.1*10**18 );
        _mint(msg.sender, totalTokenReceipt);
    } 

}
