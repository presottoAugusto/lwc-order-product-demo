@isTest
public class OrderItemSelectorTest {
   
    @TestSetup
    static void makeData() {
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
    static void testselectByOrderAndPricebookEntryId() {
        Order o = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];

        OrderItem oi = TestDataFactory.createOrderItem(o.Id, pbe.Id, 199.00, 1.00);
        insert oi;

        Test.startTest();
        OrderItem selectedOrderItem = OrderItemSelector.selectByOrderAndPricebookEntryId(o.Id, pbe.Id);
        Test.stopTest();

        System.assert(selectedOrderItem != null, 'Created Order Product should have returned.');
        System.assertEquals(o.Id, selectedOrderItem.OrderId, 'Order Id should match.');
        System.assertEquals(pbe.Id, selectedOrderItem.PricebookEntryId, 'Pricebook Entry Id should match.');
    } 

    @isTest
    static void testselectByOrderAndPricebookEntryIdDifferentProduct() {
        Order o = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];

        Product2 p2 = TestDataFactory.createProduct('Test Product2', true);
        insert p2;
        PricebookEntry pbe2 = TestDataFactory.createPricebookEntry(p2.Id, Test.getStandardPricebookId(), 1.00, true);
        insert pbe2;

        OrderItem oi = TestDataFactory.createOrderItem(o.Id, pbe.Id, 199.00, 1.00);
        insert oi;

        Test.startTest();
        OrderItem selectedOrderItem = OrderItemSelector.selectByOrderAndPricebookEntryId(o.Id, pbe2.Id);
        Test.stopTest();

        System.assert(selectedOrderItem == null, 'No Order Item should have returned.');
    } 

    @isTest
    static void testselectByOrderAndPricebookEntryIdDifferentOrder() {
        Order o = [SELECT Id FROM Order LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Contract ct2 = TestDataFactory.createContract(Date.today(), 'Draft', Test.getStandardPricebookId(), acc.Id);
        insert ct2;
        Order o2 = TestDataFactory.createOrder(acc.Id, ct2.Id, Date.today(), 'Draft');
        insert o2;

        OrderItem oi = TestDataFactory.createOrderItem(o.Id, pbe.Id, 199.00, 1.00);
        insert oi;

        Test.startTest();
        OrderItem selectedOrderItem = OrderItemSelector.selectByOrderAndPricebookEntryId(o2.Id, pbe.Id);
        Test.stopTest();

        System.assert(selectedOrderItem == null, 'No Order Item should have been returned.');
    } 

    @isTest
    static void testselectByOrderId() {
        Order o = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];

        OrderItem oi = TestDataFactory.createOrderItem(o.Id, pbe.Id, 199.00, 1.00);
        insert oi;

        Test.startTest();
        List<OrderItem> selectedOrderItem = OrderItemSelector.selectByOrderId(o.Id);
        Test.stopTest();

        System.assert(!selectedOrderItem.isEmpty(), 'Order Item should have been returned.');
        System.assertEquals(oi.Id, selectedOrderItem.get(0).Id, 'Order Product should match the id of the inserted one.');
    } 
}
