//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.14;
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

contract BlockCart is SafeERC20 {
    constructor() {
        owner = msg.sender;
    }


    // ERC20 variables
    string public name = "BlockCart Token"; // Token name
    string public symbol = "BCT"; // Token symbol
    uint8 public decimals = 18; // Number of decimal places
    uint public totalSupply = 1000000; // Total supply of tokens



    address public owner;
    string public contractName = "BlockCart";

    uint256 foodCount = 1;
    uint256 orderCount = 1;

    // enum Order status
    enum OrderStatus {
        Cancelled,
        Completed,
        Pending
    }

    // structs restaurant food order courrier customer comment
    struct Restaurant {
        address resOwner;
        string name;
        string desc;
        bool isOpen;
        uint256 successWork;
    }

    struct Food {
        string name;
        string desc;
        string category;
        uint256 price; //(wei)
        bool isActive;
        address resOwner;
    }

    struct Order {
        uint256[] foodIds;
        uint256 totalPrice;
        string orderAdress;
        address resOwner;
        address cusOwner; //customer
        address courOwner; //courrier
        string orderDetail;
        OrderStatus status;
        uint256 creatingTime; //timestamp
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
    struct DelayedTransfer {
  uint256 amount;
  address to;
  uint256 releaseTime;
}
    mapping(uint256 => DelayedTransfer[]) delayedTransfers;
    mapping(address => Restaurant) public restaurants;
    mapping(uint256 => Food) public foods;
    mapping(uint256 => Order) public orders;
    mapping(address => Customer) public customers;
    mapping(address => Courrier) public courriers;
    mapping(address => uint256) lockedBalances;
    mapping(address => uint256) balances;
    mapping(address => Comment) comments;
    mapping(address => mapping(address => uint)) public allowed;

function createOrder(uint256[] memory _foodIds, string memory _orderAddress, uint256 _totalPrice) public {
  require(customers[msg.sender].customerAddress == msg.sender, "The caller is not a registered customer");
  require(balances[msg.sender] >= _totalPrice, "Insufficient balance");
  for (uint256 i = 0; i < _foodIds.length; i++) {
    require(foods[_foodIds[i]].isActive, "One or more food items are not active or do not exist");
  }
  balances[msg.sender] -= _totalPrice;
  lockedBalances[foods[_foodIds[0]].resOwner] += _totalPrice;
  orders[orderCount] = Order(_foodIds, _totalPrice, _orderAddress, foods[_foodIds[0]].resOwner, msg.sender, address(0), "", OrderStatus.Pending, now);
  orderCount++;
  scheduleRelease(_totalPrice, foods[_foodIds[0]].resOwner, 3 hours);
}

function scheduleRelease(uint256 _amount, address _to, uint256 _delay) private {
  require(_delay > 0, "The delay must be positive");
  uint256 releaseTime = now + _delay;
  DelayedTransfer memory transfer = DelayedTransfer(_amount, _to, releaseTime);
  delayedTransfers[releaseTime].push(transfer);
}


function releaseLockedBalance() private {
  uint256 currentTime = now;
  DelayedTransfer[] memory transfers = delayedTransfers[currentTime];
  for (uint256 i = 0; i < transfers.length; i++) {
    DelayedTransfer memory transfer = transfers[i];
    require(restaurants[transfer.to].resOwner == transfer.to, "The recipient is not a registered restaurant");
    lockedBalances[transfer.to] -= transfer.amount;
    balances[transfer.to] += transfer.amount;
  }
  delete delayedTransfers[currentTime];
}

function setOrderCourrierFee(uint256 _orderId, uint256 _courrierFee) public {
  require(restaurants[msg.sender].resOwner == msg.sender, "The caller is not a registered restaurant");
  require(orders[_orderId].status == OrderStatus.Pending, "The order does not exist or is not pending");
  require(orders[_orderId].resOwner == msg.sender, "The order does not belong to the sender");
  orders[_orderId].courrierFee = _courrierFee;
}
 


function totalSupply() public view returns (uint) {
        return totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) public returns (bool) {
        require(_value <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true}



function transferFrom(address _from, address _to, uint _value) public returns (bool) {
    require(_value <= balances[_from] && _value <= allowed[_from][msg.sender], "Insufficient balance or allowance");
    balances[_from] -= _value;
    allowed[_from][msg.sender] -= _value;
    balances[_to] += _value;
    emit Transfer(_from, _to, _value);
    return true;
}

function approve(address _spender, uint _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
}

function allowance(address _owner, address _spender) public view returns (uint) {
    return allowed[_owner][_spender];
}



function createRestaurant(string memory _name, string memory _description) public {
    require(restaurants[msg.sender].resOwner ==msg.sender, "The caller is already registered as a restaurant");
    restaurants[msg.sender] = Restaurant(msg.sender, _name, _description, true, 0);
}


    function destroyRestaurant() public {
        require(restaurants[msg.sender].resOwner ==msg.sender, "The caller is already as a restaurant");
        delete restaurants[msg.sender];
    }

    function changeIsOpen() public {
        require(restaurants[msg.sender].resOwner ==msg.sender, "The caller is already as a restaurant");
        bool isOpen = restaurants[msg.sender].isOpen;
        restaurants[msg.sender].isOpen = !isOpen;
    }

    function addFood(
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
            _name,
            _desc,
            _category,
            _price,
            true,
            msg.sender
        );
        foodCount++;
    }

function changeActiveFood(uint _foodId) public {

    Food memory food = foods[_foodId];

    require(food.resOwner == msg.sender, "Only the owner of the food can change its active status");

    food.isActive = !food.isActive;
    foods[_foodId] = food;
}


    function createCustomer(
        string memory _name,
        string memory _mail,
        string memory _phoneNumber
    ) public {

        require(customers[msg.sender].customerAddress==msg.sender,'The caller is already registered as a customer');

        customers[msg.sender] = Customer(
            msg.sender,
            _name,
            _mail,
            _phoneNumber
        );
    }

    function deleteCustomer() public {
        require(customers[msg.sender].customerAddress==msg.sender,'The caller is already as a customer');
        delete customers[msg.sender];
    }


    function createCourrier(string memory _name) public {
        require(courriers[msg.sender].courAddress==msg.sender,'The caller is already registered as a courrier');
        courriers[msg.sender] = Courrier(_name, msg.sender, 0);
    }


    function deleteCourrier() public {
        require(courriers[msg.sender].courAddress==msg.sender,'The caller is already as a courrier');
        delete courriers[msg.sender];
    }

function createOrder(uint256[] memory _foodIds, string memory _orderAddress, uint256 _totalPrice) public {
  require(customers[msg.sender].customerAddress == msg.sender, "The caller is not a registered customer");
  require(balances[msg.sender] >= _totalPrice, "Insufficient balance");
  for (uint256 i = 0; i < _foodIds.length; i++) {
    require(foods[_foodIds[i]].isActive, "One or more food items are not active or do not exist");
  }
  balances[msg.sender] -= _totalPrice;
  orders[orderCount] = Order(_foodIds, _totalPrice, _orderAddress, address(0), msg.sender, address(0), "", OrderStatus.Pending, now);
  orderCount++;
}



    /* function createOrder(
        address resOwner,
        uint256[] memory _foodIds,
        string memory _orderAddress,
        string memory _orderDetail
    ) public payable {
        uint256 totalPrice = 0;
        for (uint256 i = 0; i < _foodIds.length; i++) {
            totalPrice += foods[_foodIds[i]].price;
        }


        require(totalPrice <= msg.value, "Insufficient funds");


        payable(address(this)).transfer(totalPrice);


        stakedBalances[msg.sender] = totalPrice;


        uint256 creatingTime = block.timestamp;


        address courOwner;

        orders[orderCount] = Order(
            _foodIds,
            totalPrice,
            _orderAddress,
            msg.sender,
            resOwner,
            courOwner,
            _orderDetail,
            OrderStatus.Pending,
            creatingTime
        );
        orderCount++;
    }




    function takePackage(uint256 _orderId) public {
        require(msg.sender == orders[_orderId].cusOwner);
        require(
            orders[_orderId].status == OrderStatus.Cancelled,
            "order is completed"
        );
        require(
            orders[_orderId].status == OrderStatus.Completed,
            "order is completed"
        );
    }
    

    function updateOrder() public {}



    function completeOrder(uint256 _orderId) public {
        Order memory order = orders[_orderId];
        require(
            order.courOwner != address(0),
            "This order has not yet been taken by a courier"
        );

        require(
            order.courOwner == msg.sender,
            "Only the courier who took the order can complete it"
        );


        balances[msg.sender] += stakedBalances[msg.sender];
        stakedBalances[msg.sender] = 0;

        order.status = OrderStatus.Completed;

        orders[_orderId] = order;
    }



    function addComment(
        uint256 _orderId,
        string memory _title,
        string memory _detail
    ) public {
        Order memory order = orders[_orderId];

        require(
            order.cusOwner == msg.sender,
            "Only the customer who placed the order can leave a comment"
        );

        require(
            order.status == OrderStatus.Completed,
            "This order has not yet been completed"
        );

        comments[order.resOwner] = Comment(_title, _detail);
    } */
}
