@isTest
public class OrderSelectorTest {
    
    @TestSetup
    static void makeData() {
        TestDataFactory.activateStandardPricebook();
        
        Product2 p = TestDataFactory.createProduct('Test Product', true);
        p.ProductCode = '111222333';
        insert p;
        insert TestDataFactory.createPricebookEntry(p.Id, Test.getStandardPricebookId(), 1.00, true);

        Account acc = TestDataFactory.createAccount('Test Account');
        acc.AccountNumber = 'ACC1234';
        insert acc;
        Contract ct = TestDataFactory.createContract(Date.today(), 'Draft', Test.getStandardPricebookId(), acc.Id);
        insert ct;

        Order o = TestDataFactory.createOrder(acc.Id, ct.Id, Date.today(), 'Draft');
        insert o;
    }
    
    @isTest
    static void testSelectOrderToConfirm() {
        Order o = [SELECT Id, AccountId FROM Order LIMIT 1];
        Product2 p = [SELECT ProductCode FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Account acc = [SELECT AccountNumber FROM Account WHERE Id = :o.AccountId];

        OrderItem oi = TestDataFactory.createOrderItem(o.Id, pbe.Id, 199.00, 1.00);
        insert oi;

        Test.startTest();
        Order retrievedOrder = OrderSelector.selectOrderToConfirm(o.Id);
        Test.stopTest();

        System.assert(retrievedOrder != null, 'Order should have been returned.');
        System.assertEquals(o.Id, retrievedOrder.Id, 'Order Id is not the correct one.');
        System.assertEquals(acc.AccountNumber, retrievedOrder.Account.AccountNumber, 'Account numbers should match.');
        System.assert(!retrievedOrder.OrderItems.isEmpty(), 'Order Items should be retrieved.');
        System.assertEquals(p.ProductCode, retrievedOrder.OrderItems.get(0).Product2.ProductCode, 'Product Code should match.');        
    }

    @isTest
    static void testSelectOrderToConfirmNoOrderItem() {
        Order o = [SELECT Id, AccountId FROM Order LIMIT 1];
        Test.startTest();
        Order retrievedOrder = OrderSelector.selectOrderToConfirm(o.Id);
        Test.stopTest();

        System.assert(retrievedOrder.OrderItems.isEmpty(), 'Order Items should be empty.');
    }
}