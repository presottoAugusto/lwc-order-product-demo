/**
 * @description       : 
 * @author            : Augusto Presotto da Costa
 * @last modified on  : 10-17-2021
 * @last modified by  : Augusto Presotto da Costa
**/
public with sharing class ConfirmOrder {

    private static final String METHOD = 'POST';
    private static final String CALLOUT_ENDPOINT = 'callout:Confirm_Order';
   
    @AuraEnabled

    /**
    * @description - Method to confirm the order on the external system
    * @author Augusto Presotto da Costa | 10-17-2021 
    * @param Id orderId 
    * @return Map<String, String> - Map return if was success or not
    **/
    public static Map<String,String> confirm(Id orderId) {

        Order o = OrderSelector.selectOrderToConfirm(orderId);
        if (o.OrderItems.isEmpty()) {
            // To avoid errors one Activating the order we already check if there are order items
            throw new AuraHandledException('Unable to Confirm Order. There must be at least one Order Item related to the Order');
        }
        List<OrderProduct> productList = new List<OrderProduct>();
        //Iterate through Order Items related to Order in order to Add them to wrapper class
        for (OrderItem oi : o.OrderItems) {
            OrderProduct product = new OrderProduct();
            product.name = oi.Product2.Name;
            product.code = oi.Product2.ProductCode;
            product.unitPrice = oi.UnitPrice;
            product.quantity = Integer.valueOf(oi.Quantity);
            productList.add(product);
        }

        //Get the object we want to send in a Wrapper Class
        OrderJSON order = new OrderJSON(o.Account.AccountNumber, o.OrderNumber, o.Type, o.Status, productList);

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();

        request.setEndpoint(CALLOUT_ENDPOINT);
        request.setMethod(METHOD);
        request.setbody(JSON.serialize(order));

        Map<String,String> responseMap = new Map<String,String>();  

        try {
            response = http.send(request);
            if (response.getStatusCode() == 200) {
                responseMap.put('success', 'true');
                OrderService.activateOrder(o);
            } else {
                throw new AuraHandledException('Unable to Confirm Order.');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

      return responseMap;
    }

    class OrderProduct {
        public String name { get; set; }
        public String code { get; set; }
        public Decimal unitPrice { get; set; }
        public Integer quantity { get; set; }
    }

    class OrderJSON {
        public String accountNumber;
        public String orderNumber;
        public String type;
        public String status;
        public List<OrderProduct> orderProducts;

        public OrderJSON(String accNumber, String orderNumber, String type, String status, List<OrderProduct> products) {
            this.accountNumber = accNumber;
            this.orderNumber = orderNumber;
            this.type = type;
            this.status = status;
            this.orderProducts = products;
        }
    }
}