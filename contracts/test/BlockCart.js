const { ethers } = require('hardhat')

const { expect } = require('chai')

describe('BlockCart contract', function () {
    let BlockCartContract
    let account1
    let account2
    let account3
    let account4
    let nullAddress = ethers.constants.AddressZero
    before(async () => {
        [account1, account2, account3, account4] = await ethers.getSigners()
        const BlockCart = await ethers.getContractFactory('BlockCart')
        BlockCartContract = await BlockCart.deploy()
    })

    it('should create a restaurant', async () => {
        await BlockCartContract.createRestaurant('Test Restaurant', 'This is a test restaurant')
        const restaurant = await BlockCartContract.restaurants(account1.address)
        expect(restaurant.name).to.equal('Test Restaurant')
        expect(restaurant.desc).to.equal('This is a test restaurant')
    })

    it('should destroy a restaurant', async () => {
        await BlockCartContract.destroyRestaurant()
        const restaurant = await BlockCartContract.restaurants(account1.address)
        expect(restaurant.resOwner).to.equal(nullAddress)
    })

    it('should change the open status of a restaurant', async () => {
        await BlockCartContract.createRestaurant('Test Restaurant', 'This is a test restaurant')
        let restaurant = await BlockCartContract.restaurants(account1.address)
        expect(restaurant.isOpen).to.be.true
        await BlockCartContract.changeIsOpen()
        restaurant = await BlockCartContract.restaurants(account1.address)
        expect(restaurant.isOpen).to.be.false
    })
    it('should create a customer', async () => {
        await BlockCartContract.createCustomer('Test Customer', 'test@example.com', '1234567890')
        const customer = await BlockCartContract.customers(account1.address)
        expect(customer.name).to.equal('Test Customer')
        expect(customer.mail).to.equal('test@example.com')
        expect(customer.phoneNumber).to.equal('1234567890')
    })

    it('should add a food item', async () => {
        await BlockCartContract.createRestaurant('Test Restaurant', 'This is a test restaurant')
        await BlockCartContract.addFood('https://example.com/food1.jpg', 'Food 1', 'This is food 1', 1000, 'Category 1')
        const food = await BlockCartContract.foods(1)
        expect(food.name).to.equal('Food 1')
        expect(food.desc).to.equal('This is food 1')
        expect(food.price).to.equal(1000)
        expect(food.category).to.equal('Category 1')
    })

    it('should change the active status of a food item', async () => {
        await BlockCartContract.createRestaurant('Test Restaurant', 'This is a test restaurant')
        await BlockCartContract.addFood('https://example.com/food1.jpg', 'Food 1', 'This is food 1', 1000, 'Category 1')
        let food = await BlockCartContract.foods(1)
        expect(food.isActive).to.be.true
        await BlockCartContract.changeActiveFood(1)
        food = await BlockCartContract.foods(1)
        expect(food.isActive).to.be.false
    })

    it('should delete a customer', async () => {
        await BlockCartContract.createCustomer('Test Customer', 'test@example.com', '1234567890')
        await BlockCartContract.deleteCustomer()
        const customer = await BlockCartContract.customers(account1.address)
        expect(customer.customerAddress).to.equal(nullAddress)
    })

    it('should create a courrier', async () => {
        await BlockCartContract.createCourrier('Test Courrier')
        const courrier = await BlockCartContract.courriers(account1.address)
        expect(courrier.name).to.equal('Test Courrier')
    })

    it('should delete a courrier', async () => {
        await BlockCartContract.createCourrier('Test Courrier')
        await BlockCartContract.deleteCourrier()
        const courrier = await BlockCartContract.courriers(account1.address)
        expect(courrier.courAddress).to.equal(nullAddress)
    })

    it('should add a delivery fee to an order', async () => {
        await BlockCartContract.connect(account2).createRestaurant('Test Restaurant', 'This is a test restaurant')
        await BlockCartContract.connect(account2).addFood('https://example.com/food1.jpg', 'Food 1', 'This is food 1', 1000, 'Category 1')
        await BlockCartContract.connect(account1).createCustomer('Test Customer', 'test@example.com', '1234567890')
        await BlockCartContract.connect(account3).createCourrier('Test Courrier')
        await BlockCartContract.connect(account1).createOrder([1], '123 Main St', account2.address, 'Order detail')
        const order = await BlockCartContract.orders(1)
        expect(order.status).to.equal(2) 
        await BlockCartContract.connect(account2).addDeliveryFee(1, 500)
        const updatedOrder = await BlockCartContract.orders(1)
        expect(updatedOrder.courrierFee).to.equal(500)
    })

    it('should cancel an order', async () => {
        await BlockCartContract.connect(account2).createRestaurant('Test Restaurant', 'This is a test restaurant')
        await BlockCartContract.connect(account2).addFood('https://example.com/food1.jpg', 'Food 1', 'This is food 1', 1000, 'Category 1')
        await BlockCartContract.connect(account1).createCustomer('Test Customer', 'test@example.com', '1234567890')
        await BlockCartContract.connect(account3).createCourrier('Test Courrier')
        await BlockCartContract.connect(account1).createOrder([1], '123 Main St', account1.address, 'Order detail')
        await BlockCartContract.connect(account2).addDeliveryFee(1, 500)
        await BlockCartContract.connect(account1).cancelOrder(1)
        const order = await BlockCartContract.orders(1)
        expect(order.status).to.equal(0) // OrderStatus.Cancelled
    })

})
