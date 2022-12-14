// SPDX-License-Identifier:MIT
// Contract created by Mohammed Rizwan

pragma solidity >=0.7.0 < 0.9.0;

contract RemotePurchase{
    uint public itemCost;
    address payable public seller;
    address payable public buyer;

    enum State{Created, Locked, Release, Inactive}
    State public state;

    constructor() payable {
        seller = payable (msg.sender);
        itemCost = msg.value / 2;
    }

    /// The function can not be called at the current state. 
    error InvalidState();

    /// Only the buyer can call this function.
    error OnlyBuyer();

    /// Only the seller can call this function.
    error OnlySeller();

    modifier inState(State state_) {
        if(state != state_) {
            revert InvalidState();
        }
        _;
    }

    modifier onlyBuyer() {
        if(msg.sender != buyer) {
            revert OnlyBuyer();
        }
        _;
    }

    modifier onlySeller() {
        if(msg.sender != seller) {
            revert OnlySeller();
        }
        _;
    }

    function confirmPurchase() external   inState(State.Created) payable{
        require(msg.value == (2 * itemCost), "Please send the 2 times the purchase amount");
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    function confirmReceived() external onlyBuyer inState(State.Locked) {
        state = State.Release;
        buyer.transfer(itemCost);
    }

    function paySeller() external onlySeller inState(State.Release) {
        state = State.Inactive;
        seller.transfer(3*itemCost);
    }

    function abort() external onlySeller inState(State.Created) {
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }

 }
