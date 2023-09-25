// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Market{
    struct Item{
        string name;
        string description;
        uint price;
        address payable seller;
        bool available;
    }

    mapping (uint => Item) public items;
    uint itemCount;

    event ItemListed(uint256 itemId, string name, uint256 price, address seller);
    event OrderPlaced(uint256 itemId, address buyer);
    event TransactionCompleted(uint256 itemId, address buyer, address seller, uint256 price);

    constructor(){
        itemCount = 0;
    }

    function addItem(string memory _name, string memory _description, uint _price) public{
        itemCount++;
        Item storage newitem = items[itemCount];
        newitem.name = _name;
        newitem.description= _description;
        newitem.price = _price;
        newitem.seller = payable(msg.sender);
        newitem.available = true;

        emit ItemListed(itemCount, _name, _price, msg.sender);
    }

    function placeOrder(uint itemId) public payable{
        require (itemId > 0 && itemId <= itemCount, "Invalid ID");
        Item storage item = items[itemId];
        require (item.available, "Item not available");
        require (msg.value == item.price, "Insufficient Balance");
        item.available=false;
        emit OrderPlaced(itemId, msg.sender);
    } 

    function completeTransaction(uint itemId) public{
    require (itemId > 0 && itemId <= itemCount, "Invalid ID");
        Item storage item = items[itemId];
        require (!item.available, "Item is still available");
        require (msg.sender != item.seller, "Seller cannot perform this function");
        item.seller.transfer (item.price);

        emit TransactionCompleted(itemId, msg.sender, item.seller, item.price);
    }

    function getItem(uint256 _itemId) public view returns (string memory, string memory, uint256, address, bool) {
        require(_itemId > 0 && _itemId <= itemCount, "Invalid item ID");
        Item storage item = items[_itemId];
        
        return (item.name, item.description, item.price, item.seller, item.available);
    }
}