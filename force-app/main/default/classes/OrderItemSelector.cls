/**
 * @description       : Class Responsible for selecting OrderItem object
 * @author            : Augusto Presotto da Costa
 * @last modified on  : 10-15-2021
 * @last modified by  : Augusto Presotto da Costa
**/
public with sharing class OrderItemSelector {
    
    /**
    * @description Select OrderItem by Order Id and Pricebook Entry Id
    * @author Augusto Presotto da Costa | 10-15-2021 
    * @param Id orderId 
    * @param Id pricebookEntryId 
    * @return OrderItem 
    **/
    public static OrderItem selectByOrderAndPricebookEntryId(Id orderId, Id pricebookEntryId) {
        List<OrderItem> orderItemList = [SELECT Id, UnitPrice, TotalPrice, Quantity, OrderId, PricebookEntryId
                                        FROM OrderItem
                                        WHERE PricebookEntryId = :pricebookEntryId AND OrderId = :orderId
                                        WITH SECURITY_ENFORCED LIMIT 1];
        return orderItemList.isEmpty() ? null : orderItemList.get(0);
    }

    /**
    * @description Select OrderItem by Order Id
    * @author Augusto Presotto da Costa | 10-15-2021 
    * @param Id orderId 
    * @return List<OrderItem> 
    **/
    public static List<OrderItem> selectByOrderId(Id orderId) {
        return [SELECT Id, Product2.Name, UnitPrice, Quantity, TotalPrice 
                FROM OrderItem
                WHERE OrderId = :orderId
                WITH SECURITY_ENFORCED
                ORDER BY Product2.Name];
    }
}
