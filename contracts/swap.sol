// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ownable {
    address private owner;
    event OwnershipTransfer(address indexed from, address indexed to); 
    modifier onlyowner (){
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address from, address to) external onlyowner{
        owner = to;
        emit OwnershipTransfer(from,to);
    }
    function Ownable() external returns (address){
        owner = msg.sender;
        return owner;
    }
    
}

contract Swap is ownable{
    using SafeMath for uint256;
    
    ERC20 mnitoken;
    uint256 public const;
    uint256 public totalmni;
    uint256 public totaleth;
    
    event TransferToken(address from, address to, uint256 amount);
    
    constructor(address token) payable{
        mnitoken = ERC20(token);
        totaleth = msg.value;
    }
    
    function initiateMNI(uint256 amount) external onlyowner{
        require(const == 0,"zero");
        require(mnitoken.balanceOf(msg.sender)!=0,"balance empty");
        // mnitoken.approve(address(this),amount);
        mnitoken.transferFrom(msg.sender,address(this),amount);
        totalmni=amount;
        const = totalmni.mul(totaleth);
        require(const>0);
    }
    function EthtoMni(uint256 mintoken,uint256 timestamp) payable external{
        require(msg.value!=0 && timestamp!=0,"zero ether sended");
        uint256 fee =msg.value/300;
        uint256 etherwithfee = msg.value.sub(fee);
        uint256 totalethtemp = etherwithfee.add(totaleth);
        uint256 totalmnitemp = const/totalethtemp;
        uint256 purchasedTokens = totalmni.sub(totalmnitemp);
        require(purchasedTokens>=mintoken,"mintoken not reached");
        require(block.timestamp < timestamp,"timeout");
        mnitoken.transfer(msg.sender,purchasedTokens);
        totalmni=totalmnitemp;
        totaleth=totalethtemp;
        emit TransferToken(address(this),msg.sender,purchasedTokens);
    }
    
    function MnitoEth(uint256 tokenSend, uint256 minEth ,  uint256 timestamp) payable external {
        require(tokenSend != 0 && timestamp!=0 ,"token are zero");
        uint256 fee = tokenSend/300;
        uint256 tokenSend_ = tokenSend.sub(fee);
        uint256 totalToken = tokenSend_.add(totalmni);
        uint256 totalEthToken = const/totalToken;
        uint256 purchasedEth = totaleth.sub(totalEthToken);
        require(purchasedEth >=minEth,"minEth not reached");
        require(block.timestamp < timestamp,"timeout");
        mnitoken.transferFrom(msg.sender,address(this),tokenSend);
        payable(msg.sender).transfer(purchasedEth);
        totaleth=totalEthToken;
        totalmni=totalToken;
        emit TransferToken(address(this),msg.sender,purchasedEth);
    }
    function OwnerdepositEth() public payable onlyowner{
        require(msg.value!=0,"Zero eth");
        totaleth=totaleth.add(msg.value);
        const = totaleth.mul(totalmni);
    }
    function OwnerdepositToken(uint256 tokens) public onlyowner{
        require(tokens!=0,"tokens are zero");
        mnitoken.transferFrom(msg.sender,address(this),tokens);
        totalmni=totalmni.add(tokens);
        const = totaleth.mul(totalmni);
    }
    function OwnerwithdrawEth(uint256 ethAmount) onlyowner public{
        require(ethAmount!=0, "eth amount is zero");
        require(ethAmount<=totaleth,"excess eth amount");
        payable(msg.sender).transfer(ethAmount);
        totaleth=totaleth.sub(ethAmount);
        const=totaleth.mul(totalmni);
    }
    function Ownerwithdrawtoken(uint256 tokens) public onlyowner{
        require(tokens!=0 && tokens<=totalmni,"tokens are low or high");
        mnitoken.transfer(msg.sender,tokens);
        totalmni=totalmni.sub(tokens);
        const=totalmni.mul(totaleth);
    }
} 