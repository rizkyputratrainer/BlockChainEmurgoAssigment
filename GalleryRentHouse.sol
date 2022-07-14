// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.0;


contract GalleryRentHouse {
    address payable public owner;

    uint public countHouse = 0;
    uint public countRenting = 1;
    uint totalFund = 0;

    enum HouseTypes {SEDERHANA, MENENGAH, MEWAH}

    struct Renting {
        uint rentId;
        uint amount;
        uint[] rooms;
        uint houseId;
        bool isPaid;
        address payable currentCustomer;    
    }

    struct House {
        uint houseId;
        string houseTitle;
        uint housePrice;
        HouseTypes houseTypes;
        uint[] roomId;
    }

    mapping(uint => House) Houses;

    mapping(uint => Renting) Rentings;

    uint indexOrder = 1;

    constructor() {
        owner = msg.sender;
    }

    modifier isOwner {
        require (owner == msg.sender, "You are not owner");
        _;
    }

    modifier isNotOwner {
        require (owner != msg.sender, "You are not customer");
        _;
    }

    modifier isHouseAvailable(uint _houseId) {
        require(Houses[_houseId].houseId != 0, "The House is not Available");
        _;
    }

    modifier ChooseRooms(uint _roomId) {
        require(_roomId <= 5, "Select room house available 1 to 5 rooms.");
        _;
    }

    modifier checkRent(uint _houseId) {
        uint ids = Rentings[_rentId].rentId;
        require(ids != 0, "You haven't rent");
        _;
    }

    modifier checkBalance(uint _rentId) {
        uint _cost = Rentings[_rentId].amount;
        require(msg.value >= _cost, "not enough funds");
        _;
    }

    modifier checkPaid(uint _rentingId) {
        require(!Rentings[_rentingId].isPaid, "You already paid");
        _;
    }

    modifier isRoomAvailableHouse(uint _houseId, uint _roomId) {

        bool availableRoom = false;
        for (uint i = 0; i < Houses[_houseId].roomId.length; i++) {
            if (_roomId == Houses[_houseId].roomId[i]) {
                availableRoom = true;
            }
        }
        require(!availableRoom, "Room are filled");
        _;
    }

    modifier isRoomAvailable(uint _roomId) {
        if (Rentings[countRenting].currentCustomer != msg.sender) {
            delete Rentings[countRenting].rooms;
        }

        bool availableRoom = false;
        for (uint i = 0; i < Rentings[countRenting].rooms.length; i++) {
            if (_seatId == Rentings[countRenting].rooms[i]) {
                availableRoom = true;
            }
        }
        require(!availableRoom, "Room are rented");
        _;
    }

    function addHouse(string memory _houseTitle, uint _housePrice, HouseTypes _houseTypes) external isOwner {
        countHouse++;
        // create House
        Houses[countHouse].houseId = countHouse;
        Houses[countHouse].houseTitle = _houseTitle;
        Houses[countHouse].housePrice = _housePrice;
        Houses[countHouse].houseTypes = _houseTypes;
    }

    function rentingHouses(uint _houseId, uint _roomId) external payable isNotOwner isHouseAvailable(_houseId) ChooseRooms(_roomId) isRoomAvailable(_roomId) isRoomAvailableHouse(_houseId, _roomId)   {
        
        // create renting
        Rentings[countRenting].rentId = countRenting;
        Rentings[countRenting].houseId = _houseId;
        Rentings[countRenting].rooms.push(_roomId);
        Rentings[countRenting].currentCustomer = msg.sender;

        // update amount
        Rentings[countRenting].amount = Rentings[countRenting].rooms.length * Houses[_houseId].housePrice;
    }

    function paymentHouses(uint _rentingId) payable external checkBalance(_rentingId) checkRent(_rentingId) checkPaid(_rentingId) {
        Renting memory rentings = Rentings[_rentingId];
        
        uint totalFee = Rentings[_rentingId].amount;
        uint refundFee = 0;

        Rentings[_rentingId].isPaid = true;
        countRenting++;

        // update Room house
        for (uint i = 0; i < Rentings[_rentingId].rooms.length; i++) {
            Houses[Rentings[_rentingId].houseId].roomId.push(Rentings[_rentingId].rooms[i]);
        }

        if (msg.value > Rentings[_rentingId].amount) {
            refundFee = msg.value - Rentings[_rentingId].amount;
        }

        address payable customer = rentings.currentCustomer;
        // refund fee to sender
        customer.transfer(refundFee);

        owner.transfer(totalFee);
    }

    function finishHouse(uint _houseId) external isOwner isHouseAvailable(_houseId) returns(bool success) {
        delete Houses[_houseId].roomId;

        return true;
    }

   function getRenting(uint _rentId) public view returns (uint _id, uint _amount, uint[] memory _room,
        uint _houseId, bool _isPaid) {
        uint lengths = Rentings[_rentId].rooms.length;
        
        uint id = Rentings[_rentId].rentId;
        uint amount = Rentings[_rentId].amount;
        bool isPaid = Rentings[_rentId].isPaid;
        uint houseId = Rentings[_rentId].houseId;

        uint[] memory room = new uint[](lengths);

        Renting storage rents = Rentings[_rentId];
        for (uint i = 0; i < lengths; i++) {
            room[i] = rents.rooms[i];
        }

        return (id, amount, room, houseId, isPaid);
    }

    function getHouses(uint _houseId) public view returns (uint _id, string memory _houseTitle, uint _housePrice, 
        uint[] memory _room, HouseTypes _houseTypes) {
        uint lengths = Houses[_houseId].roomId.length;
        
        uint id = Houses[_houseId].houseId;
        string memory houseTitle = Houses[_houseId].houseTitle;
        uint housePrice = Houses[_houseId].housePrice;
        HousesTypes houseTypes = Houses[_houseId].houseTypes;

        uint[] memory room = new uint[](lengths);

        House storage housess = Houses[_houseId];
        for (uint i = 0; i < lengths; i++) {
            room[i] = housess.roomId[i];
        }

        return (id, houseTitle, housePrice, room, houseTypes);
    }
}
