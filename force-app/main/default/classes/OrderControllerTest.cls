@isTest
public class OrderControllerTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.activateStandardPricebook();
        
        Product2 p = TestDataFactory.createProduct('Test Product', true);
        insert p;
        insert TestDataFactory.createPricebookEntry(p.Id, Test.getStandardPricebookId(), 1.00, true);

        Account acc = TestDataFactory.createAccount('Test Account');
        insert acc;
        Contract ct = TestDataFactory.createContract(Date.today(), 'Draft', Test.getStandardPricebookId(), acc.Id);
        insert ct;

        insert TestDataFactory.createOrder(acc.Id, ct.Id, Date.today(), 'Draft');    
    }

    @isTest
    static void testAddProductToOrder() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Decimal unitPrice = 10.00;

        Test.startTest();
        OrderController.addProductToOrder(ord.Id, pbe.Id, unitPrice);
        Test.stopTest();

        OrderItem oi = [SELECT Id, UnitPrice, PricebookEntryId, OrderId FROM OrderItem WHERE OrderId = :ord.Id]; 
        System.assert(oi != null, 'Order Product should have been returned.');
        System.assertEquals(pbe.Id, oi.PricebookEntryId, 'Wrong Pricebook Entry Id.');
        System.assertEquals(unitPrice, oi.UnitPrice, 'Wrong Unit Price.');
    }

    @isTest
    static void testGetAvailableProducts() {
        Product2 p = TestDataFactory.createProduct('Test Product2', true);
        insert p;
        insert TestDataFactory.createPricebookEntry(p.Id, Test.getStandardPricebookId(), 1.00, true);
        Test.startTest();
        List<OrderController.Product> productList = OrderController.getAvailableProducts(Test.getStandardPricebookId(), 0); 
        Test.stopTest();

        System.assert(!productList.isEmpty(), 'Products List returned should not be empty.');
        System.assert(productList.size() == 2, 'Two products should have been returned.');
        System.assertEquals('Test Product', productList.get(0).name, 'First returned product name should have matched first product Name');
        System.assertEquals('Test Product2', productList.get(1).name, 'Second returned product name should have matched second product Name');
    }

    @isTest
    static void testGetAvailableProductsNoProducts() {
        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry];
        delete pbeList;
        Test.startTest();
        List<OrderController.Product> productList = OrderController.getAvailableProducts(Test.getStandardPricebookId(), 0); 
        Test.stopTest();

        System.assert(productList.isEmpty(), 'Products returned should have been returned empty.');
    }

    @isTest
    static void testGetOrderProducts() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pbe = [SELECT Id, Product2.Name FROM PricebookEntry LIMIT 1];

        OrderItem oi = TestDataFactory.createOrderItem(ord.Id, pbe.Id, 199.00, 1.00);
        insert oi;

        Test.startTest();
        List<OrderController.OrderProduct> orderProductList = OrderController.getOrderProducts(ord.Id);
        Test.stopTest();

        System.assert(!orderProductList.isEmpty(), 'Order Products List returned should not be empty.');
        System.assertEquals(pbe.Product2.Name, orderProductList.get(0).name, 'Order Product returned should have the same name as the product added.');
        System.assertEquals(199.00, orderProductList.get(0).unitPrice, 'Order Product returned should have the same Unit Price as the one we added.');
        System.assertEquals(1.00, orderProductList.get(0).quantity, 'Order Product Quantity should have been only one.');
        System.assertEquals(199.00, orderProductList.get(0).totalPrice, 'Order Product Total Price should be the sames as the one we added.');
    }

    @isTest
    static void testGetOrderProductsNoOrderProduct() {
        Order ord = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();
        List<OrderController.OrderProduct> orderProductList = OrderController.getOrderProducts(ord.Id);
        Test.stopTest();

        System.assert(orderProductList.isEmpty(), 'Order Products List returned should be empty.');
    }
}
