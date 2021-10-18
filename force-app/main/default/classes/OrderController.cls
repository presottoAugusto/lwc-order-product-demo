/**
 * @description       : Class related with Order Record Page components 
 * @author            : Augusto Presotto da Costa
 * @group             : 
 * @last modified on  : 10-15-2021
 * @last modified by  : Augusto Presotto da Costa
**/
public with sharing class OrderController {
    
    
    /**
     * @description - Get all Available Products related with given Pricebook Id, using offset to infinite/lazy loading
     * @author Augusto Presotto da Costa | 10-15-2021 
     * @param Id pricebookId 
     * @param Integer offset  - Number of records to be used as a offset
     * @return List<Product>  - Available Products
     **/
    @AuraEnabled(cacheable=false)
    public static List<Product> getAvailableProducts(Id pricebookId, Integer offset) {
        List<Product> productList = new List<Product>();
        
        try {
            // Method to enforce security and return only accessible fields
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, PricebookEntrySelector.selectByPricebookId(pricebookId, offset));
            for (SObject strippedPBE : securityDecision.getRecords()) {
                PricebookEntry pbe = (PricebookEntry)strippedPBE;
                // Here we use an wrapper class to be easily used on the front end
                productList.add( new Product(pbe.Product2.Name, pbe.UnitPrice, pbe.Id) );
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()); 
        }
    
        return productList;
    }

    
    /**
     * @description - Get Order Products related with given Order Id
     * @author Augusto Presotto da Costa | 10-15-2021 
     * @param Id orderId 
     * @return List<OrderProduct> 
     **/
    @AuraEnabled(cacheable=true)
    public static List<OrderProduct> getOrderProducts(Id orderId) {
        List<OrderProduct> orderProductList = new List<OrderProduct>();

        try {
            for (OrderItem item : OrderItemSelector.selectByOrderId(orderId)) {
                // Here we use an wrapper class to be easily used on the front end
                orderProductList.add( new OrderProduct(item.Product2.Name, item.UnitPrice, item.Quantity, item.TotalPrice) );
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return orderProductList;
    }
    
    
    /**
     * @description - Method used to add Product as an Order Product (OrderItem) 
     * @author Augusto Presotto da Costa | 10-15-2021 
     * @param Id orderId 
     * @param Id pricebookEntryId  - Id of the entry of the product
     * @param Decimal unitPrice 
     **/
    @AuraEnabled
    public static void addProductToOrder(Id orderId, Id pricebookEntryId, Decimal unitPrice) {
        try {
            OrderItemService.add(orderId, pricebookEntryId, unitPrice);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @TestVisible
    class Product {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Decimal unitPrice;
        @AuraEnabled
        public String pricebookEntryId;

        public Product(String name, Decimal unitPrice, String pbeId) {
            this.name = name;
            this.unitPrice = unitPrice;
            this.pricebookEntryId = pbeId;
        }
    }
    
    @TestVisible
    class OrderProduct {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Decimal unitPrice;
        @AuraEnabled
        public Decimal quantity;
        @AuraEnabled
        public Decimal totalPrice;

        public OrderProduct(String name, Decimal unitPrice, Decimal quantity, Decimal totalPrice) {
            this.name = name;
            this.unitPrice = unitPrice;
            this.quantity = quantity;
            this.totalPrice = totalPrice;
        }
    }
}
