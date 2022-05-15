// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract buyingContract{
    address payable public seller;
    address payable public buyer;
    uint public value;

    enum State {Created, Locked, Release, Inactive}
    State public state;

    constructor() payable {
        seller=payable(msg.sender);
        value=msg.value/2;
    }

    /// The function cannot be called at the current state
    error InvalidState();
    /// Only the buyer can call this function
    error OnlyBuyer();
    /// Only the seller can call this function
    error OnlySeller();

    modifier inState(State state_) {
        if (state != state_) {
            revert InvalidState();
        }
        _;
    }
        modifier onlyBuyer() {
        if (msg.sender!=buyer) {
            revert OnlyBuyer();
        }
        _;
    }
        modifier onlySeller() {
        if (msg.sender!=seller) {
            revert OnlySeller();
        }
        _;
    }
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    function confirmPurchase() external inState(State.Created) payable {
        require(msg.value==(value*2), "Please deposite 2x the price of product");
        buyer=payable(msg.sender);
        state = State.Locked;
    }
    function confirmReceived() external onlyBuyer inState(State.Locked) {
        state=State.Release;
        buyer.transfer(value);
    }
    function paySeller() external onlySeller inState(State.Release) payable {
        state=State.Inactive;
        seller.transfer(value*3);
    }
    function abort() external onlySeller inState(State.Created) payable {
        state=State.Inactive;
        seller.transfer(address(this).balance);
    }
}

