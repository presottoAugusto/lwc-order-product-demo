/**
 * @description       : Contains Pricebook Entry Queries
 * @author            : Augusto Presotto da Costa
 * @group             : 
 * @last modified on  : 10-17-2021
 * @last modified by  : Augusto Presotto da Costa
**/
public with sharing class PricebookEntrySelector {

    /**
    * @description - Select Pricebook Entries by Pricebook Id
    * @author Augusto Presotto da Costa | 10-14-2021 
    * @param Id pricebookId 
    * @return List<PricebookEntry> 
    **/
    public static List<PricebookEntry> selectByPricebookId(Id pricebookId, Integer offset) {
        return [SELECT Id, Product2.Id, Product2.Name, UnitPrice 
                FROM PricebookEntry 
                WHERE Pricebook2Id = :pricebookId AND isActive = true AND Product2.isActive = true 
                ORDER BY Product2.Name
                LIMIT 15 OFFSET :offset
                ];
    }
} 