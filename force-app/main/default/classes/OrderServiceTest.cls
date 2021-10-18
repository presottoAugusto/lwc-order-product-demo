@isTest
public class OrderServiceTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.activateStandardPricebook();

        Account acc = TestDataFactory.createAccount('Test Account');
        insert acc;
        Contract ct = TestDataFactory.createContract(Date.today(), 'Draft', Test.getStandardPricebookId(), acc.Id);
        insert ct;
        ct.Status = 'Activated';
        update ct;
        Order ord = TestDataFactory.createOrder(acc.Id, ct.Id, Date.today(), 'Draft');
        insert ord;
        Product2 p = TestDataFactory.createProduct('Test Product', true);
        insert p;
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(p.Id, Test.getStandardPricebookId(), 1.00, true);
        insert pbe;

        insert TestDataFactory.createOrderItem(ord.Id, pbe.Id, 199.00, 1.00);
    }

    @isTest
    static void testActivateOrder() {
        Order ord = [SELECT Id, Status FROM Order LIMIT 1];

        System.assert(ord.Status != 'Activated', 'Order should not be Activated to this test.');

        Test.startTest();
        OrderService.activateOrder(ord);
        Test.stopTest();

        Order activeOrder = [SELECT Status FROM Order WHERE Id = :ord.Id];

        System.assert(activeOrder.Status == 'Activated', 'Order should have been Activated.');
    }
}
