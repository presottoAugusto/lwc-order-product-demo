/**
 * @description       : Class to perform Order Item actions
 * @author            : Augusto Presotto da Costa
 * @last modified on  : 10-15-2021
 * @last modified by  : Augusto Presotto da Costa
**/
public with sharing class OrderItemService {
    
    /**
    * @description - Add a Product to the Order Using Order Item object
    * @author Augusto Presotto da Costa | 10-15-2021 
    * @param String orderId 
    * @param String pricebookEntryId 
    * @param Decimal unitPrice 
    **/
    public static void add(String orderId, String pricebookEntryId, Decimal unitPrice) {
        OrderItem orderItem = OrderItemSelector.selectByOrderAndPricebookEntryId(orderId, pricebookEntryId);
        
        // If there are already the same Order Product we just add to the Quantity
        if (orderItem != null) {
            orderItem.Quantity = orderItem.Quantity + 1.00;
            update orderItem; 
        } else {
            // If there isn't we add a new one
            orderItem = new OrderItem();
            orderItem.OrderId = orderId;
            orderItem.PricebookEntryId = pricebookEntryId;
            orderItem.UnitPrice = unitPrice;
            orderItem.Quantity = 1.00;
            insert orderItem;
        }
    }
}