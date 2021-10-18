@isTest
public class OrderItemServiceTest {

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
    static void testAdd() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Decimal unitPrice = 10.00;

        Test.startTest();
        OrderItemService.add(ord.Id, pbe.Id, unitPrice);
        Test.stopTest();

        OrderItem oi = [SELECT Id, UnitPrice, PricebookEntryId, OrderId FROM OrderItem WHERE OrderId = :ord.Id]; 
        System.assert(oi != null, 'Order Product should have been returned.');
        System.assertEquals(pbe.Id, oi.PricebookEntryId, 'Wrong Pricebook Entry Id.');
        System.assertEquals(unitPrice, oi.UnitPrice, 'Wrong Unit Price.');
    }

    @isTest
    static void testAddExistingOrderProduct() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Decimal unitPrice = 10.00;

        Test.startTest();
        OrderItemService.add(ord.Id, pbe.Id, unitPrice);
        OrderItemService.add(ord.Id, pbe.Id, unitPrice);
        Test.stopTest();

        OrderItem oi = [SELECT Id, UnitPrice, PricebookEntryId, Quantity, OrderId FROM OrderItem WHERE OrderId = :ord.Id]; 
        System.assert(oi != null, 'Order Product should have been returned.');
        System.assertEquals(2, Integer.valueOf(oi.Quantity), 'Quantity of the Order Product should be two.'); 
    }
}