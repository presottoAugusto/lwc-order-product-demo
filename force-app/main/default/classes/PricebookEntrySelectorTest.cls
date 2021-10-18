@isTest
public class PricebookEntrySelectorTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.activateStandardPricebook();
    }

    @isTest
    static void testSelectByPBId() {
        Product2 product = TestDataFactory.createProduct('Test Product', true);
        Product2 product2 = TestDataFactory.createProduct('Test Product2', true);
        
        insert new List<Product2> { product, product2 };

        PricebookEntry pbe = TestDataFactory.createPricebookEntry(product.Id, Test.getStandardPricebookId(), 1.00, true);
        PricebookEntry pbe2 = TestDataFactory.createPricebookEntry(product2.Id, Test.getStandardPricebookId(), 2.00, true);

        insert new List<PricebookEntry> { pbe, pbe2 }; 

        Test.startTest();
        List<PricebookEntry> pbeList = PricebookEntrySelector.selectByPricebookId(Test.getStandardPricebookId(), 0);
        system.debug(pbeList);
        Test.stopTest();

        System.assert(pbeList.size() == 2, 'Pricebook Entry list should have two items.');
        System.assertEquals(product.Name, pbeList.get(0).Product2.Name, 'Pricebook Entry first item product\'s name should match the first inserted Product\'s name.');
        System.assertEquals(pbe.UnitPrice, pbeList.get(0).UnitPrice, 'Pricebook Entry first item Unit Price should match the first inserted PBE Unit Price.');
        System.assertEquals(product2.Name, pbeList.get(1).Product2.Name, 'Pricebook Entry second item product\'s name should match the second inserted Product\'s name.');
        System.assertEquals(pbe2.UnitPrice, pbeList.get(1).UnitPrice, 'Pricebook Entry second item Unit Price should match the second inserted PBE Unit Price.');
    }

    @isTest
    static void testSelectByPBIdNoPricebookEntry() {
        Test.startTest();
        List<PricebookEntry> pbeList = PricebookEntrySelector.selectByPricebookId(Test.getStandardPricebookId(), 0);
        Test.stopTest();

        System.assert(pbeList.isEmpty(), 'Pricebook Entry list should be empty.');
    }

    @isTest
    static void testSelectByPBIdDifferentPricebook() {
        Pricebook2 notStandardPricebook = TestDataFactory.createPricebook('Not Standard Pricebook');
        insert notStandardPricebook;

        Product2 product = TestDataFactory.createProduct('Test Product', true);
        insert product;

        PricebookEntry pbe = TestDataFactory.createPricebookEntry(product.Id, Test.getStandardPricebookId(), 1.00, true);
        insert pbe;

        Test.startTest();
        List<PricebookEntry> pbeList = PricebookEntrySelector.selectByPricebookId(notStandardPricebook.Id, 0);
        Test.stopTest();

        System.assert(pbeList.isEmpty(), 'Pricebook Entry list should be empty.');
    }

    @isTest
    static void testSelectByPBIdInactiveProduct() {
        Product2 product = TestDataFactory.createProduct('Test Product', false);
        insert product;

        PricebookEntry pbe = TestDataFactory.createPricebookEntry(product.Id, Test.getStandardPricebookId(), 1.00, true);
        insert pbe;

        Test.startTest();
        List<PricebookEntry> pbeList = PricebookEntrySelector.selectByPricebookId(Test.getStandardPricebookId(), 0);
        Test.stopTest();

        System.assert(pbeList.isEmpty(), 'Pricebook Entry list should be empty.');
    }

    @isTest
    static void testSelectByPBIdInactivePricebookEntry() {
        Product2 product = TestDataFactory.createProduct('Test Product', true);
        insert product;

        PricebookEntry pbe = TestDataFactory.createPricebookEntry(product.Id, Test.getStandardPricebookId(), 1.00, false);
        insert pbe;

        Test.startTest();
        List<PricebookEntry> pbeList = PricebookEntrySelector.selectByPricebookId(Test.getStandardPricebookId(), 0);
        Test.stopTest();

        System.assert(pbeList.isEmpty(), 'Pricebook Entry list should be empty.');
    }
}