public with sharing class OrderSelector {
    public static Order selectOrderToConfirm(Id orderId) {
        return [SELECT Id, OrderNumber, Type, Status, Account.AccountNumber,
                    (SELECT Product2.Name, Product2.ProductCode, UnitPrice, Quantity
                    FROM OrderItems) 
                FROM Order WHERE Id = :orderId];
    }
}
