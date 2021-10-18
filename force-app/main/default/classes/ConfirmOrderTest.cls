@isTest
public class ConfirmOrderTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.activateStandardPricebook();
        
        Product2 p = TestDataFactory.createProduct('Test Product', true);
        insert p;
        Account acc = TestDataFactory.createAccount('Test Account');
        insert acc;
        Contract ct = TestDataFactory.createContract(Date.today(), 'Draft', Test.getStandardPricebookId(), acc.Id);
        insert ct;
        ct.Status = 'Activated';
        update ct;
        Order ord = TestDataFactory.createOrder(acc.Id, ct.Id, Date.today(), 'Draft');
        insert ord;
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(p.Id, Test.getStandardPricebookId(), 1.00, true);
        insert pbe;

        insert TestDataFactory.createOrderItem(ord.Id, pbe.Id, 199.00, 1.00);
    }

    @isTest 
    static void testConfirm() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new ConfirmOrderCalloutMock());
        Test.startTest();
        Map<String, String> calloutReturn = ConfirmOrder.confirm(ord.Id);
        Test.stopTest();
        
        System.assert(calloutReturn.get('success') != null, 'Callout Integration should have returned success.');
        Order activatedOrder = [SELECT Id, Status FROM Order WHERE Id = :ord.Id];
        System.assertEquals('Activated', activatedOrder.Status, 'Order should have been Activated.');
    }

    @isTest 
    static void testConfirmNoOrderItems() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        List<OrderItem> items = [SELECT Id FROM OrderItem];
        delete items; 
        Test.setMock(HttpCalloutMock.class, new ConfirmOrderCalloutMock());
        Test.startTest();
        try{
            Map<String, String> calloutReturn = ConfirmOrder.confirm(ord.Id);
        } catch(Exception ex) {
            System.assert(ex != null, 'There should be an error.');
        }
        Test.stopTest();
        
        Order notActivatedOrder = [SELECT Id, Status FROM Order WHERE Id = :ord.Id];
        System.assertNotEquals('Activated', notActivatedOrder.Status, 'Order should not have been Activated.');
    }
}