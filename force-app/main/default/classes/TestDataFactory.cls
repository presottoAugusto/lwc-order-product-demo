@isTest
public class TestDataFactory {
    
    public static void activateStandardPricebook() {
        Pricebook2 standardPricebook = new Pricebook2();
        standardPricebook.Id = Test.getStandardPricebookId();
        standardPricebook.IsActive = true;
        update standardPricebook;   
    }

    public static Pricebook2 createPricebook(String name) {
        return new Pricebook2(Name = name, IsActive = true);
    }

    public static Product2 createProduct(String productName, Boolean isActive) {
        return new Product2(Name = productName, isActive = isActive);
    }

    public static PricebookEntry createPricebookEntry(Id productId, Id pricebookId, Decimal price, Boolean isActive) {
        return new PricebookEntry(Product2Id = productId, Pricebook2Id = pricebookId, UnitPrice = price, IsActive = isActive);
    }

    public static Account createAccount(String name) {
        return new Account(Name = name);
    }

    public static Contract createContract(Date startDate, String status, Id pricebookId, Id accountId) { 
        return new Contract(StartDate = startDate, Status = status, Pricebook2Id = pricebookId, AccountId = accountId);
    }

    public static Order createOrder(Id accountId, Id contractId, Date startDate, String status) {
        return new Order(AccountId = accountId, ContractId = contractId, EffectiveDate = startDate, Status = status);
    }

    public static OrderItem createOrderItem(Id orderId, Id pricebookEntryId, Decimal price, Decimal quantity) {
        return new OrderItem(OrderId = orderId, PricebookEntryId = pricebookEntryId, UnitPrice = price, Quantity = quantity);
    }
}