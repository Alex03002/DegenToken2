// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {
    struct Item {
        uint256 id;
        string name;
        uint256 price;
    }

    mapping(uint256 => Item) public items;
    uint256 public itemCount;

    mapping(address => uint256[]) public redeemedItems;

    constructor() ERC20("Degen", "DGN") {
        items[1] = Item(1, "Yamato", 200);
        items[2] = Item(2, "Rebellion", 200);
        items[3] = Item(3, "Red Queen", 200);
        itemCount = 3;
    }

    function mintTokens(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function transferTokens(address _receiver, uint256 _value) external {
        require(balanceOf(msg.sender) >= _value, "You do not have enough Degen Tokens");
        approve(msg.sender, _value);
        transferFrom(msg.sender, _receiver, _value);
    }

    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }    
    
    function itemShop() public view returns (string memory) {
        string memory allItems = "Here are the available items: ";
        for (uint256 i = 1; i <= itemCount; i++) {
            Item memory item = items[i];
            allItems = string(abi.encodePacked(allItems, "ID: ", uint2str(item.id), ", Name: ", item.name, ", Price: ", uint2str(item.price), "\n"));
        }
        return allItems;
    }

    function redeemItems(uint256 itemId) external {
        Item memory item = items[itemId];
        require(balanceOf(msg.sender) >= item.price, "You do not have enough Degen Tokens");
        _burn(msg.sender, item.price);
        redeemedItems[msg.sender].push(itemId);
    }

    function itemInventory() external view returns (string[] memory) {
        uint256[] memory itemIds = redeemedItems[msg.sender];
        string[] memory itemNames = new string[](itemIds.length);
        for (uint256 i = 0; i < itemIds.length; i++) {
            itemNames[i] = items[itemIds[i]].name;
        }
        return itemNames;
    }

    function checkBalance() external view returns (uint256) { 
        return balanceOf(msg.sender); 
    }  

    function burnTokens(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "You cannot burn more than your current balance");
        _burn(msg.sender, amount);
    }

    function burnOther(address to, uint256 amount) public onlyOwner {
        require(balanceOf(to) >= amount, "You cannot burn more than the available balance");
        _burn(to, amount);
    }
}
