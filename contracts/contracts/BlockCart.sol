// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// import "@openzeppelin/contracts@4.8.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BlockCart is ERC20 {
    constructor() ERC20("BlockCart", "BC") {
        _mint(msg.sender, 1000 * 10 ** decimals());
        owner = msg.sender;
    }

    address public owner;
    string public contractName = "BlockCart";

    uint256 public foodCount = 1;
    uint256 public orderCount = 1;

    function getFoodCount() public view returns (uint256) {
        return foodCount;
    }

    function getOrderCount() public view returns (uint256) {
        return orderCount;
    }

    enum OrderStatus {
        Cancelled,
        Completed,
        Pending
    }
    struct Restaurant {
        address resOwner;
        string name;
        string desc;
        bool isOpen;
        uint256 successWork;
    }

    struct Food {
        string imageLink;
        string name;
        string desc;
        string category;
        uint256 price;
        bool isActive;
        address resOwner;
    }

    struct Order {
        uint256[] foodIds;
        uint256 totalPrice;
        uint256 courrierFee;
        string orderAdress;
        address resOwner;
        address cusOwner; //customer
        address courOwner; //courrier
        string orderDetail;
        OrderStatus status;
    }

    struct Customer {
        address customerAddress;
        string name;
        string mail;
        string phoneNumber;
    }

    struct Courrier {
        string name;
        address courAddress;
        uint256 succedWork;
    }

    struct Comment {
        string title;
        string detail;
    }

    mapping(address => Restaurant) public restaurants;
    mapping(uint256 => Food) public foods;
    mapping(uint256 => Order) public orders;
    mapping(address => Customer) public customers;
    mapping(address => Courrier) public courriers;
    mapping(address => Comment[]) comments;

    function createRestaurant(
        string memory _name,
        string memory _description
    ) public {
        restaurants[msg.sender] = Restaurant(
            msg.sender,
            _name,
            _description,
            true,
            0
        );
    }

    function destroyRestaurant() public {
        delete restaurants[msg.sender];
    }

    function changeIsOpen() public {
        bool isOpen = restaurants[msg.sender].isOpen;
        restaurants[msg.sender].isOpen = !isOpen;
    }

    function addFood(
        string memory _imageLink,
        string memory _name,
        string memory _desc,
        uint256 _price,
        string memory _category
    ) public {
        require(
            restaurants[msg.sender].resOwner == msg.sender,
            "Only restaurant owners can add food items"
        );

        foods[foodCount] = Food(
            _imageLink,
            _name,
            _desc,
            _category,
            _price,
            true,
            msg.sender
        );
        foodCount++;
    }

    function changeActiveFood(uint256 _foodId) public {
        foods[_foodId].isActive = !foods[_foodId].isActive;
    }

    function createCustomer(
        string memory _name,
        string memory _mail,
        string memory _phoneNumber
    ) public {
        customers[msg.sender] = Customer(
            msg.sender,
            _name,
            _mail,
            _phoneNumber
        );
    }

    function deleteCustomer() public {
        delete customers[msg.sender];
    }

    function createCourrier(string memory _name) public {
        courriers[msg.sender] = Courrier(_name, msg.sender, 0);
    }

    function deleteCourrier() public {
        delete courriers[msg.sender];
    }



    function createOrder(
        uint256[] memory _foodIds,
        string memory _orderAddress,
        address _restaurantOwner,
        string memory _orderDetail
    ) public {
        require(
            customers[msg.sender].customerAddress == msg.sender,
            "Customer must exist"
        );
        require(
            restaurants[_restaurantOwner].resOwner == _restaurantOwner,
            "Restaurant must exist"
        );
        uint256 totalPrice = 0;
        for (uint256 i = 0; i < _foodIds.length; i++) {
            totalPrice += foods[_foodIds[i]].price;
        }

        orders[orderCount] = Order(
            _foodIds,
            totalPrice,
            0,
            _orderAddress,
            _restaurantOwner,
            msg.sender,
            address(0),
            _orderDetail,
            OrderStatus.Pending
        );
        orderCount++;
    }
        function cancelOrder(uint256 _orderId) public {
        Order storage order = orders[_orderId];
        require(order.status == OrderStatus.Pending, "Order must be pending");
        require(order.cusOwner == msg.sender, "Only customer can cancel order");

        order.status = OrderStatus.Cancelled;
    }


    function acceptOrder(uint256 _orderId) public {
        Order storage order = orders[_orderId];
        require(order.status == OrderStatus.Pending, "Order must be pending");
        require(
            courriers[msg.sender].courAddress == msg.sender,
            "Courrier must exist"
        );

        order.courOwner = msg.sender;
        order.status = OrderStatus.Pending;
    }

    function payOrder(uint256 _orderId) public {
        Order storage order = orders[_orderId];
        require(order.status == OrderStatus.Pending, "Order must be pending");
        require(
            balanceOf(msg.sender) >= order.totalPrice,
            "Insufficient token balance"
        );

        order.status = OrderStatus.Completed;
        transfer(order.resOwner, order.totalPrice);
    }
    function addDeliveryFee(uint256 _orderId, uint256 _fee) public {
        Order storage order = orders[_orderId];
        require(order.status == OrderStatus.Pending, "Order must be pending");
        require(
            order.resOwner == msg.sender,
            "Only restaurant owner can add delivery fee"
        );

        order.courrierFee += _fee;
    }
    function payCourrier(uint256 _orderId) public {
        Order storage order = orders[_orderId];
        require(
            order.status == OrderStatus.Completed,
            "Order must be completed"
        );
        require(
            order.resOwner == msg.sender,
            "Only restaurant owner can pay courrier"
        );
        require(
            balanceOf(msg.sender) >= order.courrierFee,
            "Insufficient token balance"
        );
        transfer(order.courOwner, order.totalPrice);
        order.courrierFee = 0;
    }


    function addComment(
        uint256 _orderId,
        string memory _title,
        string memory _detail
    ) public {
        Order storage order = orders[_orderId];
        require(
            order.status == OrderStatus.Completed,
            "Order must be completed"
        );
        require(order.cusOwner == msg.sender, "Only customer can add comment");

        comments[order.cusOwner].push(Comment(_title, _detail));
    }
}
